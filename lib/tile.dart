import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class Tile extends StatelessWidget {
  Tile(
      {Key? key,
      required this.tag,
      required this.w,
      required this.state,
      required this.update})
      : super(key: key);

  final double w;
  final int tag;
  final int state;
  final ValueChanged<int> update;
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
      width: w,
      height: w,
      child: IconButton(
        onPressed: () => update(tag),
        icon: getIcon(),
      ),
    );
  }

  Widget getIcon() {
    switch (state) {
      case 1:
        return RiveAnimation.asset(
          'images/art.riv',
          artboard: 'Circle',
          onInit: _riveInit,
        );
      case -1:
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
