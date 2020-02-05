import 'package:flutter/material.dart';

class ButtonGroup extends StatefulWidget {

  final List<String> titles;
  final ValueChanged<int> onTab;
  final Color color;
  final Color secondaryColor;
  int current;

  ButtonGroup({
    Key key,
    this.titles,
    this.onTab,
    this.color,
    this.secondaryColor,
    this.current,
  }):super(key: key);

  @override
  State<StatefulWidget> createState() => _ButtonGroup();

}

class _ButtonGroup extends State<ButtonGroup>{
  static const double _radius = 10.0;
  //static const double _outerPadding = 2.0;

//  final List<String> titles;
//  final ValueChanged<int> onTab;
//  final Color color;
//  final Color secondaryColor;
//
  _ButtonGroup({
    Key key,
  });


  @override
  void initState() {
    super.initState();
    widget.current = widget.current ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return ButtonBar(
        alignment: MainAxisAlignment.center,
        buttonPadding: EdgeInsets.all(0),
        children: _buttonList()
    );
  }

  List<Widget> _buttonList() {
    final buttons = <Widget>[];
    buttons.add(RaisedButton(
      onPressed: () => doPress(0),
      color: ( 0 == widget.current ) ? widget.color : widget.secondaryColor,
      child: Text(widget.titles.first,
          style: TextStyle(color: ( 0 == widget.current ) ? widget.secondaryColor : widget.color)
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(_radius),
            topLeft: Radius.circular(_radius)),
      ),
    ));
    if(widget.titles.length > 2) {
      for (int i = 1; i < widget.titles.length - 1; i++) {
        buttons.add(_button(widget.titles[i], i));
      }
    }
    buttons.add(RaisedButton(
      onPressed: () => doPress(widget.titles.length - 1),
      color: (widget.titles.length - 1  == widget.current ) ? widget.color : widget.secondaryColor,
      child: Text(widget.titles.last,
          style: TextStyle(color: ( widget.titles.length - 1  == widget.current ) ? widget.secondaryColor : widget.color)
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      // color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(_radius),
            topRight: Radius.circular(_radius)),
      ),
    ));
    return buttons;
  }

  Widget _button(String title, int index) {
    return RaisedButton(
      onPressed: () => doPress(index),
      color: ( index == widget.current ) ? widget.color : widget.secondaryColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Text(title,
          style: TextStyle(color: ( index == widget.current ) ? widget.secondaryColor : widget.color)
      ),
      shape: Border(
        top: BorderSide(color: Colors.grey),
        bottom: BorderSide(color: Colors.grey),
      ),
    );
  }

  void doPress(int index) {
    setState(() {
      widget.current = index;
    });
    if (widget.onTab != null) widget.onTab(index);
  }
}