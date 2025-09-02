// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:user/widgets/history_design_ui.dart';
//
// import '../infoHandler/app_info.dart';
//
// class TripsHistoryScreen extends StatefulWidget {
//   const TripsHistoryScreen({super.key});
//
//   @override
//   State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
// }
//
// class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
//   @override
//   Widget build(BuildContext context) {
//
//     bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
//     return Scaffold(
//       backgroundColor: darkTheme? Colors.black : Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: darkTheme? Colors.black : Colors.blueGrey[900],
//         title:Text(
//           "History",
//           style: TextStyle(
//             color : darkTheme? Colors.black : Colors.white,
//           ),
//         ),
//
//         leading: IconButton(
//           icon: Icon(Icons.close, color: darkTheme ? Colors.amber.shade400 : Colors.white),
//           onPressed: (){
//             Navigator.pop(context);
//           },
//         ),
//
//         centerTitle: true,
//         elevation: 0,
//       ),
//
//       body: Padding(
//         padding: EdgeInsets.all(10),
//         child: ListView.separated(
//             itemBuilder: (context,i){
//               return Card(
//                 color: darkTheme ? Colors.black : Colors.grey[100],
//                 shadowColor: Colors.transparent,
//                 child: HistoryDesignUIWidget(
//                   tripsHistoryModel: Provider.of<AppInfo>(context, listen:false).allTripsHistoryInformationList[i],
//                 ),
//               );
//
//         },
//             separatorBuilder: (context,i) => SizedBox(height: 30,),
//             itemCount: Provider.of<AppInfo>(context, listen:false).allTripsHistoryInformationList.length,
//             physics: ClampingScrollPhysics(),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user/widgets/history_design_ui.dart';
import '../infoHandler/app_info.dart';

class TripsHistoryScreen extends StatefulWidget {
  const TripsHistoryScreen({super.key});

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  Future<void> _refreshTrips() async {
    // You can add any refresh logic here if needed
    // For now, we'll just force a rebuild
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: darkTheme ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: darkTheme ? Colors.black : Colors.blueGrey[900],
        title: Text(
          "History",
          style: TextStyle(
            color: darkTheme ? Colors.black : Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: darkTheme ? Colors.amber.shade400 : Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: darkTheme ? Colors.amber.shade400 : Colors.white),
            tooltip: "Refresh",
            onPressed: _refreshTrips,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: darkTheme ? Colors.yellowAccent : Colors.white),
            tooltip: "Clear History",
            onPressed: () {
              _showClearConfirmationDialog(context);
            },
          ),
        ],
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<AppInfo>(
        builder: (context, appInfo, child) {
          final tripList = appInfo.allTripsHistoryInformationList;
          if (tripList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshTrips,
              child: Center(
                child: Text(
                  "No trip history available.",
                  style: TextStyle(color: darkTheme ? Colors.white : Colors.black),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refreshTrips,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.separated(
                itemBuilder: (context, i) {
                  return Card(
                    color: darkTheme ? Colors.black : Colors.grey[100],
                    shadowColor: Colors.transparent,
                    child: HistoryDesignUIWidget(
                      tripsHistoryModel: tripList[i],
                    ),
                  );
                },
                separatorBuilder: (context, i) => const SizedBox(height: 30),
                itemCount: tripList.length,
                physics: const AlwaysScrollableScrollPhysics(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showClearConfirmationDialog(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkTheme ? Colors.grey[900] : Colors.white,
        title: Text("Clear History", style: TextStyle(color: darkTheme ? Colors.white : Colors.black)),
        content: Text("Are you sure you want to clear all trip history?", style: TextStyle(color: darkTheme ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AppInfo>(context, listen: false).clearTripHistory();
              Navigator.pop(ctx);
              setState(() {}); // Refresh UI
            },
            child: Text("Clear", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}