import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'tile.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'TicTacToe',
      home: Main(),
    );
  }
}

class Main extends StatelessWidget {
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Widget title = Text(
      "TIC TAC TOE",
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Color(0xFF545454),
      ),
    );
    const Widget winner = Text(
      "winner",
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: Color(0xFF545454),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xff57baac),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          title,
          SizedBox.square(dimension: 60),
          Board(),
          SizedBox.square(dimension: 30),
          winner
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

class Board extends StatefulWidget {
  const Board({Key? key}) : super(key: key);

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
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
  var board = List.filled(9, 0);
  var turn = 1;
  var winner = '';
  var activated = true;
  late List<Tile> tiles;
  SMITrigger? _redraw;

  void reset(String text) {
    activated = false;
    setState(() => winner = text);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _redraw?.fire());
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
    const _padding = 20.0;
    final double width =
        min(MediaQuery.of(context).size.width - 2 * _padding, 590);
    tiles = List.generate(
        9, (i) => Tile(tag: i, w: width / 3, update: updateBoard));

    final frame = LimitedBox(
      maxHeight: width,
      child: RiveAnimation.asset(
        'images/art.riv',
        artboard: 'Board',
        onInit: (Artboard artboard) {
          final controller =
              StateMachineController.fromArtboard(artboard, 'StateMachine');
          artboard.addController(controller!);
          _redraw = controller.findInput<bool>('Reset') as SMITrigger;
        },
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(_padding),
      child: Stack(alignment: AlignmentDirectional.center, children: [
        frame,
        generateTiles(),
      ]),
    );
  }

  Widget generateTiles() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (i) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (j) => tiles[j + 3 * i]),
        ),
      ),
    );
  }
}
