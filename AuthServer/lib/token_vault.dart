library TokenVault;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:openreception_framework/cache.dart' as IO;
import 'package:openreception_framework/common.dart';

TokenVault vault = new TokenVault();

class TokenVault {
  Map<String, Map> _userTokens = new Map<String, Map>();
  Map<String, Map> _serverTokens = new Map<String, Map>();

  Map getToken(String token) {
    if(_userTokens.containsKey(token)) {
      return _userTokens[token];
    } else if (_serverTokens.containsKey(token)) {
      return _serverTokens[token];
    } else {
      throw new Exception('getToken. Unknown token: ${token}');
    }
  }

  void insertToken(String token, Map data) {
    print(data);
    if(_userTokens.containsKey(token)) {
      throw new Exception('insertToken. Token allready exists: $token');
    } else {
      _userTokens[token] = data;
    }
  }

  void updateToken(String token, Map data) {
    if(_userTokens.containsKey(token)) {
      _userTokens[token] = data;
    } else if (_serverTokens.containsKey(token)) {
       return;
    }
    else {
      throw new Exception('updateToken. Unknown token: ${token}');
    }
  }

  bool containsToken(String token) =>
      _userTokens.containsKey(token) ||
      _serverTokens.containsKey(token);

  void removeToken(String token) {
    if(_userTokens.containsKey(token)) {
      _userTokens.remove(token);
    } else {
      throw new Exception('containsToken. Unknown token: ${token}');
    }
  }

  Iterable<String> listUserTokens() {
    return _userTokens.keys;
  }

  Future loadFromDirectory(String directory) {
    if(directory != null) {
      return IO.list(directory).then((List<FileSystemEntity> list) {

        return Future.forEach(list, (FileSystemEntity item) {
          if(item is File) {
            IO.load(item.path).then((String text) {
              //TODO handle systems that do not seperate folders with "/"
              String token = item.path.split('/').last.split('.').first;
              Map data = JSON.decode(text);
              _serverTokens[token] = data;
              print ('Loaded ${_serverTokens[token]}');
            }).catchError((error) {
              log('TokenVault.loadFromDirectory() ${error}');
            });
          }
        });

      });
    } else {
      return new Future.value();
    }
  }
}