
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../global/global.dart';
import '../infoHandler/app_info.dart';
import '../models/trips_history_model.dart';
import '../widgets/history_design_ui.dart';

class TripsHistoryScreen extends StatefulWidget {
  const TripsHistoryScreen({super.key});

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTripHistory();
  }

  void fetchTripHistory() async {
    setState(() {
      isLoading = true;
    });

    Provider.of<AppInfo>(context, listen: false).clearTripHistory();

    DatabaseReference tripHistoryRef = FirebaseDatabase.instance
        .ref()
        .child("helpers")
        .child(firebaseAuth.currentUser!.uid)
        .child("tripsHistory");

    tripHistoryRef.once().then((DatabaseEvent databaseEvent) {
      DataSnapshot snapshot = databaseEvent.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> trips = snapshot.value as Map<dynamic, dynamic>;
        trips.forEach((key, value) {
          TripsHistoryModel trip = TripsHistoryModel.fromMap(value);

          if (!Provider.of<AppInfo>(context, listen: false)
              .allTripsHistoryInformationList
              .contains(trip) &&
              trip.status == "ended") {
            Provider.of<AppInfo>(context, listen: false)
                .updateOverAllTripsHistoryInformation(trip);
          }
        });
      }

      setState(() {
        isLoading = false;
      });
    }).catchError((error) {
      print("Error fetching trip history: $error");
      setState(() {
        isLoading = false;
      });
    });
  }

  void _clearTripHistory() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear History"),
        content: Text("Are you sure you want to clear all trip history?"),
        actions: [
          TextButton(child: Text("Cancel"), onPressed: () => Navigator.of(context).pop(false)),
          TextButton(child: Text("Clear"), onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );

    if (!confirm) return;

    setState(() {
      isLoading = true;
    });

    DatabaseReference tripHistoryRef = FirebaseDatabase.instance
        .ref()
        .child("helpers")
        .child(firebaseAuth.currentUser!.uid)
        .child("tripsHistory");

    try {
      await tripHistoryRef.remove();
      Provider.of<AppInfo>(context, listen: false).clearTripHistory();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Trip history cleared")),
      );
    } catch (e) {
      print("Error clearing trip history: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to clear trip history")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "History",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: darkTheme ? Colors.grey[900] : Colors.blueGrey[900],
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            tooltip: "Clear History",
            onPressed: _clearTripHistory,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Consumer<AppInfo>(
        builder: (context, appInfo, _) {
          if (appInfo.allTripsHistoryInformationList.isEmpty) {
            return Center(child: Text("No trip history available."));
          }
          return ListView.builder(
            itemCount: appInfo.allTripsHistoryInformationList.length,
            itemBuilder: (context, index) {
              TripsHistoryModel trip = appInfo.allTripsHistoryInformationList[index];
              return HistoryDesignUIWidget(tripsHistoryModel: trip);
            },
          );
        },
      ),
    );
  }
}
