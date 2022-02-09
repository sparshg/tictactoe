import 'dart:developer';

import 'package:flutter/material.dart';

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
  late List<Tile> tiles;

  void reset(String text) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(text),
          );
        });
    Future.delayed(const Duration(seconds: 1), () {
      RestartWidget.restartApp(context);
    });
  }

  int updateBoard(int tag) {
    if (board[tag] == 0) {
      board[tag] += turn;
      log(board.toString());
      turn *= -1;

      for (var i in wins) {
        if (board[i[0]] + board[i[1]] + board[i[2]] == 3) {
          log(i.toString());
          reset("O Won");
          return 0;
        } else if (board[i[0]] + board[i[1]] + board[i[2]] == -3) {
          reset("X Won");
          return 0;
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
    final w = (MediaQuery.of(context).size.width - 2 * _padding) / 3;
    tiles = List.generate(9, (i) => Tile(tag: i, w: w, update: updateBoard));

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(_padding),
          child: Stack(alignment: AlignmentDirectional.center, children: [
            Image.asset('images/board.png'),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [tiles[0], tiles[1], tiles[2]],
                ),
                Row(
                  children: [tiles[3], tiles[4], tiles[5]],
                ),
                Row(
                  children: [tiles[6], tiles[7], tiles[8]],
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

class Tile extends StatefulWidget {
  final double w;
  final int tag;
  final int Function(int) update;

  const Tile(
      {Key? key, required this.w, required this.tag, required this.update})
      : super(key: key);

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
            _icon = out == 1
                ? Image.asset('images/cross.png')
                : Image.asset('images/circle.png');
          });
        },
        icon: _icon,
      ),
    );
  }
}
