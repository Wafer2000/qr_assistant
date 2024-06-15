import 'package:flutter/material.dart';

/*
Black: White (0xFFFFFFFF)
White: Black (0xFF000000)
Venice Blue: Iceberg (0xFFE5F3F7)
Iceberg: Venice Blue (0xFF07529B)
Steel Blue: Kashmir Blue (0xFF4D7397)
Viking: Blue Zodiac (0xFF123353)
Kashmir Blue: Steel Blue (0xFF4E8EB9)
Blue Zodiac: Viking (0xFF70B3DC)
Danube: Bali Hai (0xFF8894B2)
Catalina Blue: Danube (0xFF639DD6)
Bali Hai: Catalina Blue (0xFF062A78)
*/ 

class MyColor {
  final Color color;

  const MyColor._(this.color);

  factory MyColor.black() {
    return const MyColor._(Color(0xFF000000));
  }

  factory MyColor.white() {
    return const MyColor._(Color(0xFFFFFFFF));
  }

  factory MyColor.wheat() {
    return const MyColor._(Color(0xFFF4DCAD));
  }

  factory MyColor.spectra() {
    return const MyColor._(Color(0xFF2D5A58));
  }

  factory MyColor.deYork() {
    return const MyColor._(Color(0xFF6EC495));
  }

  factory MyColor.bunker() {
    return const MyColor._(Color(0xFF0A0D0F));
  }

  factory MyColor.crail() {
    return const MyColor._(Color(0xFFBD5E3B));
  }

  factory MyColor.thatchGreen() {
    return const MyColor._(Color(0xFF3C431C));
  }

  factory MyColor.jungleGreen() {
    return const MyColor._(Color(0xFF259675));
  }

  factory MyColor.naturalGray() {
    return const MyColor._(Color(0xFF8B897F));
  }

  factory MyColor.grayChateau() {
    return const MyColor._(Color(0xFFA0A9B4));
  }
}