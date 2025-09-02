import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/models/direction_details_info.dart';

import '../models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

UserModel? userModelCurrentInfo;

// Function to save the last used email
Future<void> saveLastUsedEmail(String email) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_used_email', email);
}

// Function to get the last used email
Future<String?> getLastUsedEmail() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('last_used_email');
}

String cloudMessagingServerToken = "Bearer ya29.c.c0ASRK0Gak9xNxBZiUUGuG3JKptbeQpvIB2QbyVJNw9CWANV1H3KgL0o2QlGh2YQpHpCyF-cVGv7oxM3sYM5ChfuKdrdaGXrpg-61Z3FGTArFuH0NzfnzDnHKluyhR6sfBU6gEsQlJcnb9K2L3Y4sV-2CWpPsxkNVHGfo1mPzR_M3d1o0aphEibIRPAS7iBRvF0MR7X66TyHFi1JfZiNzgx4NtoCkRrpHZIEQRYRVf_zuH8PngjxjjlF6SS4N2rJI402aq-8jnqV8EDdzGc7Umtkx_GQKNT60MuL8kOKBQPLfG9LEydQsNiDIiJY9VYYt2W8VgrERdwdWncVRRPsl18rMvKRrh79tMg2kd8N3Tb9wyvKlpMisxZFEH384CvIQQS-08ra6qIgkWgYIkkuhJY91da9xbW4-wkeIz3zr19anfvIwbQdfbti6XUFJI_9-tYVXWbxzSBt6ws-zBQftonpbilqsxxMxJMtSrZpkqm4igxnIu9J1yjgn_7b_ojmn08xWdUbs8esWJJyoIVgZeXW5W8stdUQ-eZoosYg1jZfjn2avkefV6MvwpX6MbeqkxZsfrJ8e39803wxfMnvxnrrwjkZ2m655gvJ-92VXJFhpa2OeJ2tuvhvyZnFfWo83nvln4Zbo9tXB7II4s-dkBtydk6_wMyW7glv21sr_7IFQJQRbvVWckuu0X06slStu0x_rs8tjsjyjhu1uUWY4vebWs9o-sc95mph7h-0dtj6dFpOszYIQe4WbO_RfWnuvbdu_l850galwfYIri9eJoea5-cs2VRVSZ8eSx1ls4ag_WaW9nfUa0Fn4f84Sh16719cbr3t8z9yfiqQwXhpJi766dlYMnYsjpQjbpRcmdhi86W4ailFbdrb2keohSoFI3ShrVgS8x54m5n_-iuV9JpekWzaRz2F9qoS7rc-gpo-ttjMSh3q8amqgfQ-WO67369x-FRicZnMVu64Qw3qarZqhzV-Yv-h1wpfmi8tcq";

List helpersList = [];
DirectionDetailsInfo? tripDirectionDetailsInfo;
String userDropOffAddress = "";
String helperVehicleDetails = "";
String helperName = "";
String helperId = "";
String helperPhone = "";
String helperRatings = "";
String selectedVehicleType ="";
double fareAmount =0.0;

double countRatingStars = 0.0;
String titleStarsRating = "";