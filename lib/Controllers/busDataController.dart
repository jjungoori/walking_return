import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:walking/Controllers/userDataController.dart';
import 'package:walking/modules/asyncQueue.dart';

// asyncQueue 적용 완료

// 실제 로직에 사용되는 변수와 그렇지 않은 변수가 섞여 있어서 Service와 ViewModel을 분리
// Service는 실제 로직을 담당하고, ViewModel은 UI또는 반환에 필요한 변수와 함수를 제공

// 추가적으로
// Service에서는 화면에 관계 없이 공통되는 데이터만을 저장함.
// 데이터를 저장할 수 있다는 걸 알아둬야함.

class StudentData {
  final String name;
  final String busId;
  final String description;
  final bool isArrived;
  final bool isAbsent;
  final String? ID;
  final bool temporary;

  StudentData({
    required this.name,
    required this.description,
    required this.busId,
    required this.isArrived,
    required this.isAbsent,
    required this.temporary,

    this.ID,
  });


  /// Firestore 데이터를 `StudentData` 객체로 변환
  factory StudentData.fromFirestore(Map<String, dynamic> data, String id) {
    return StudentData(
      ID: id,
      name: data['name'] ?? '',
      busId: data['busId'] ?? '',
      description: (data['description'] ?? 'No description'),
      isArrived: data['isArrived'] ?? false,
      isAbsent: data['isAbsent'] ?? false,
      temporary: data['temporary'] ?? false,
    );
  }

  /// 객체를 Firestore에 저장 가능한 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'busId': busId,
      'description': description,
      'isArrived': isArrived,
      'isAbsent': isAbsent,
      'temporary': temporary,
    };
  }

  StudentData copyWith({
    String? name,
    String? busId,
    String? description,
    bool? isArrived,
    String? ID,
    bool? isAbsent,
    bool? temporary,
  }) {
    return StudentData(
      name: name ?? this.name,
      busId: busId ?? this.busId,
      description: description ?? this.description,
      isArrived: isArrived ?? this.isArrived,
      ID: ID ?? this.ID,
      isAbsent: isAbsent ?? this.isAbsent,
      temporary: temporary ?? this.temporary,
    );
  }
}

class BusDataService extends GetxService {
  static BusDataService get to => Get.find();

  var targetBusId = ''.obs;
  Rxn<Map<String, dynamic>> busData = Rxn<Map<String, dynamic>>();

  RxList<StudentData> sortedStudents = <StudentData>[].obs;

  void setTargetBusId(String busId){
    targetBusId.value = busId;
  }

  Future<void> fetchBusData() async {
    try {
      // Firestore 경로: buses
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore.instance
          .collection('buses')
          .doc(targetBusId.value) // 특정 documentID로 접근
          .get();

      await fetchStudentsForBus(targetBusId.value).then((students) {
        sortedStudents.value = students
            .map((student) => StudentData(
          ID: student['id'],
          name: student['name'],
          busId: student['busId'],
          description: (student['description'] ?? "NODES").trim(), // description에서 뒤에 붙은 띄어쓰기 제거
          isArrived: student['isArrived'] ?? false,
          isAbsent: student['isAbsent'] ?? false,
          temporary: student['temporary'] ?? false,
        ))
            .toList();

        // name을 가나다 순으로 정렬
        sortedStudents.sort((a, b) => a.name.compareTo(b.name));
      });

      if (docSnapshot.exists) {
        busData.value = docSnapshot.data();
        print("Bus data fetched successfully for document ID: ${targetBusId.value}");
        print(busData);
      } else {
        print("No bus found with document ID: ${targetBusId.value}");
      }
    } catch (e) {
      print("Error fetching bus data for document ID ${targetBusId.value}: $e");
    }
    return;
  }

