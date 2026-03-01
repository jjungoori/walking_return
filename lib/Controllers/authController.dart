import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../modules/getKakaoNick.dart';

// TODO: asyncQueue 적용하기

// 실제 로직에 사용되는 변수와 그렇지 않은 변수가 섞여 있어서 Service와 ViewModel을 분리
// Service는 실제 로직을 담당하고, ViewModel은 UI또는 반환에 필요한 변수와 함수를 제공

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<kakao.OAuthToken?> _loginWithKakaoRepo() async{
    var token;
    if (kIsWeb) {
      try {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
        return token;
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
      return null;
    }
    if (await kakao.isKakaoTalkInstalled()) {
      try {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
        return token;
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          throw error;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
          return token;
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
        return token;
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }
  }

  Future<void> loginWithKakao() async {
    // kakao.OAuthToken token = await kakao.UserApi.instance.loginWithKakaoAccount();
    try{
      kakao.OAuthToken token = (await _loginWithKakaoRepo())!;
      var providerId = kIsWeb ? 'oidc.kakao2' : 'oidc.kakao';
      var provider = OAuthProvider(providerId);
      var credential = provider.credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );
      await _firebaseAuth.signInWithCredential(credential);

      var userName = await getKakaoNickname();
      Get.showSnackbar(
        GetSnackBar(
          title: "환영합니다 ${userName}",
          message: '성공적으로 로그인되었습니다.',
          // icon: const Icon(Icons.user),
          duration: const Duration(seconds: 2),
          barBlur: 1,
        ),
      );
    }
    catch(e){
      print("카카오 로그인 실패: $e");
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    try {
      await kakao.UserApi.instance.logout();
    } catch (e) {
      print("카카오 로그아웃 실패(웹일 수 있음): $e");
    }
  }
}

class AuthViewModel extends GetxController {
  static AuthViewModel get to => Get.find();

  final AuthService _authService = Get.find();  // AuthService 의존성 주입

  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  StreamSubscription<User?>? _authSub;

  @override
  void onInit() {
    super.onInit();
    _authSub = _authService.authStateChanges().listen((user) {
      currentUser.value = user;
      isLoggedIn.value = user != null;
    });
    _checkLoginStatus();
  }

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }

  Future<void> _checkLoginStatus() async {
    isLoading.value = true;
    try {
      currentUser.value = await _authService.getCurrentUser();
      isLoggedIn.value = currentUser.value != null;
    } catch (e) {
      print("로그인 상태 확인 오류: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> loginWithKakao() async {
    var success = false;
    try {
      isLoading.value = true;
      await _authService.loginWithKakao();
      await _checkLoginStatus();
      isLoading.value = false;
      success = true;
      print("로그인 성공!!");
    } catch (e) {
      print("로그인 실패: $e");
      isLoading.value = false;
      success = false;
    } finally {
      isLoading.value = false;
      return success;
    }
  }

  Future<bool> logout() async {
    var success = false;
    try {
      isLoading.value = true;
      await _authService.logout();
      currentUser.value = null;
      isLoggedIn.value = false;
      success = true;
    } catch (e) {
      print("로그아웃 실패: $e");
    } finally {
      isLoading.value = false;
      return success;
    }
  }
}
