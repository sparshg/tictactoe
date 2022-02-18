import 'package:flutter/material.dart';
import 'tile.dart';
import 'dart:math';
import 'package:rive/rive.dart';

class Board extends StatefulWidget {
  const Board({Key? key, this.changeScore, required this.difficulty})
      : super(key: key);
  final ValueChanged<int>? changeScore;
  final String difficulty;

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
  final winpos = [
    [0, -1, -pi / 2],
    [0, 0, pi / 2],
    [0, 1, pi / 2],
    [-1, 0, 0],
    [0, 0, 0],
    [1, 0, 0],
    [0, 0, -pi / 4],
    [0, 0, pi / 4],
  ];
  var winmark = 0;
  var board = List.filled(9, 0);
  var turn = 1;
  var winner = '';
  var activated = true;
  var disabled = false;
  var restart = false;
  var mark = false;
  late List<Tile> tiles;
  SMITrigger? _redraw;
  late RiveAnimationController _controllerB, _controllerW;

  @override
  void initState() {
    super.initState();
    _controllerB = OneShotAnimation('Black', onStop: reset);
    _controllerW = OneShotAnimation('White', onStop: reset);
  }

  void reset() => setState(() => restart = true);

  int minimax(List<int> board, int a, int b, bool isMaximizingPlayer) {
    final score = getScore(board);
    if (score < 2) {
      return score;
    }

    if (isMaximizingPlayer) {
      var bestVal = -100000;
      for (var i = 0; i < 9; i++) {
        if (board[i] == 0) {
          board[i]++;
          final eval = minimax(board, a, b, false);
          bestVal = max(bestVal, eval);
          a = max(a, eval);
          board[i] = 0;
          if (b <= a) {
            break;
          }
        }
      }
      return bestVal;
    } else {
      var bestVal = 100000;
      for (var i = 0; i < 9; i++) {
        if (board[i] == 0) {
          board[i]--;
          final eval = minimax(board, a, b, true);
          bestVal = min(bestVal, eval);
          b = min(b, eval);
          board[i] = 0;
          if (b <= a) {
            break;
          }
        }
      }
      return bestVal;
    }
  }

  void spawnMark(String text, {bool tie = false}) {
    activated = false;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!tie) {
        widget.changeScore!(turn);
        setState(() => mark = true);
      } else {
        reset();
      }
    });
  }

  int getScore(List<int> board) {
    for (var i in wins) {
      if (board[i[0]] + board[i[1]] + board[i[2]] == 3) {
        return 1;
      } else if (board[i[0]] + board[i[1]] + board[i[2]] == -3) {
        return -1;
      }
    }
    if (!board.contains(0)) {
      return 0;
    }
    return 2;
  }

  void updateBoard(int tag) {
    if (board[tag] == 0 && activated) {
      setState(() {
        board[tag] += turn;
        turn *= -1;
        for (var i in wins) {
          if (board[i[0]] + board[i[1]] + board[i[2]] == 3) {
            winmark = wins.indexOf(i);
            spawnMark("O Won");
            return;
          } else if (board[i[0]] + board[i[1]] + board[i[2]] == -3) {
            winmark = wins.indexOf(i);
            spawnMark("X Won");
            return;
          }
        }
        if (!board.contains(0)) {
          spawnMark("Tie", tie: true);
          return;
        }
        if (widget.difficulty != 'Manual' && turn == -1) {
          var bestPlace = 0;
          var bestScore = 100000;
          for (var i = 0; i < 9; i++) {
            if (board[i] == 0) {
              final rand = Random().nextInt(100);
              if (widget.difficulty == 'Easy') {
                if (rand < 30) {
                  bestPlace = i;
                  break;
                }
              } else if (widget.difficulty == 'Medium') {
                if (rand < 20) {
                  bestPlace = i;
                  break;
                }
              } else if (widget.difficulty == 'Hard') {
                if (rand < 10) {
                  bestPlace = i;
                  break;
                }
              }
              board[i]--;
              final result =
                  minimax(List<int>.from(board), -100000, 100000, true);
              board[i] = 0;
              if (bestScore > result) {
                bestScore = result;
                bestPlace = i;
              }
            }
          }
          disabled = true;
          Future.delayed(const Duration(milliseconds: 600), () {
            updateBoard(bestPlace);
            disabled = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const _padding = 20.0;
    final double width = min(MediaQuery.of(context).size.width - 2 * _padding,
        MediaQuery.of(context).size.height * 9 / 16);
    tiles = List.generate(
      9,
      (i) => Tile(
        tag: i,
        w: width / 3,
        state: board[i],
        update: (tag) {
          if (!disabled) {
            updateBoard(tag);
          }
        },
        reset: restart,
      ),
    );

    if (restart) {
      restart = false;
      board = List.filled(9, 0);
      turn = 1;
      _redraw?.fire();
      activated = true;
    }

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
        if (mark) markOnWin(width),
        generateTiles(),
      ]),
    );
  }

  Widget markOnWin(width) {
    mark = false;
    return Transform.translate(
      offset: Offset(
          width / 3 * winpos[winmark][0], width / 3 * winpos[winmark][1]),
      child: Transform.rotate(
        angle: winpos[winmark][2].toDouble(),
        child: LimitedBox(
          maxHeight: width,
          child: RiveAnimation.asset(
            'images/art.riv',
            artboard: 'Mark',
            controllers: [turn == 1 ? _controllerB : _controllerW],
          ),
        ),
      ),
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
