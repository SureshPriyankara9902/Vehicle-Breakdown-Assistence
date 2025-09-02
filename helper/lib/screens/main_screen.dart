import 'package:flutter/material.dart';
import 'package:helper/global/global.dart';
import 'package:helper/splashScreen/splash_screen.dart';

import '../tabPages/earning_tab.dart';
import '../tabPages/home_tab.dart';
import '../tabPages/profile_tab.dart';
import '../tabPages/ratings_tab.dart';
import '../tabPages/contact_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {

  TabController? tabController;
  int selectedIndex = 0;

  onItemClicked (int index){
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      body:TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
           HomeTabPage(),
           EarningsTabPage(),
           RatingsTabPage(),
           ContactTab(),
           ProfileTabPage(),

        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
          items: [BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: "Earning"),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: "Ratings"),
            BottomNavigationBarItem(icon: Icon(Icons.contact_support), label: "Contact"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),

          ],
        unselectedItemColor: darkTheme? Colors.black54 : Colors.white54,
        selectedItemColor: darkTheme? Colors.black54 : Colors.white,
        backgroundColor: darkTheme? Colors.amber.shade400 : Colors.blueGrey[900],
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 14),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),

    );
  }
}
