import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

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
