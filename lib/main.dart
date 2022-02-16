import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(
    const RestartWidget(
      child: MyApp(),
    ),
  );
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'TicTacToe',
      home: Board(),
    );
  }
}

class Board extends StatefulWidget {
  const Board({Key? key}) : super(key: key);

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  final _padding = 20.0;
  final wins = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
  ];
  var board = [0, 0, 0, 0, 0, 0, 0, 0, 0];
  var turn = 1;
  var winner = '';
  var activated = true;
  late List<Tile> tiles;

  void reset(String text) {
    activated = false;
    setState(() => winner = text);
    Future.delayed(const Duration(seconds: 1), () {
      RestartWidget.restartApp(context);
    });
  }

  int updateBoard(int tag) {
    if (board[tag] == 0 && activated) {
      board[tag] += turn;
      turn *= -1;

      for (var i in wins) {
        if (board[i[0]] + board[i[1]] + board[i[2]] == 3) {
          reset("O Won");
          return turn;
        } else if (board[i[0]] + board[i[1]] + board[i[2]] == -3) {
          reset("X Won");
          return turn;
        }
      }
      if (!board.contains(0)) {
        reset("Tie");
      }
      return turn;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final double width =
        min(MediaQuery.of(context).size.width - 2 * _padding, 590);
    tiles = List.generate(
        9, (i) => Tile(tag: i, w: width / 3, update: updateBoard));

    return Scaffold(
      backgroundColor: const Color(0xff57baac),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("TIC TAC TOE",
              style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF545454))),
          const SizedBox.square(dimension: 60),
          Padding(
            padding: EdgeInsets.all(_padding),
            child: Stack(alignment: AlignmentDirectional.center, children: [
              LimitedBox(
                maxHeight: width,
                child: const RiveAnimation.asset(
                  'images/art.riv',
                  artboard: 'Board',
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (j) => tiles[j + 3 * i]),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox.square(dimension: 30),
          Text(winner,
              style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF545454))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _launchURL,
        backgroundColor: const Color(0xff57baac),
        child: Image.asset('images/github.png'),
      ),
    );
  }

  _launchURL() async {
    const url = 'https://github.com/sparshg/tictactoe';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class Tile extends StatefulWidget {
  const Tile(
      {Key? key, required this.w, required this.tag, required this.update})
      : super(key: key);

  final double w;
  final int tag;
  final int Function(int) update;

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  Widget _icon = Container();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.w,
      height: widget.w,
      child: IconButton(
        onPressed: () {
          setState(() {
            final out = widget.update(widget.tag);
            if (out == 1) {
              _icon = const RiveAnimation.asset(
                'images/art.riv',
                artboard: 'Cross',
              );
            } else if (out == -1) {
              _icon = const RiveAnimation.asset(
                'images/art.riv',
                artboard: 'Circle',
              );
            }
          });
        },
        icon: _icon,
      ),
    );
  }
}
