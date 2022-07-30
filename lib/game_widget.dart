import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'naval_mine_icon.dart';
import 'game_model.dart';

class MinesweeperGame extends StatefulWidget {
  const MinesweeperGame({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MinesweeperGame> createState() => _MinesweeperGameState();
}

class _MinesweeperGameState extends State<MinesweeperGame> {
  int _inputRows = 8;
  int _inputCols = 8;
  int _inputMines = 10;
  final TextEditingController _rowsController = TextEditingController();
  final TextEditingController _colsController = TextEditingController();
  final TextEditingController _minesController = TextEditingController();
  String dropdownValue = 'Beginner';
  final List difficulties = [
    [8, 8, 10],
    [16, 16, 40],
    [30, 16, 99]
  ];

  @override
  void initState() {
    super.initState();
    _rowsController.text = '8';
    _colsController.text = '8';
    _minesController.text = '10';
  }

  Widget _buildTile(int index) {
    GameModel game = Provider.of<GameModel>(context, listen: false);
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
                    child: const Text(''), onPressed: () => game.click(index))),
      );
    }
  }

  Widget _buildBoard(BuildContext context) {
    GameModel game = context.watch<GameModel>();
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
          crossAxisCount: game.getBoardDims.y,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          padding: const EdgeInsets.all(5),
          children: List.generate(game.numTiles, (index) {
            return _buildTile(index);
          }),
        ),
      );
    } else if (game.state == 1) {
      WidgetsBinding.instance.addPostFrameCallback((duration) =>
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.black,
              content: Text(
                'You won!',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ))));
    } else if (game.state == 2) {
      WidgetsBinding.instance.addPostFrameCallback((duration) =>
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.black,
              content: Text(
                'You lost!',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ))));
    }
    return Container(
      width: 800,
      height: 800,
      color: Colors.black,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      child: GridView.count(
        crossAxisCount: game.getBoardDims.y,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        padding: const EdgeInsets.all(5),
        children: List.generate(game.numTiles, (index) {
          return _buildTile(index);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var game = context.watch<GameModel>();
    return Scaffold(
        appBar: AppBar(title: Text(widget.title), actions: [
          DropdownButton(
              value: dropdownValue,
              items: const [
                DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                DropdownMenuItem(
                    value: 'Intermediate', child: Text('Intermediate')),
                DropdownMenuItem(value: 'Expert', child: Text('Expert')),
              ],
              onChanged: (String? newValue) {
                dropdownValue = newValue!;
                int d = 0;
                if (newValue == 'Intermediate') {
                  d = 1;
                } else if (newValue == 'Expert') {
                  d = 2;
                }
                _rowsController.text = difficulties[d][0].toString();
                _inputRows = difficulties[d][0];
                _colsController.text = difficulties[d][1].toString();
                _inputCols = difficulties[d][1];
                _minesController.text = difficulties[d][2].toString();
                _inputMines = difficulties[d][2];
                setState(() {
                  dropdownValue = newValue;
                });
              }),
          SizedBox(
            width: 40,
            child: TextFormField(
              controller: _rowsController,
              decoration: const InputDecoration(
                labelText: 'Rows',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              onChanged: (value) {
                if (value == "") {
                  _rowsController.text = _inputRows.toString();
                } else {
                  _inputRows = int.parse(value);
                  if (_inputRows > 50) {
                    _inputRows = 50;
                    _rowsController.text = '50';
                  }
                  _fixMinesInput();
                }
              },
            ),
          ),
          SizedBox(
            width: 40,
            child: TextFormField(
              controller: _colsController,
              decoration: const InputDecoration(
                labelText: 'Cols',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              onChanged: (value) {
                if (value == "") {
                  _colsController.text = _inputCols.toString();
                } else {
                  _inputCols = int.parse(value);
                  if (_inputCols > 50) {
                    _inputCols = 50;
                    _colsController.text = '50';
                  }
                  _fixMinesInput();
                }
              },
            ),
          ),
          SizedBox(
            width: 40,
            child: TextFormField(
              controller: _minesController,
              decoration: const InputDecoration(
                labelText: 'Mines',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              onChanged: (value) {
                if (value == "") {
                  _minesController.text = _inputMines.toString();
                }
                _fixMinesInput();
              },
            ),
          ),
          Builder(
              builder: (context) => IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      game.createGame(_inputRows, _inputCols, _inputMines);
                    },
                    tooltip: 'New Game',
                  )),
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

  void _fixMinesInput() {
    if (_inputRows * _inputCols <= int.parse(_minesController.text)) {
      _minesController.text = (_inputRows * _inputCols - 1).toString();
    }
    _inputMines = int.parse(_minesController.text);
  }
}
