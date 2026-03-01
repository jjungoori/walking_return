import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils.dart';
import 'busDataController.dart';

class NoteService extends GetxService {
  static NoteService get to => Get.find();

  final _firebaseFirestore = FirebaseFirestore.instance;

  /// 학생 데이터 변경을 실시간으로 구독
  Stream<List<StudentData>> listenToStudents(String busId) {
    return _firebaseFirestore
        .collection('buses')
        .doc(busId)
        .collection('students')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return StudentData.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// 학생 데이터를 수정하는 함수
  Future<void> updateStudent(String busId, String studentId, StudentData updatedData) async {
    try {
      await _firebaseFirestore
          .collection('buses')
          .doc(busId)
          .collection('students')
          .doc(studentId)
          .update(updatedData.toFirestore());
      print("Student updated successfully");
    } catch (e) {
      print("Error updating student: $e");
    }
  }
}

class NoteViewModel extends GetxController {
  static NoteViewModel get to => Get.find();

  final NoteService _noteService = Get.find();

  final RxList<StudentData> students = <StudentData>[].obs;
  final RxString currentBusId = ''.obs;

  var editMode = false.obs;

  var isLoading = false.obs;

  var offFailureCount = 0;
  var previousStudent = "";

  /// 특정 busId에 대해 학생 데이터 실시간 구독 시작
  void listenToStudents(String busId) async {
    currentBusId.value = busId;
    isLoading.value = true; // 데이터 로드 시작

    _noteService.listenToStudents(busId).listen((studentList) {
      studentList.sort((a, b) => a.name.compareTo(b.name));
      students.assignAll(studentList);
      isLoading.value = false; // 데이터 로드 완료
      print("Students updated: ${students.length} students loaded.");
    }, onError: (error) {
      isLoading.value = false; // 에러 발생 시 로드 상태 종료
      print("Error loading students: $error");
    });
  }

  /// 학생 데이터를 수정
  Future<void> updateStudent(StudentData updatedStudent) async {
    if (currentBusId.value.isEmpty) {
      print("Bus ID is not set");
      return;
    }

    var updatedStudentHash = (updatedStudent.isAbsent.hashCode ^ updatedStudent.isArrived.hashCode ^ updatedStudent.ID.hashCode).toString();

    // Foolproof: 연속으로 출석 취소에 실패할 때
    if (previousStudent == updatedStudentHash) {
      offFailureCount++;
      if (offFailureCount > 3) {
        // 진동 주기
        HapticFeedback.lightImpact();

        Get.snackbar(
          "취소 제스처",
          "취소하려면 학생을 꾹 눌러주세요.",
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
        offFailureCount = 0;
      }
    }
    previousStudent = updatedStudentHash;
    print(previousStudent);

    await _noteService.updateStudent(
      currentBusId.value,
      updatedStudent.ID!,
      updatedStudent,
    );
  }

  Future<void> resetNote() async {
    if (currentBusId.value.isEmpty) {
      print("Bus ID is not set");
      return;
    }

    // 모든 학생 데이터 복사본 생성
    var studentList = List.from(students);

    for (var student in studentList) {
      // 학생의 출석 상태를 취소
      if (student.temporary == true) {
        await BusDataViewModel.to.removeStudent(student.ID!);
        continue;
      }

      var updatedStudent = student.copyWith(isArrived: false, isAbsent: false); // isArrived를 false로 변경
      await updateStudent(updatedStudent);
    }
  }
}
