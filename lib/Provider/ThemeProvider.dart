import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier{
  var _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void setTheme(themeMode) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    _themeMode = themeMode;

    if(themeMode == ThemeMode.dark){
      pref.setBool("isDarkMode", true);
    }else{
      pref.setBool("isDarkMode", false);
    }
    notifyListeners();
  }
}