import 'dart:math';

import 'package:flutter/material.dart';

class ScaleConfig {
  late MediaQueryData _mediaQueryData;
  late double width;
  late double height;
  late double heightUsable;
  late double gridWidth;
  late double gridHeight;
  late double tileSize;
  late double tileFontSize;
  late double iconSize;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    width = _mediaQueryData.size.width;
    height = _mediaQueryData.size.height;
    heightUsable = height - _mediaQueryData.padding.top - kToolbarHeight;
  }

  void recalculate(int rows, int cols) {
    width = _mediaQueryData.size.width;
    height = _mediaQueryData.size.height;
    heightUsable = height - _mediaQueryData.padding.top - kToolbarHeight - 40;
    // 61 is height of mines remaining/timer box

    double boardRatio = rows / cols;
    double aspectRatio = width / heightUsable;
    if (boardRatio >= 3 || aspectRatio >= 3) {
      gridWidth = width / 3;
      gridHeight = heightUsable * 0.95;
    } else {
      gridWidth = min(width * 0.9, heightUsable * 0.9);
      gridHeight = gridWidth * boardRatio;
    }
    tileSize = (gridWidth - 10) / cols;
    iconSize = tileSize * 0.8;
    tileFontSize = tileSize * 0.6;
  }
}
