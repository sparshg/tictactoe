import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class Tile extends StatefulWidget {
  const Tile({
    Key? key,
    required this.tag,
    required this.w,
    required this.state,
    required this.update,
    required this.reset,
  }) : super(key: key);

  final double w;
  final int tag;
  final int state;
  final ValueChanged<int> update;
  final bool reset;

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  SMIBool? _draw;

  void _riveInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, 'StateMachine');
    artboard.addController(controller!);
    _draw = controller.findInput<bool>('Draw') as SMIBool;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.w,
      height: widget.w,
      child: IconButton(
        onPressed: () {
          widget.update(widget.tag);
          _draw?.change(true);
        },
        icon: getIcon(),
      ),
    );
  }

  Widget getIcon() {
    switch (widget.state) {
      case 1:
        if (widget.reset) {
          _draw?.change(false);
        }
        return RiveAnimation.asset(
          'images/art.riv',
          artboard: 'Circle',
          onInit: _riveInit,
        );
      case -1:
        if (widget.reset) {
          _draw?.change(false);
        }
        return RiveAnimation.asset(
          'images/art.riv',
          artboard: 'Cross',
          onInit: _riveInit,
        );
      default:
        return Container();
    }
  }
}
