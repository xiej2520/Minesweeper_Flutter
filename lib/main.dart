import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import 'game_model.dart';
import 'naval_mine_icon.dart';

void main() {
  html.document.onContextMenu.listen((evt) => evt.preventDefault());
  runApp(ChangeNotifierProvider(
      create: (context) => GameModel(), child: const App()));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minesweeper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MinesweeperGame(title: 'Minesweeper'),
    );
  }
}

class MinesweeperGame extends StatefulWidget {
  const MinesweeperGame({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MinesweeperGame> createState() => _MinesweeperGameState();
}

class _MinesweeperGameState extends State<MinesweeperGame> {
  Widget _buildTile(int index) {
    var game = context.watch<GameModel>();
    Tile t = game.getTile(index);
    if (t.revealed) {
      if (t.minesNearby == -1) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.black,
          ),
          child: game.state == 1
              ? const Icon(NavalMine.navalMine,
                  color: Colors.blueAccent, size: 48)
              : const Icon(NavalMine.navalMine, color: Colors.red, size: 48),
        );
      } else {
        return Container(
          width: 100,
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.grey.shade900,
          ),
          child: Text(t.minesNearby.toString(),
              style: TextStyle(
                color: nearbyColorMap(t.minesNearby),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              )),
        );
      }
    } else {
      return Listener(
        onPointerDown: (PointerDownEvent event) {
          if (event.buttons == kSecondaryMouseButton) {
            game.flag(index);
          }
        },
        child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.black,
            ),
            child: t.flagged
                ? IconButton(
                    icon: const Icon(Icons.flag, color: Colors.red, size: 48),
                    onPressed: () => {})
                : TextButton(
                    child: const Text(''),
                    onPressed: () => {
                          game.click(index),
                        })),
      );
    }
  }

  Widget _buildBoard(BuildContext context) {
    var game = context.watch<GameModel>();
    if (game.state == -1) {
      return Container(
        height: 400,
        width: 400,
        color: Colors.black,
      );
    } else if (game.state == 0) {
      return Container(
        width: 800,
        height: 800,
        color: Colors.black,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        child: GridView.count(
          crossAxisCount: game.getBoardDims.x,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          padding: const EdgeInsets.all(5),
          children: List.generate(game.numTiles, (index) {
            return _buildTile(index);
          }),
        ),
      );
    } else if (game.state == 1) {
      /*
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        'You lost!',
        style: TextStyle(color: Colors.red),
      )));
      */

      return Container(
        width: 800,
        height: 800,
        color: Colors.black,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        child: GridView.count(
          crossAxisCount: game.getBoardDims.x,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          padding: const EdgeInsets.all(5),
          children: List.generate(game.numTiles, (index) {
            return _buildTile(index);
          }),
        ),
      );
    } else if (game.state == 2) {
      /*
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        'You won!',
        style: TextStyle(color: Colors.green),
      )));
      */

      return Container(
        width: 800,
        height: 800,
        color: Colors.black,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        child: GridView.count(
          crossAxisCount: game.getBoardDims.x,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          children: List.generate(game.numTiles, (index) {
            return _buildTile(index);
          }),
        ),
      );
    }
    return Container(
      height: 400,
      width: 400,
      color: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    var game = context.watch<GameModel>();
    return Scaffold(
        appBar: AppBar(title: Text(widget.title), actions: [
          Builder(
              builder: (context) => IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => game.createGame(10, 10, 40),
                    tooltip: 'New Game',
                  ))
        ]),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildBoard(context),
              ],
            ),
          ),
        ));
  }
}
