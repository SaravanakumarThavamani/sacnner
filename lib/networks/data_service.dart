import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../routes_list.dart';

abstract class TokenDataService {
  String? accessToken;
  int? userId;
  String? userName;
  String? email;
  String? phoneNumber;
  bool? rememberMe;
  String? savedEmail;
  String? savedPassword;
  String? activeUserType;

  bool get isLoggedIn;

  void logout();
  void registerLogout();
}

class TokenDataServiceImp extends BaseDataService implements TokenDataService {
  TokenDataServiceImp() : super('localBox');
  @override
  bool? get rememberMe {
    return getValue('rememberMe') ?? false;
  }

  @override
  set rememberMe(bool? value) {
    setValue(value, 'rememberMe');
  }

  @override
  String? get savedEmail {
    return getValue('savedEmail');
  }

  @override
  set savedEmail(String? value) {
    setValue(value, 'savedEmail');
  }

  @override
  String? get savedPassword {
    return getValue('savedPassword');
  }

  @override
  set savedPassword(String? value) {
    setValue(value, 'savedPassword');
  }

  @override
  String? get accessToken {
    return getValue('Token');
  }

  @override
  set accessToken(String? token) {
    setValue(token, 'Token');
  }

  @override
  int? get userId {
    return getValue('UserId');
  }

  @override
  set userId(int? id) {
    setValue(id, 'UserId');
  }

  @override
  String? get userName {
    return getValue('userName');
  }

  @override
  set userName(String? name) {
    setValue(name, 'userName');
  }

  @override
  String? get email {
    return getValue('email');
  }

  @override
  set email(String? name) {
    setValue(name, 'email');
  }

  @override
  String? get phoneNumber {
    return getValue('phoneNumber');
  }

  @override
  set phoneNumber(String? name) {
    setValue(name, 'phoneNumber');
  }

  @override
  String? get activeUserType {
    return getValue('activeUserType');
  }

  @override
  set activeUserType(String? name) {
    setValue(name, 'activeUserType');
  }

  @override
  bool get isLoggedIn {
    return accessToken != null && accessToken!.isNotEmpty;
  }

  Future<void> saveRememberMeState({
    required bool remember,
    required String email,
    required String password,
  }) async {
    await _localBox.put('rememberMe', remember);
    _mappings['rememberMe'] = remember;

    if (remember) {
      await _localBox.put('savedEmail', email.trim());
      await _localBox.put('savedPassword', password);
      _mappings['savedEmail'] = email.trim();
      _mappings['savedPassword'] = password;
    } else {
      await _localBox.delete('savedEmail');
      await _localBox.delete('savedPassword');
      _mappings.remove('savedEmail');
      _mappings.remove('savedPassword');
    }
  }

  @override
  Future<void> logout() async {
    await _localBox.delete('Token');
    await _localBox.delete('UserId');
    await _localBox.delete('userName');
    await _localBox.delete('email');
    await _localBox.delete('phoneNumber');
    await _localBox.delete('activeUserType');
    // await _localBox.delete('rememberMe');
    // await _localBox.delete('savedEmail');
    // await _localBox.delete('savedPassword');
    _mappings.clear();

    Get.offAllNamed(RouteList.login);
  }

  @override
  void registerLogout() {
    _removeKey('Token');
    _removeKey('UserId');
    _removeKey('userName');
    _removeKey('activeUserType');
    _removeKey('email');
    _removeKey('phoneNumber');

    // _removeKey('rememberMe');
    // _removeKey('savedEmail');
    // _removeKey('savedPassword');

    _mappings.clear();
  }
  // @override
  // void registerLogout() {
  //   _removeKey('Token');
  //   _removeKey('UserId');
  //   _removeKey('userName');

  //   _removeKey('activeUserType');
  //   _removeKey("email");
  //   _removeKey("phoneNumber");

  //   _mappings.clear();
  // }

  void _removeKey(String key) {
    _localBox.delete(key);
    _mappings.remove(key);
  }
}

abstract class BaseDataService {
  final String _boxName;
  late Box<dynamic> _localBox;
  final Map<String, dynamic> _mappings = <String, dynamic>{};
  BaseDataService(this._boxName) {
    _localBox = Hive.box(_boxName);
  }

  dynamic getValue([String callerMethodName = ""]) {
    if (!_mappings.containsKey(callerMethodName)) {
      _mappings[callerMethodName] = _localBox.get(callerMethodName);
    }
    return _mappings[callerMethodName];
  }

  void setValue(dynamic value, [String callerMethodName = ""]) {
    _localBox.put(callerMethodName, value);
    _mappings[callerMethodName] = value;
  }
}
