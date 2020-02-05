import 'package:flutter/material.dart';
import 'AddRecordPage.dart';
import 'Assets.dart';
import 'MyIcons.dart';
import 'bill.dart';
import 'database/DBManager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const String _title = 'MyWallet';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    DBManager();
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyWalletPage(),
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
    if(index == 2) return;
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
            icon: Icon(MyIcons.add, color: Colors.white,),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return Bill(); // Create this function, it should return your first page as a widget
      case 3:
        return Assets(); // Create this function, it should return your second page as a widget
//      case 2:
//        return _buildThirdPage(); // Create this function, it should return your third page as a widget
//      case 3:
//        return _buildFourthPage(); // Create this function, it should return your fourth page as a widget
    }

    return Center(child: Text("There is no page builder for this index."),);
  }
}
