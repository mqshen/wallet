import 'package:flutter/material.dart';

typedef KeyboardCallback(int key);

class NumericalKeyboard extends StatelessWidget {
  const NumericalKeyboard({Key key, this.onKeyPressed}) : super(key: key);

  static const backspaceKey = 42;
  static const addKey = 43;
  static const minusKey = 44;
  static const pointKey = 45;
  static const confirmKey = 46;
  static const clearKey = 69;

  final KeyboardCallback onKeyPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: Table(
        defaultColumnWidth: IntrinsicColumnWidth(flex: 1.0),
        border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey[300]),
            verticalInside: BorderSide(color: Colors.grey[300])
        ),
        children: [
          TableRow(
            children: [
              _buildNumberKey(7),
              _buildNumberKey(8),
              _buildNumberKey(9),
              _buildKey(Icon(Icons.backspace), backspaceKey),
            ],
          ),
          TableRow(
            children: [
              _buildNumberKey(4),
              _buildNumberKey(5),
              _buildNumberKey(6),
              _buildKey(Icon(Icons.add), addKey),
            ],
          ),
          TableRow(
            children: [
              _buildNumberKey(1),
              _buildNumberKey(2),
              _buildNumberKey(3),
              _buildKey(Icon(Icons.remove), minusKey),
            ],
          ),
          TableRow(
            children: [
              _buildKey(Text('C'), clearKey),
              _buildNumberKey(0),
              _buildKey(Text('.'), pointKey),
              _buildKey(Text('确定'), confirmKey),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildNumberKey(int n) {
    return _buildKey(Text('$n'), n);
  }

  Widget _buildKey(Widget icon, int key) {
    return IconButton(
      icon: icon,
      padding: EdgeInsets.all(16.0),
      onPressed: () => onKeyPressed(key),
    );
  }
}