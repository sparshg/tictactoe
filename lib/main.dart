import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'board.dart';
import 'package:rive/rive.dart';

const Color green = Color(0xFF57BAAC);
const Color lighterGreen = Color.fromARGB(255, 78, 170, 156);
const Color darkGreen = Color(0xFF4A9F92);
const Color darkerGreen = Color.fromARGB(255, 60, 128, 117);
const Color black = Color(0xFF545454);

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

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  var scoreX = 0;
  var scoreO = 0;
  @override
  Widget build(BuildContext context) {
    const Widget title = Text(
      "TIC  TAC  TOE",
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: black,
      ),
    );

    return Scaffold(
      backgroundColor: green,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          title,
          Board(
              changeScore: (i) => setState(() => i == 1 ? scoreX++ : scoreO++)),
          Row(children: [
            Expanded(child: Score(score: scoreO, type: 0)),
            Expanded(child: Score(score: scoreX, type: 1)),
          ])
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _launchURL,
        backgroundColor: green,
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

class Score extends StatefulWidget {
  const Score({Key? key, required this.score, required this.type})
      : super(key: key);
  final int score;
  final int type;

  @override
  State<Score> createState() => _ScoreState();
}

class _ScoreState extends State<Score> {
  SMIBool? _draw;
  var _score = 0;

  void tapEffect() {
    _draw?.change(false);
    Future.delayed(
        const Duration(milliseconds: 450), () => _draw?.change(true));
  }

  Widget scoreText() {
    if (widget.score > _score) {
      tapEffect();
      _score = widget.score;
    }
    return Expanded(
      child: Text(
        '${widget.score}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.bold,
          color: black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tapEffect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          color: lighterGreen,
          borderRadius: BorderRadius.all(Radius.circular(24)),
          boxShadow: [
            BoxShadow(color: darkerGreen, offset: Offset(3, 3), blurRadius: 8)
          ],
        ),
        child: Row(
          children: [
            scoreText(),
            LimitedBox(
              maxHeight: 72,
              maxWidth: 72,
              child: RiveAnimation.asset(
                'images/art.riv',
                artboard: widget.type == 1 ? 'Cross' : 'Circle',
                onInit: (Artboard artboard) {
                  final controller = StateMachineController.fromArtboard(
                      artboard, 'StateMachine');
                  artboard.addController(controller!);
                  _draw = controller.findInput<bool>('Draw') as SMIBool;
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
