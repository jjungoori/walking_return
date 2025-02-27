import 'dart:collection';
import 'dart:math';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AsyncTaskQueue {
  // 작업 큐 (HashMap을 기반으로 구현)
  final _queue = HashMap<int, dynamic>();

  // 작업이 있는지 여부를 관찰 가능한 변수로 제공
  final RxBool hasTasks = false.obs;

  /// 작업 추가 (비동기 작업 시작 시 호출)
  void addTask(int key) {
    _queue[key] = 1;
    _updateTaskStatus();
  }

  /// 작업 제거 (비동기 작업 완료 시 호출)
  dynamic removeTask(int key) {
    final taskData = _queue.remove(key);
    _updateTaskStatus();
    return taskData;
  }

  /// 현재 작업 큐의 상태를 업데이트
  void _updateTaskStatus() {
    hasTasks.value = _queue.isNotEmpty;
    print('Task Queue: ${hasTasks.value}');
  }

  /// 특정 키의 작업 데이터를 가져오기
  dynamic getTask(int key) {
    return _queue[key];
  }

  /// 작업이 비어 있는지 확인
  bool isEmpty() => _queue.isEmpty;

  /// 작업이 있는지 확인
  bool isNotEmpty() => _queue.isNotEmpty;

  /// 작업 실행 및 자동 큐 관리
  Future<T> executeTask<T>(Future<T> Function() asyncTask) async {
    final key = _generateHash();
    addTask(key);
    print('Task added: ${key}');
    try {
      return await asyncTask();
    } finally {
      removeTask(key);
      print('Task removed: ${key}, Remaining tasks: ${_queue}');
    }
  }

  /// 해시 키 자동 생성
  int _generateHash() {
    return Random().nextInt(1 << 32);
  }
}

