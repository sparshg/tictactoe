import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'preferences.dart';
import 'board.dart';
import 'support.dart';
import 'package:rive/rive.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'package:provider/provider.dart';
import 'providermodel.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: green,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Preferences.init();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProviderModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Main(),
      ),
    );
  }
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  late ProviderModel _appProvider;
  var scoreX = 0;
  var scoreO = 0;
  var _selected = 2;
  var _on = 'Hard';
  var _ai = -1;
  var _prevAi = 0;
  bool _newAssets = false;
  var _timeout = false;
  final _difficulties = ['Easy', 'Medium', 'Hard', 'Impossible'];

  @override
  void initState() {
    final provider = Provider.of<ProviderModel>(context, listen: false);
    _appProvider = provider;

    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      initInApp(provider);
    });

    super.initState();
  }

  initInApp(provider) async {
    await provider.initInApp();
    if (provider.unlockAnims) {
      setState(() {
        _newAssets = (Preferences.getResource() ?? false);
      });
    }
  }

  @override
  void dispose() {
    _appProvider.subscription.cancel();
    super.dispose();
  }

  void resetScores() {
    if (!_timeout) {
      setState(() {
        scoreX = 0;
        scoreO = 0;
      });
    }
  }

  void changeAI(int to) {
    if (_on != 'Manual') {
      _ai = to;
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
                        } else {
                          _ai = _prevAi;
                        }
                        _on = _difficulties[_selected];
                      } else {
                        _on = s;
                        _prevAi = _ai;
                        _ai = 0;
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
            changeScore: (turn) => setState(() {
              turn == 1 ? scoreX++ : scoreO++;
              _timeout = true;
              Future.delayed(
                  const Duration(milliseconds: 1200), () => _timeout = false);
            }),
            difficulty: _on,
            newAssets: _newAssets,
            ai: _ai,
          ),
          const Spacer(),
          Row(children: [
            Expanded(
                child: Score(
                    score: scoreO,
                    type: 1,
                    reset: resetScores,
                    changeAI: changeAI,
                    ai: _ai == 1 ? true : false)),
            Expanded(
                child: Score(
                    score: scoreX,
                    type: -1,
                    reset: resetScores,
                    changeAI: changeAI,
                    ai: _ai == -1 ? true : false)),
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
                  label: const FittedBox(
                      child: Text("Open Issue", style: _buttonTextStyle1)),
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
                  label: const FittedBox(
                      child: Text("Animations", style: _buttonTextStyle2)),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            Support(animMode: (bool t) async {
                              await Preferences.setResource(t);
                              setState(() {
                                _newAssets = t;
                              });
                            }));
                  },
                  style: _buttonStyle2,
                ),
              ),
            ),
          ]),
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
  const Score(
      {Key? key,
      required this.score,
      required this.type,
      this.reset,
      this.changeAI,
      this.ai = false})
      : super(key: key);
  final int score;
  final int type;
  final bool ai;
  final VoidCallback? reset;
  final ValueChanged<int>? changeAI;

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
    final _text = Text(
      '${widget.score}',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: black,
      ),
    );
    if (widget.ai) {
      return Expanded(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            _text,
            const Positioned(
                left: 10,
                bottom: -10,
                child: Text(
                  "AI",
                  style: TextStyle(
                      fontFamily: 'Monospace',
                      color: black,
                      fontWeight: FontWeight.w600),
                )),
          ],
        ),
      );
    } else {
      return Expanded(child: _text);
    }
  }

  Widget icon() {
    return LimitedBox(
      maxHeight: 72,
      maxWidth: 72,
      child: RiveAnimation.asset(
        'images/art.riv',
        artboard: widget.type == 1 ? 'Circle' : 'Cross',
        onInit: (Artboard artboard) {
          final controller =
              StateMachineController.fromArtboard(artboard, 'StateMachine');
          artboard.addController(controller!);
          _draw = controller.findInput<bool>('Draw') as SMIBool;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.changeAI!(widget.type);
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
