import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'board.dart';
import 'package:rive/rive.dart';
import 'package:flutter/services.dart';

const Color green = Color(0xFF57BAAC);
const Color lighterGreen = Color.fromARGB(255, 78, 170, 156);
const Color darkGreen = Color(0xFF4A9F92);
const Color darkerGreen = Color.fromARGB(255, 60, 128, 117);
const Color black = Color(0xFF545454);
const Color white = Color(0xFFF2EBD5);

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'TicTacToe',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const Main(),
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
  var _selected = 0;
  var _on = 'Easy';
  var _timeout = false;
  final _difficulties = ['Easy', 'Medium', 'Hard', 'Impossible'];

  void resetScores() {
    if (!_timeout) {
      setState(() {
        scoreX = 0;
        scoreO = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (scoreX > 4 || scoreO > 4) {
      Future.delayed(const Duration(milliseconds: 1200), resetScores);
    }

    const Widget title = Text(
      "TIC  TAC  TOE",
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: black,
      ),
    );

    const _buttonTextStyle1 = TextStyle(
      fontFamily: 'Monospace',
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: black,
    );
    const _buttonTextStyle2 = TextStyle(
      fontFamily: 'Monospace',
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: white,
    );
    final _buttonStyle1 = ElevatedButton.styleFrom(
      onPrimary: darkerGreen,
      primary: green,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.all(16),
      side: const BorderSide(
        width: 5.0,
        color: black,
      ),
    );
    final _buttonStyle2 = ElevatedButton.styleFrom(
      primary: black,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.all(16),
    );
    final _deselectedStyle = ElevatedButton.styleFrom(
      onPrimary: darkerGreen,
      primary: green,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.all(12),
      side: const BorderSide(
        width: 4.0,
        color: black,
      ),
    );
    final _selectedStyle = ElevatedButton.styleFrom(
      primary: black,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.all(12),
    );

    Widget difficultyRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['Manual', _difficulties[_selected]]
          .map(
            (String s) => Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: ElevatedButton(
                  child: Text(
                    s,
                    style: s == _on ? _buttonTextStyle2 : _buttonTextStyle1,
                  ),
                  onPressed: () {
                    setState(() {
                      if (s != 'Manual') {
                        if (_on != 'Manual') {
                          _selected = (_selected + 1) % 4;
                        }
                        _on = _difficulties[_selected];
                      } else {
                        _on = s;
                      }
                    });
                  },
                  style: s == _on ? _selectedStyle : _deselectedStyle,
                ),
              ),
            ),
          )
          .toList(),
    );

    return Scaffold(
      backgroundColor: green,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // const SizedBox(height: 10),
          const Spacer(),
          title,
          difficultyRow,
          const Spacer(),
          Board(
            changeScore: (i) => setState(() {
              i == 1 ? scoreX++ : scoreO++;
              _timeout = true;
              Future.delayed(
                  const Duration(milliseconds: 1200), () => _timeout = false);
            }),
            difficulty: _on,
          ),
          const Spacer(),
          Row(children: [
            Expanded(child: Score(score: scoreO, type: 0, reset: resetScores)),
            Expanded(child: Score(score: scoreX, type: 1, reset: resetScores)),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: ElevatedButton.icon(
                  icon: const ImageIcon(
                    AssetImage('images/github.png'),
                    color: black,
                  ),
                  label: const Text("Open Issue", style: _buttonTextStyle1),
                  onPressed: _launchURL,
                  style: _buttonStyle1,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.mode_edit_outline_outlined),
                  label: const Text("Animations", style: _buttonTextStyle2),
                  onPressed: () {},
                  style: _buttonStyle2,
                ),
              ),
            ),
          ]),
          // const Spacer(),
        ],
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
  const Score({Key? key, required this.score, required this.type, this.reset})
      : super(key: key);
  final int score;
  final int type;
  final VoidCallback? reset;

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
    if (widget.score != _score) {
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

  Widget icon() => LimitedBox(
        maxHeight: 72,
        maxWidth: 72,
        child: RiveAnimation.asset(
          'images/art.riv',
          artboard: widget.type == 1 ? 'Cross' : 'Circle',
          onInit: (Artboard artboard) {
            final controller =
                StateMachineController.fromArtboard(artboard, 'StateMachine');
            artboard.addController(controller!);
            _draw = controller.findInput<bool>('Draw') as SMIBool;
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        tapEffect();
        widget.reset!();
      },
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
          children: [scoreText(), icon()],
        ),
      ),
    );
  }
}
