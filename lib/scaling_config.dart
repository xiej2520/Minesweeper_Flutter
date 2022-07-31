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
    heightUsable = height - _mediaQueryData.padding.top - kToolbarHeight - 60;
    // 61 is height of mines remaining/timer box

    double boardRatio = cols / rows;
    double aspectRatio = width / heightUsable;
    if (aspectRatio > 2.5 * boardRatio) {
      // switch to vertical with scrollbar
      tileSize = (width / 2 / cols).floorToDouble();
    } else {
      tileSize =
          min(width * 0.9 / cols, heightUsable * 0.9 / rows).floorToDouble();
    }
    gridWidth = tileSize * cols + 10;
    gridHeight = tileSize * rows + 10;
    iconSize = tileSize * 0.8;
    tileFontSize = tileSize * 0.6;
  }
}
