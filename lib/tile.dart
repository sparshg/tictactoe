import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class Tile extends StatefulWidget {
  const Tile({
    Key? key,
    required this.tag,
    required this.w,
    required this.state,
    required this.update,
    required this.restart,
  }) : super(key: key);

  final double w;
  final int tag;
  final int state;
  final ValueChanged<int> update;
  final bool restart;

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
        },
        icon: getIcon(),
      ),
    );
  }

  Widget getIcon() {
    final String _image;
    if (_draw?.value == false) {
      _draw?.change(true);
      return Container();
    }
    switch (widget.state) {
      case 1:
        _image = 'Circle';
        break;
      case -1:
        _image = 'Cross';
        break;
      default:
        return Container();
    }
    if (widget.restart) {
      _draw?.change(false);
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {});
      });
    }
    return RiveAnimation.asset(
      'images/art.riv',
      artboard: _image,
      onInit: _riveInit,
    );
  }
}
