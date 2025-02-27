import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

Future<String?> getKakaoNickname() async {
  try {
    User user = await UserApi.instance.me();
    return user.kakaoAccount?.profile?.nickname;
  } catch (e) {
    print("Failed to get Kakao nickname: $e");
    return null;
  }
}