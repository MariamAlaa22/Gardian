import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'constants.dart';
import 'shared_prefs_utils.dart';

class LocaleUtils {
  
  static void setLocale(String languageCode) {
    saveSelectedLanguage(languageCode);
    
    
  }

  
  static void saveSelectedLanguage(String selectedLanguage) {
    SharedPrefsUtils.setString(Constants.appLanguage, selectedLanguage);
    SharedPrefsUtils.setBool(Constants.languageSelected, true);
  }

  
  static String getAppLanguage() {
    
    String savedLanguage = SharedPrefsUtils.getString(Constants.appLanguage) ?? 
                          ui.window.locale.languageCode;
    return savedLanguage;
  }

  
  static String initAppLanguage() {
    bool isLanguageSelected = SharedPrefsUtils.getBool(Constants.languageSelected);
    String languageToUse = getAppLanguage();

    if (!isLanguageSelected) {
      
      saveSelectedLanguage(languageToUse);
      SharedPrefsUtils.setBool(Constants.languageSelected, false);
    }
    
    return languageToUse;
  }
}