import 'dart:math';
import 'package:flutter/material.dart';

class BackgroundGenerator {
  static final Random _random = Random();

  
  static Color getRandomColor() {
    return Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );
  }

  
  static String getFirstCharacters(String name) {
    if (name.isEmpty) return "";
    
    StringBuffer firstCharacters = StringBuffer();
    List<String> words = name.split(" ");
    
    for (var word in words) {
      if (word.isNotEmpty && _isAlphabetic(word[0])) {
        firstCharacters.write(word[0]);
      }
    }

    return firstCharacters.toString().toUpperCase();
  }

  
  static bool _isAlphabetic(String char) {
    return RegExp(r'[a-zA-Z]').hasMatch(char);
  }
}