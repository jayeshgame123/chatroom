import 'package:flutter/cupertino.dart';

class CountProvider with ChangeNotifier{

  int _count = 0;
  get count => _count;

  void setCount(){
    if(_count == 0){
      _count+1;
    }else{
      _count-1;
    }
    notifyListeners();
  }
}