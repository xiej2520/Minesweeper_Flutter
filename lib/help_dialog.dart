import 'package:flutter/material.dart';
import 'package:minesweeper/naval_mine_icon.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Help'),
        content: const Text.rich(TextSpan(children: [
          TextSpan(
              text: 'Left-click',
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' or '),
          TextSpan(text: 'tap', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' to clear a tile.\n'),
          TextSpan(
              text: 'Right-click',
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' or '),
          TextSpan(
              text: 'long-press',
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' to toggle a flag'),
          WidgetSpan(child: Icon(Icons.flag, color: Colors.red)),
          TextSpan(text: '.\n'),
          TextSpan(text: 'The game ends when '),
          TextSpan(
              text: 'all tiles have been cleared',
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          TextSpan(text: ' or when '),
          TextSpan(
              text: 'the player hits a mine',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          WidgetSpan(child: Icon(NavalMine.navalMine, color: Colors.red)),
          TextSpan(text: '.\n\n'),
          TextSpan(
              text: 'Not all minefields can be cleared without guessing.\n\n',
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: 'The size of the board and the number of mines '),
          TextSpan(text: 'can be customized.'),
        ])),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'))
        ]);
  }
}
