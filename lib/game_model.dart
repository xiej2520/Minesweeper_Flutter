import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:collection';

class Tile {
  int minesNearby;
  bool revealed = false;
  bool flagged = false;

  Tile(this.minesNearby);
}

class Game {
  List<List<Tile>> board = [];
  int rows;
  int cols;
  int numMines;
  late int remainingTiles;
  int state = 0; // 0: in progress, 1: won, 2: lost

  Game(this.rows, this.cols, this.numMines) {
    board = List<List<Tile>>.generate(
        rows, (i) => List<Tile>.generate(cols, (j) => Tile(0)));
    int minesToPlace = numMines;
    remainingTiles = rows * cols - numMines;

    Random rng = Random();
    // splaytree for list of remaining indicies without a mine
    SplayTreeSet<int> remaining =
        SplayTreeSet<int>.from([for (int i = 0; i < rows * cols; i++) i]);
    while (minesToPlace > 0) {
      int randIndex = remaining.elementAt(rng.nextInt(remaining.length));
      Pair p = indexToPair(randIndex);
      remaining.remove(randIndex);
      board[p.x][p.y].minesNearby = -1; // set mine
      for (Pair dp in ordinalDirections) {
        Pair q = dp + p;
        if (q.x >= 0 &&
            q.x < rows &&
            q.y >= 0 &&
            q.y < cols &&
            board[q.x][q.y].minesNearby != -1) {
          board[q.x][q.y].minesNearby++;
        }
      }
      minesToPlace--;
    }
  }

  bool click(Pair p) {
    if (board[p.x][p.y].minesNearby == -1) {
      state = 2;
      _revealBoard();
      return true;
    }
    _dfs(p);
    if (remainingTiles == 0) {
      state = 1;
      _revealBoard();
    }
    return false;
  }

  void flag(Pair p) {
    board[p.x][p.y].flagged = !board[p.x][p.y].flagged;
  }

  void _dfs(Pair p) {
    if (p.x < 0 ||
        p.x >= rows ||
        p.y < 0 ||
        p.y >= cols ||
        board[p.x][p.y].minesNearby == -1 ||
        board[p.x][p.y].revealed) {
      return;
    }
    board[p.x][p.y].flagged = false;
    board[p.x][p.y].revealed = true;
    remainingTiles--;
    for (Pair dp in cardinalDirections) {
      debugPrint((dp + p).toString());
      _dfs(dp + p);
    }
  }

  void _revealBoard() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        board[i][j].revealed = true;
      }
    }
  }

  Pair indexToPair(int index) {
    return Pair(index ~/ rows, index % rows);
  }

  int pairToIndex(Pair p) {
    return p.x * rows + p.y;
  }

  static List<Pair> ordinalDirections = [
    // 8 ordinal directions
    for (int i = -1; i <= 1; i++) [for (int j = -1; j <= 1; j++) Pair(i, j)]
  ].expand((i) => i).toList();

  static List<Pair> cardinalDirections = [
    Pair(-1, 0),
    Pair(1, 0),
    Pair(0, -1),
    Pair(0, 1)
  ];
}

class GameModel extends ChangeNotifier {
  late Game game;
  int state = -1; // -1: uninitialized, 0: in progress, 1: won, 2: lost

  GameModel();

  void createGame(int rows, int cols, int numMines) {
    game = Game(rows, cols, numMines);
    state = 0;
    notifyListeners();
  }

  void click(int index) {
    game.click(game.indexToPair(index));
    if (game.state == 1 || game.state == 2) {
      state = game.state;
    }
    notifyListeners();
  }

  void flag(int index) {
    game.flag(game.indexToPair(index));
    notifyListeners();
  }

  Tile getTile(int index) {
    Pair p = game.indexToPair(index);
    return game.board[p.x][p.y];
  }

  int get numTiles => game.rows * game.cols;
  Pair get getBoardDims => Pair(game.rows, game.cols);
}

class Pair {
  int x;
  int y;
  Pair(this.x, this.y);

  Pair operator +(Pair other) {
    return Pair(x + other.x, y + other.y);
  }

  @override
  String toString() => '($x,$y)';
}

Color nearbyColorMap(int nearbyMines) {
  switch (nearbyMines) {
    case 0:
      return Colors.greenAccent.shade700;
    case 1:
      return Colors.yellowAccent;
    case 2:
      return Colors.yellow.shade700;
    case 3:
      return Colors.yellow.shade900;
    case 4:
      return Colors.red.shade700;
    case 5:
      return Colors.red.shade900;
    case 6:
      return Colors.purple.shade700;
    case 7:
      return Colors.blue.shade900;
    case 8:
      return Colors.pink.shade600;
  }
  return Colors.white;
}
