import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'AddRecordPage.dart';
import 'Assets.dart';
import 'Constants.dart';
import 'MyIcons.dart';
import 'Bill.dart';
import 'package:wallet/statistical/Statistical.dart';
import 'database/DBManager.dart';

void main() {
  runApp(MyApp());
  SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle (
    statusBarColor: Colors.transparent,
  );
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
}


class MyApp extends StatelessWidget {
  static const String _title = 'MyWallet';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white,
      ),
      home: LoadingPage(),
    );
  }
}


class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DBManager().completer.future.whenComplete((){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyWalletPage()),
      );
    });
    return new Container(
      color: Colors.cyan,
    );
  }

}

class MyWalletPage extends StatefulWidget {
  MyWalletPage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyWalletPageState createState() => _MyWalletPageState();
}

class _MyWalletPageState extends State<MyWalletPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if(index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddRecordPage()),
      );
      return;
    }
      setState(() {
        _selectedIndex = index;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: const Text('BottomNavigationBar Sample'),
//      ),
      body: _getBody(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(MyIcons.book),
            title: Text('账单'),
          ),
          BottomNavigationBarItem(
            icon: Icon(MyIcons.chart),
            title: Text('报表'),
          ),
          BottomNavigationBarItem(
            icon: Icon(MyIcons.add, color: Colors.white, ),
            title: Text(''),
          ),BottomNavigationBarItem(
            icon: Icon(MyIcons.card),
            title: Text('资产'),
          ),BottomNavigationBarItem(
            icon: Icon(MyIcons.person),
            title: Text('更多'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddRecordPage()),
            );
          },
      ),
      floatingActionButtonLocation: MyCenterButtonLocation(),//FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return Bill();
      case 1:
        return Statistical();
      case 3:
        return Assets();
//      case 3:
//        return _buildFourthPage(); // Create this function, it should return your fourth page as a widget
    }

    return Center(child: Text("There is no page builder for this index."),);
  }
}
