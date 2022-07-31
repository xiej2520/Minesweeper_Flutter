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
  List<List<int>> flagsNearby = [];
  int rows;
  int cols;
  int numMines;
  late int numFlags;
  late int remainingTiles;
  late SplayTreeSet<int> remaining;
  int state = -1; // -1: before first click, 0: in progress, 1: won, 2: lost

  Game(this.rows, this.cols, this.numMines) {
    board = List<List<Tile>>.generate(
        rows, (i) => List<Tile>.generate(cols, (j) => Tile(0)));
    // for proper dfs clearing without giving away info
    flagsNearby = List<List<int>>.generate(
        rows, (i) => List<int>.generate(cols, (j) => 0));
    numFlags = 0;
    remainingTiles = rows * cols - numMines;

    int minesToPlace = numMines;
    // splaytree for list of remaining indicies without a mine
    remaining =
        SplayTreeSet<int>.from([for (int i = 0; i < rows * cols; i++) i]);
    Random rng = Random();
    while (minesToPlace > 0) {
      int randIndex = remaining.elementAt(rng.nextInt(remaining.length));
      Pair p = indexToPair(randIndex);
      remaining.remove(randIndex);
      board[p.x][p.y].minesNearby = -1; // set mine
      _updateMineCountsNearby(p);
      minesToPlace--;
    }
  }

  void _updateMineCountsNearby(Pair p) {
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
  }

  void click(Pair p) {
    // first click can't be a mine
    if (state == -1) {
      if (board[p.x][p.y].minesNearby == -1) {
        board[p.x][p.y].minesNearby = 0;
        for (Pair dp in ordinalDirections) {
          Pair q = dp + p;
          if (q.x >= 0 && q.x < rows && q.y >= 0 && q.y < cols) {
            if (board[q.x][q.y].minesNearby == -1) {
              board[p.x][p.y].minesNearby++;
            } else {
              board[q.x][q.y].minesNearby--;
            }
          }
        }
        remaining.remove(p);
        Pair newMine = indexToPair(
            remaining.elementAt(Random().nextInt(remaining.length)));
        board[newMine.x][newMine.y].minesNearby = -1;
        _updateMineCountsNearby(newMine);
      }
      state = 0;
    }

    // hit a mine
    if (board[p.x][p.y].minesNearby == -1) {
      state = 2;
      _revealBoard();
      return;
    }
    board[p.x][p.y].revealed = true;
    remainingTiles--;
    // dfs clear any empty tiles
    if (board[p.x][p.y].minesNearby == 0) {
      for (Pair dp in ordinalDirections) {
        _dfs(dp + p);
      }
    }
    // won game, no non-mine tiles remaining
    if (remainingTiles == 0) {
      state = 1;
      _revealBoard();
    }
  }

  // swap flag status of tile
  void flag(Pair p) {
    board[p.x][p.y].flagged = !board[p.x][p.y].flagged;
    int d = board[p.x][p.y].flagged ? 1 : -1;
    numFlags += d;
    // update flagsNearby
    flagsNearby[p.x][p.y] += d;
    for (Pair dp in ordinalDirections) {
      Pair q = p + dp;
      if (q.x >= 0 && q.x < rows && q.y >= 0 && q.y < cols) {
        flagsNearby[q.x][q.y] += d;
      }
    }
  }

  // recursively clear any adjacent tiles that are not surrounded by mines
  void _dfs(Pair p) {
    if (p.x < 0 ||
        p.x >= rows ||
        p.y < 0 ||
        p.y >= cols ||
        flagsNearby[p.x][p.y] != 0 ||
        board[p.x][p.y].revealed) {
      return;
    }
    board[p.x][p.y].revealed = true;
    remainingTiles--;
    // only continue recursion if current tile has no mines nearby
    if (board[p.x][p.y].minesNearby == 0) {
      for (Pair dp in ordinalDirections) {
        _dfs(dp + p);
      }
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
    return Pair(index ~/ cols, index % cols);
  }

  int pairToIndex(Pair p) {
    return p.x * rows + p.y;
  }

  static List<Pair> ordinalDirections = cardinalDirections = [
    Pair(-1, -1),
    Pair(-1, 0),
    Pair(-1, 1),
    Pair(0, -1),
    Pair(0, 1),
    Pair(1, -1),
    Pair(1, 0),
    Pair(1, 1)
  ];

  static List<Pair> cardinalDirections = [
    Pair(-1, 0),
    Pair(1, 0),
    Pair(0, -1),
    Pair(0, 1)
  ];
}

class GameModel extends ChangeNotifier {
  late Game game;
  // -1: uninitialized, 0: in progress, 1: won, 2: lost
  bool displayedEndMessage = false;
  int state = -1;

  GameModel();

  void createGame(int rows, int cols, int numMines) {
    game = Game(rows, cols, numMines);
    state = 0;
    displayedEndMessage = false;
    notifyListeners();
  }

  void click(int index) {
    game.click(game.indexToPair(index));
    state = game.state;
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

  int get minesRemaining => state == 0 ? game.numMines - game.numFlags : 0;

  int get numTiles => game.rows * game.cols;
  Pair get boardDim => Pair(game.rows, game.cols);
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
