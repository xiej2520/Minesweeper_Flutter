import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'scaling_config.dart';
import 'help_dialog.dart';
import 'naval_mine_icon.dart';
import 'game_model.dart';
import 'timer_model.dart';

class MinesweeperGame extends StatefulWidget {
  const MinesweeperGame({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MinesweeperGame> createState() => _MinesweeperGameState();
}

class _MinesweeperGameState extends State<MinesweeperGame> {
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

  Widget _buildTile(int index, ScaleConfig sc) {
    GameModel game = Provider.of<GameModel>(context, listen: false);
    Tile t = game.getTile(index);
    if (t.revealed) {
      if (t.minesNearby == -1) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.black,
          ),
          child: game.state == 1
              ? Icon(NavalMine.navalMine,
                  color: Colors.blueAccent, size: sc.iconSize)
              : Icon(NavalMine.navalMine, color: Colors.red, size: sc.iconSize),
        );
      } else {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.grey.shade900,
          ),
          child: Text(t.minesNearby.toString(),
              style: TextStyle(
                color: nearbyColorMap(t.minesNearby),
                fontSize: sc.tileFontSize,
                fontWeight: FontWeight.bold,
              )),
        );
      }
    } else {
      return GestureDetector(
        onSecondaryTap: () {
          game.flag(index);
        },
        onLongPress: () {
          game.flag(index);
        },
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.black,
            ),
            child: t.flagged
                ? IconButton(
                    padding: EdgeInsets.zero,
                    icon:
                        Icon(Icons.flag, color: Colors.red, size: sc.iconSize),
                    onPressed: () => {})
                : TextButton(
                    child: const Text(''), onPressed: () => game.click(index))),
      );
    }
  }

  Widget _buildBoard(BuildContext context, ScaleConfig sc) {
    GameModel game = context.watch<GameModel>();
    if (game.state == -1) {
      return Container(
          height: 400,
          width: 400,
          color: Colors.black,
          child: const Center(
            child: Text("Minesweeper",
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          ));
    } else if (game.state == 1 && !game.displayedEndMessage) {
      WidgetsBinding.instance.addPostFrameCallback((duration) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            'You won!',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          duration: Duration(days: 1),
        ));
        Provider.of<TimerService>(context, listen: false).stop();
      });
      game.displayedEndMessage = true;
    } else if (game.state == 2 && !game.displayedEndMessage) {
      WidgetsBinding.instance.addPostFrameCallback((duration) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            'You lost!',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          duration: Duration(days: 1),
        ));
        Provider.of<TimerService>(context, listen: false).stop();
      });
      game.displayedEndMessage = true;
    }
    return Container(
      width: sc.gridWidth,
      height: sc.gridHeight,
      color: Colors.black,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      child: GridView.count(
        crossAxisCount: game.boardDim.y,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        children: List.generate(game.numTiles, (index) {
          return _buildTile(index, sc);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    });
    var game = context.watch<GameModel>();
    ScaleConfig sc = ScaleConfig()..init(context);
    game.state == -1
        ? sc.recalculate(1, 1)
        : sc.recalculate(game.boardDim.x, game.boardDim.y);
    return Scaffold(
        appBar: AppBar(title: Text(widget.title), actions: [
          IconButton(
              hoverColor: Colors.blue,
              splashRadius: 28,
              tooltip: 'Help',
              onPressed: () {
                WidgetsBinding.instance
                    .addPostFrameCallback((duration) => showDialog(
                        context: context,
                        builder: (context) {
                          return const HelpDialog();
                        }));
              },
              icon: const Icon(Icons.help_outline)),
          const SizedBox(width: 5),
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
                _colsController.text = difficulties[d][1].toString();
                _minesController.text = difficulties[d][2].toString();
                setState(() {
                  dropdownValue = newValue;
                });
              }),
          const SizedBox(width: 5),
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
                if (value != '') {
                  if (int.parse(value) > 50) {
                    _rowsController.text = '50';
                  }
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
                if (value != '') {
                  if (int.parse(value) > 50) {
                    _colsController.text = '50';
                  }
                }
              },
            ),
          ),
          SizedBox(
            width: 50,
            child: TextFormField(
              controller: _minesController,
              decoration: const InputDecoration(
                labelText: 'Mines',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ),
          ),
          Builder(
              builder: (context) => IconButton(
                    icon: const Icon(Icons.add),
                    hoverColor: Colors.green,
                    splashRadius: 28,
                    tooltip: 'New Game',
                    onPressed: () {
                      if (_rowsController.text == '') {
                        _rowsController.text = '1';
                      }
                      if (_colsController.text == '') {
                        _colsController.text = '1';
                      }
                      if (_minesController.text == '') {
                        _minesController.text = '0';
                      }
                      int rows = int.parse(_rowsController.text);
                      int cols = int.parse(_colsController.text);
                      int mines = int.parse(_minesController.text);
                      if (rows * cols <= mines) {
                        mines = rows * cols - 1;
                        _minesController.text = mines.toString();
                      }

                      game.createGame(rows, cols, mines);
                      Provider.of<TimerService>(context, listen: false).reset();
                      Provider.of<TimerService>(context, listen: false).start();
                    },
                  )),
        ]),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                game.state != -1
                    ? Container(
                        color: Colors.blue,
                        alignment: Alignment.center,
                        width: 200,
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Text('Mines remaining: ${game.minesRemaining}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Consumer<TimerService>(
                                builder: (context, timer, child) {
                              return Text('${timer.elapsed.inSeconds}s',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold));
                            })
                          ],
                        ))
                    : const Text(''),
                _buildBoard(context, sc),
              ],
            ),
          ),
        ));
  }
}

Color nearbyColorMap(int nearbyMines) {
  switch (nearbyMines) {
    case 0:
      return Colors.greenAccent.shade700;
    case 1:
      return Colors.yellowAccent;
    case 2:
      return Colors.yellow.shade900;
    case 3:
      return Colors.redAccent.shade700;
    case 4:
      return Colors.pink.shade700;
    case 5:
      return Colors.deepPurpleAccent.shade700;
    case 6:
      return Colors.purpleAccent.shade700;
    case 7:
      return Colors.indigoAccent.shade400;
    case 8:
      return Colors.lightBlueAccent;
  }
  return Colors.white;
}
