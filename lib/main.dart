import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_model.dart';
import 'game_widget.dart';
import 'package:universal_html/html.dart' as html;

void main() {
  runApp(const App());
  if (kIsWeb) {
    html.document.body!
        .addEventListener('contextmenu', (event) => event.preventDefault());
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Minesweeper',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.green,
        ),
        home: ChangeNotifierProvider(
            create: (context) => GameModel(),
            child: const MinesweeperGame(title: 'Minesweeper')));
  }
}
