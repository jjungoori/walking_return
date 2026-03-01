import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:walking/Controllers/authController.dart';
import 'package:walking/Controllers/busDataController.dart';
import 'package:walking/modules/getKakaoNick.dart';

// TODO: asyncQueue 적용하기

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot> getLeader(String userUid) async {
    return await _firestore.collection('leaders').doc(userUid).get();
  }

  Future<void> addLeader(String leaderUid, String name, String email) async {
    await _firestore.collection('leaders').doc(leaderUid).set({
      'name': name,
      'email': email,
      'buses': [],  // Initialize with an empty list of buses
    });
  }

  Future<String> resolveAppUserId({
    required String firebaseUid,
    String? kakaoId,
  }) async {
    if (kakaoId == null || kakaoId.isEmpty) {
      return firebaseUid;
    }

    final kakaoMapRef = _firestore.collection('kakao_id_map').doc(kakaoId);
    final firebaseMapRef = _firestore.collection('firebase_uid_map').doc(firebaseUid);
    final appUserRef = _firestore.collection('app_users');

    return _firestore.runTransaction((transaction) async {
      final kakaoSnap = await transaction.get(kakaoMapRef);
      final firebaseSnap = await transaction.get(firebaseMapRef);
      String? appUserId;

      if (kakaoSnap.exists) {
        final data = kakaoSnap.data();
        final existingId = data?['appUserId'];
        if (existingId is String && existingId.isNotEmpty) {
          appUserId = existingId;
        }
      }

      if (appUserId == null && firebaseSnap.exists) {
        final data = firebaseSnap.data();
        final existingId = data?['appUserId'];
        if (existingId is String && existingId.isNotEmpty) {
          appUserId = existingId;
        }
      }

      appUserId ??= appUserRef.doc().id;

      transaction.set(
        kakaoMapRef,
        {
          'appUserId': appUserId,
          'kakaoId': kakaoId,
          'firebaseUid': firebaseUid,
          'firebaseUids': FieldValue.arrayUnion([firebaseUid]),
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      transaction.set(
        firebaseMapRef,
        {
          'appUserId': appUserId,
          'kakaoId': kakaoId,
          'firebaseUid': firebaseUid,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return appUserId;
    });
  }

  Future<void> migrateLeaderIfNeeded(String fromUid, String toUid) async {
    if (fromUid == toUid) return;

    final fromRef = _firestore.collection('leaders').doc(fromUid);
    final toRef = _firestore.collection('leaders').doc(toUid);
    final fromSnap = await fromRef.get();
    final toSnap = await toRef.get();

    if (!fromSnap.exists || toSnap.exists) {
      return;
    }

    final data = fromSnap.data() as Map<String, dynamic>;
    await toRef.set(data, SetOptions(merge: true));

    final buses = (data['buses'] as List<dynamic>? ?? []);
    for (final bus in buses) {
      final busId = bus['id'];
      if (busId is! String || busId.isEmpty) continue;
      final busRef = _firestore.collection('buses').doc(busId);
      await _firestore.runTransaction((transaction) async {
        final busSnap = await transaction.get(busRef);
        if (!busSnap.exists) return;
        final busData = busSnap.data() as Map<String, dynamic>;
        final ownerId = busData['ownerId'];
        final leadersRaw = (busData['leaders'] as List<dynamic>? ?? []);
        final leaders = leadersRaw.whereType<String>().toList();
        leaders.removeWhere((id) => id == fromUid);
        if (!leaders.contains(toUid)) {
          leaders.add(toUid);
        }
        final updates = <String, dynamic>{'leaders': leaders};
        if (ownerId == fromUid) {
          updates['ownerId'] = toUid;
        }
        transaction.update(busRef, updates);
      });
    }
  }

  Future<void> addLeaderToBus(String busId, String newLeaderUid) async {
    await _firestore.collection('buses').doc(busId).update({
      'leaders': FieldValue.arrayUnion([newLeaderUid]),
    });
  }

  Future<void> removeLeaderFromBus(String busId, String leaderUid) async {
    await _firestore.collection('buses').doc(busId).update({
      'leaders': FieldValue.arrayRemove([leaderUid]),
    });
  }

  Future<void> deleteBus(String leaderUid, String busId) async {
    // Step 1: Delete the bus document from the buses collection

    // await _firestore.collection('buses').doc(busId).delete();

    // Step 2: Remove the bus reference from the leader's buses list
    DocumentReference leaderRef = _firestore.collection('leaders').doc(leaderUid);
    DocumentSnapshot leaderDoc = await leaderRef.get();
    List<dynamic> currentBuses = leaderDoc.get('buses') ?? [];

    // Remove the bus from the list
    List<dynamic> updatedBuses = currentBuses.where((bus) => bus['id'] != busId).toList();

    // Update the leader's buses list
    await leaderRef.update({
      'buses': updatedBuses,
    });

    await removeLeaderFromBus(busId, leaderUid);
  }

  Future<List<Map<String, dynamic>>> fetchBusesForLeader(String leaderUid) async {
    DocumentSnapshot leaderDoc = await _firestore.collection('leaders').doc(leaderUid).get();
    if (!leaderDoc.exists) {
      throw Exception("Leader not found");
    }

    List<dynamic> busesList = leaderDoc.get('buses') ?? [];
    // busesList.sort((a, b) => (a['index'] as int).compareTo(b['index'] as int));

    List<Map<String, dynamic>> busDatas = [];
    for (var bus in busesList) {
      DocumentSnapshot busDoc = await _firestore.collection('buses').doc(bus['id']).get();
      if (busDoc.exists) {
        busDatas.add({
          'id': bus['id'],
          'data': busDoc.data(),
        });
      }
    }

    return busDatas;
  }

  Future<void> addBusToLeaderAndAddLeaderToBus(String leaderUid, String busId) async {
    DocumentReference leaderRef = _firestore.collection('leaders').doc(leaderUid);
    // DocumentSnapshot leaderDoc = await leaderRef.get();
    // List<dynamic> currentBuses = leaderDoc.get('buses') ?? [];
    // int nextIndex = .length;

    Map<String, dynamic> newBus = {
      'id': busId,
      // 'index': nextIndex,
    };

    await leaderRef.update({
      'buses': FieldValue.arrayUnion([newBus]),
    });

    await addLeaderToBus(busId, leaderUid);
  }

  Future<String> createBus(String leaderUid, String busName, String busDescription) async {
    DocumentReference newBusRef = await _firestore.collection('buses').add({
      'name': busName,
      'description': busDescription,
      'leaders': [leaderUid],
      'ownerId': leaderUid,
    });
    return newBusRef.id;
  }


  Future<String> getLeaderName(String leaderUid) async {
    DocumentSnapshot leaderDoc = await _firestore.collection('leaders').doc(leaderUid).get();
    if (!leaderDoc.exists) {
      throw Exception("Leader not found");
    }
    return leaderDoc.get('name');
  }
}

class CurrentUserDataViewModel extends GetxController {
  static CurrentUserDataViewModel get to => Get.find();

  // Service Layer Instance
  final UserDataService _userDataService = Get.find<UserDataService>();

  // Observables
  var buses = [].obs;
  var selectedBus = {}.obs;
  var isLoading = false.obs;
  var isLoadingForAddedBus = false.obs;
  var leaderId = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> createBusAndAddToLeader(String busName, String busDescription) async {

    if(busName == "") {
      Get.snackbar("오류", "버스 이름은 비워둘 수 없습니다.");
      return;
    }

    try {
      isLoadingForAddedBus(true);
      isLoading(true);
      String leaderUid = await ensureLeaderId();
      if (leaderUid.isEmpty) {
        Get.snackbar("Error", "No logged-in user found");
        return;
      }

      var temp = await _userDataService.createBus(leaderUid, busName, busDescription);
      await _userDataService.addBusToLeaderAndAddLeaderToBus(leaderUid, temp);
      await fetchBusesForLeader();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
      isLoadingForAddedBus(false);
    }
  }

  Future<void> checkIfNewUserAndInit() async {
    try {
      isLoading(true);
      String userUid = await ensureLeaderId();
      if (userUid.isEmpty) {
        Get.snackbar("Error", "No logged-in user found");
        return;
      }

      User? user = AuthViewModel.to.currentUser.value;
      DocumentSnapshot leaderDoc = await _userDataService.getLeader(userUid);
      if (!leaderDoc.exists) {
        addLeader(await getKakaoNickname() ?? "Anonymous", user?.email ?? "No email");
      }
    } catch (e) {
      Get.snackbar("Error-CheckNewUser", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> addLeader(String name, String email) async {
    try {
      isLoading(true);
      String leaderUid = await ensureLeaderId();
      if (leaderUid.isEmpty) {
        Get.snackbar("Error", "No logged-in user found");
        return;
      }

      await _userDataService.addLeader(leaderUid, name, email);
    } catch (e) {
      Get.snackbar("Error-AddLeader", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchBusesForLeader() async {
    try {
      isLoading(true);

      String leaderUid = await ensureLeaderId();
      if (leaderUid.isEmpty) {
        Get.snackbar("Error", "No logged-in user found");
        return;
      }

      var busDatas = await _userDataService.fetchBusesForLeader(leaderUid);
      buses.assignAll(busDatas);
      for(var bus in buses) {
        print(bus['id']);
      }
    } catch (e) {
      Get.snackbar("Error-FetchBuses", e.toString());
    } finally {
      isLoading(false);
    }
  }

  void handleQRCode(String? qrCode) {
    if(qrCode == null) {
      print("QR 코드가 null입니다.");
      return;
    }
    print("QR 코드: $qrCode");

    addBus(qrCode);
    BusDataViewModel.to.setTargetBusId(qrCode);
    Get.offAndToNamed('/home');
  }

  Future<void> addBus(String busId) async {
    try {
      isLoadingForAddedBus(true);
      isLoading(true);
      String leaderUid = await ensureLeaderId();
      if (leaderUid.isEmpty) {
        Get.snackbar("Error", "No logged-in user found");
        return;
      }

      await _userDataService.addBusToLeaderAndAddLeaderToBus(leaderUid, busId);
      await fetchBusesForLeader();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingForAddedBus(false);
      isLoading(false);
    }
  }

  Future<void> deleteBus(String busId) async {
    buses.removeWhere((bus) => bus['id'] == busId);

    try {
      isLoading(true);

      String leaderUid = await ensureLeaderId();
      if (leaderUid.isEmpty) {
        Get.snackbar("Error", "No logged-in user found");
        return;
      }

      await _userDataService.deleteBus(leaderUid, busId);
      await fetchBusesForLeader(); // Refresh the list after deletion
      // Get.snackbar("Success", "버스가 성공적으로 삭제되었습니다.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> createBus(String busName, String busDescription) async {
    try {
      isLoading(true);
      String leaderUid = await ensureLeaderId();
      if (leaderUid.isEmpty) {
        Get.snackbar("Error", "No logged-in user found");
        return;
      }

      await _userDataService.createBus(leaderUid, busName, busDescription);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<String> ensureLeaderId() async {
    if (leaderId.value.isNotEmpty) {
      return leaderId.value;
    }
    User? user = AuthViewModel.to.currentUser.value;
    if (user == null) {
      return '';
    }
    final kakaoId = await getKakaoId();
    final appUserId = await _userDataService.resolveAppUserId(
      firebaseUid: user.uid,
      kakaoId: kakaoId,
    );
    await _userDataService.migrateLeaderIfNeeded(user.uid, appUserId);
    leaderId.value = appUserId;
    return appUserId;
  }
}

class CommonUserDataViewModel extends GetxController {
  static CommonUserDataViewModel get to => Get.find();

  // Service Layer Instance
  final UserDataService _userDataService = Get.find<UserDataService>();

  // Observables
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<String> getLeaderName(String leaderUid) async {
    try {
      isLoading(true);
      return await _userDataService.getLeaderName(leaderUid);
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return "";
    } finally {
      isLoading(false);
    }
  }
}
