# [Minesweeper in Flutter](https://xiej2520.github.io/Minesweeper_Flutter/#/)

Minesweeper project for learning Flutter, written as fast as possible then improved later.

## Features

* Minesweeper game with support for up to 50x50 board sizes, flagging, first-click protection.
* Compilable to web, desktop, mobile with Flutter.

## Todo 

* Decompose the monolith game_widget.dart into multiple classes/widgets.
* Improve performance (may require replacing gridview with more performant structure).
* Question-mark flagging
* Ensure boards are solvable without guessing mode.

## Steps to build

1. Install the [Flutter sdk ](https://docs.flutter.dev/get-started/install).
2. Download or clone this repository:

    `git clone https://github.com/xiej2520/Minesweeper_Flutter.git`

3. Install the required dependencies from the project root with:

    `flutter pub get`

4. Choose the device to build to after:

    `flutter run`
