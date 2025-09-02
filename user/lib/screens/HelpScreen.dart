import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  void _callSupport() async {
    const phoneNumber = '0766476848';
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            const Text(
              "Welcome to the Help & Support Center",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Here you'll find answers to frequently asked questions, instructions on how to use the app, troubleshooting tips, and contact information for support.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Payment Information
            const Text(
              "Payment Information",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.money, color: Colors.blueAccent),
              title: Text("Cash-Only Payments"),
              subtitle: Text("Currently, we only support cash payments. Please have the exact amount ready when the helper arrives."),
            ),
            const SizedBox(height: 20),

            // Frequently Asked Questions
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.help_outline, color: Colors.blueAccent),
              title: Text("How do I request assistance?"),
              subtitle: Text("Open the app, tap 'Request Help', and provide details."),
            ),
            const ListTile(
              leading: Icon(Icons.location_on, color: Colors.green),
              title: Text("How do I set my location accurately?"),
              subtitle: Text("Enable GPS, use precise location, and verify on the map."),
            ),
            const ListTile(
              leading: Icon(Icons.timer, color: Colors.orange),
              title: Text("How long will it take for help to arrive?"),
              subtitle: Text("Arrival times vary based on location and helper availability."),
            ),
            const ListTile(
              leading: Icon(Icons.contact_support, color: Colors.red),
              title: Text("How can I contact support?"),
              subtitle: Text("Call 0766476848 or email suresh68004@gmail.com."),
            ),
            const SizedBox(height: 20),

            // How to Use the App
            const Text(
              "How to Use the App",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.directions_car, color: Colors.blue),
              title: Text("Requesting Assistance"),
              subtitle: Text("To request assistance, tap the 'Request Vehicle' button on the home screen, select your location, and choose the type of help you need."),
            ),
            const ListTile(
              leading: Icon(Icons.payment, color: Colors.green),
              title: Text("Making Payments"),
              subtitle: Text("You can make payments using the payment methods available in the app. We currently support Stripe. Go to the 'Payment' section in the app settings to manage your payment options."),
            ),
            const ListTile(
              leading: Icon(Icons.history, color: Colors.purple),
              title: Text("How to Use Trip History"),
              subtitle: Text("You can view your past trips and payment history in the 'Trip History' section of the app."),
            ),
            const ListTile(
              leading: Icon(Icons.person, color: Colors.orange),
              title: Text("Managing Your Profile"),
              subtitle: Text("You can update your profile information, change your profile picture, and sign out in the 'Profile' section of the app."),
            ),
            const ListTile(
              leading: Icon(Icons.contact_support, color: Colors.orange),
              title: Text("Contacting Support"),
              subtitle: Text("If you need further assistance, you can contact our support team via the 'Contact Support' button or call us directly."),
            ),
            const SizedBox(height: 20),

            // Vehicle Types for Assistance
            const Text(
              "Vehicle Types for Assistance",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.local_shipping, color: Colors.orange),
              title: Text("Flatbed Truck"),
              subtitle: Text("For safe transport of cars, bikes, and light vehicles."),
            ),
            const ListTile(
              leading: Icon(Icons.directions_car, color: Colors.blue),
              title: Text("Wheel-Lift Truck"),
              subtitle: Text("For towing small to medium-sized vehicles."),
            ),
            const ListTile(
              leading: Icon(Icons.fire_truck, color: Colors.red),
              title: Text("Heavy Wrecker"),
              subtitle: Text("For towing large trucks, buses, and trailers."),
            ),
            const SizedBox(height: 20),

            // Troubleshooting Tips
            const Text(
              "Troubleshooting Tips",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.location_off, color: Colors.red),
              title: Text("Location Services Not Working"),
              subtitle: Text("Ensure that location services are enabled for the app in your device settings."),
            ),
            const ListTile(
              leading: Icon(Icons.payment, color: Colors.red),
              title: Text("Payment Failures"),
              subtitle: Text("Check your payment method details and ensure that you have sufficient funds."),
            ),
            const ListTile(
              leading: Icon(Icons.network_check, color: Colors.red),
              title: Text("Connectivity Issues"),
              subtitle: Text("Ensure you have a stable internet connection or switch to Wi-Fi."),
            ),
            const ListTile(
              leading: Icon(Icons.refresh, color: Colors.red),
              title: Text("App Freezes"),
              subtitle: Text("Close unnecessary apps, clear cache, or restart your device."),
            ),
            const ListTile(
              leading: Icon(Icons.warning, color: Colors.red),
              title: Text("Location Not Found"),
              subtitle: Text("Enable location services and ensure the app has permission to access your location."),
            ),
            const SizedBox(height: 20),

            // Contact Support Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _callSupport,
                icon: const Icon(Icons.call, color: Colors.white),
                label: const Text("Contact Support", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