  // fetchBusData 내부에서 호출
  Future<List<Map<String, dynamic>>> fetchStudentsForBus(String busId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('buses')
          .doc(busId)
          .collection('students')
          .get();

      // Map each document into a list of maps
      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print("Failed to fetch students: $e");
      throw Exception("Failed to fetch students");
    }
  }

  /// 학생 데이터를 Firestore에 추가하는 함수
  Future<void> addStudent(StudentData data) async {
    if (targetBusId.value.isEmpty) {
      print("targetBusId is not set");
      return;
    }

    try {
      // Firestore 경로: buses/{targetBusId}/students/{generatedId}
      await FirebaseFirestore.instance
          .collection('buses')
          .doc(targetBusId.value)
          .collection('students')
          .add({
        'name': data.name,
        'busId': data.busId,
        'description': data.description,
        'isArrived': data.isArrived,
        'isAbsent': data.isAbsent,
        'temporary': data.temporary,
      });

      print("Student added successfully");
    } catch (e) {
      print("Error adding student: $e");
    }
  }

  /// 학생 데이터를 Firestore에서 삭제하는 함수
  Future<void> removeStudent(String studentId) async {
    if (targetBusId.value.isEmpty) {
      print("targetBusId is not set");
      return;
    }

    try {
      // Firestore 경로: buses/{targetBusId}/students/{studentId}
      await FirebaseFirestore.instance
          .collection('buses')
          .doc(targetBusId.value)
          .collection('students')
          .doc(studentId)
          .delete();

      print("Student removed successfully");
    } catch (e) {
      print("Error removing student: $e");
    }
  }
}

class ProcessedBusData {
  // 가공되지 않고 바로 사용되는 데이터
  var busName = '';
  var leaderName = '';
  var leaders = [];
  var description = '';

  // 가공이 필요한 데이터
  var leaderCount = 0;
  var studentCount = 0;
  var ownerId = '';

  ProcessedBusData(busName, leaderName, leaders, description, leaderCount, studentCount, ownerId){
    this.busName = busName;
    this.leaderName = leaderName;
    this.leaders = leaders;
    this.description = description;
    this.leaderCount = leaderCount;
    this.studentCount = studentCount;
    this.ownerId = ownerId;
  }
}

class BusDataViewModel extends GetxController {
  static BusDataViewModel get to => Get.find();
  final BusDataService _busDataService = Get.find();
  get targetBusId => _busDataService.targetBusId.value;
  get sortedStudents => _busDataService.sortedStudents;

  final AsyncTaskQueue _asyncTaskQueue = AsyncTaskQueue();
  RxBool get isLoading => _asyncTaskQueue.hasTasks;

  Rxn<Map<String, dynamic>> busData = Rxn<Map<String, dynamic>>();

  Rx<ProcessedBusData> processedBusData = ProcessedBusData('Error', '', [], '', 0, 0, '').obs;

  @override
  void onInit() {
    super.onInit();
    // _busDataService.fetchSortedStudents();
    // fetchBusesForLeader(); // Fetch buses when the controller initializes
  }

  Future<void> processBusData() async {
    _asyncTaskQueue.executeTask(() async{
      if (busData.value == null) {
        print("Bus data is null");
        return;
      }

      var leaderCount = (busData.value!['leaders'] ?? []).length;
      var ownerName = await CommonUserDataViewModel.to.getLeaderName(busData.value!['ownerId']);
      var studentCount = sortedStudents.length;

      processedBusData.value = ProcessedBusData(
        busData.value!['name'],
        ownerName,
        busData.value!['leaders'],
        busData.value!['description'],
        leaderCount,
        studentCount,
        busData.value!['ownerId'],
      );


      print("Processing bus data...");
    });
  }

  Future<void> setTargetBusId(String busId) async {
    _busDataService.setTargetBusId(busId);
    await fetchBusData();
    return;
  }

  Future<void> fetchBusData() async {
    await _asyncTaskQueue.executeTask(() async{
      await _busDataService.fetchBusData();
      busData.value = _busDataService.busData.value;
      await processBusData();
    });
    return;
  }


  Future<bool> addStudent(StudentData studentData) async {
    var suc = false;
    if(studentData.name.isEmpty){
      return false;
    }
    await _asyncTaskQueue.executeTask(() async{
      try {
        await _busDataService.addStudent(studentData);
        await fetchBusData();
        print("Student added via ViewModel successfully");
        suc = true;
      } catch (e) {
        print("Error adding student via ViewModel: $e");
      }

    });
    return suc;
  }

  Future<void> removeStudent(String studentId) async {
    sortedStudents.removeWhere((element) => element.ID == studentId);
    _asyncTaskQueue.executeTask(() async{
      try {
        await _busDataService.removeStudent(studentId);
        await fetchBusData();
        print("Student removed via ViewModel successfully");
      } catch (e) {
        print("Error removing student via ViewModel: $e");
      }
      finally{
        return;
      }
    });
  }
}
