import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeServices
{
  final GetStorage box = GetStorage();
  final key = "isDarkMode";

  saveThemeToBox(bool isDarkMode) => box.write(key, isDarkMode);

  bool _loadThemeFromBox() => box.read<bool>(key) ?? false;

  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  void switchTheme()
  {
    Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    saveThemeToBox(!_loadThemeFromBox());
  }
}
