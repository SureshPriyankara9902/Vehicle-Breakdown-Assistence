import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../global/global.dart';
import '../splashScreen/splash_screen.dart';

class RateHelperScreen extends StatefulWidget {
  final String? assignedHelperId;

  const RateHelperScreen({Key? key, this.assignedHelperId}) : super(key: key);

  @override
  State<RateHelperScreen> createState() => _RateHelperScreenState();
}

class _RateHelperScreenState extends State<RateHelperScreen> {
  int countRatingStars = 0;
  bool isSubmitting = false;
  bool isRatingSubmitted = false;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _ratingDescriptions = [
    "Very poor",
    "Not good",
    "Average",
    "Good",
    "Excellent"
  ];

  void _submitRating() {
    if (isSubmitting || countRatingStars == 0) {
      if (countRatingStars == 0) {
        Fluttertoast.showToast(
          msg: "Please select a rating",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
      return;
    }

    setState(() => isSubmitting = true);

    final currentUserId = firebaseAuth.currentUser?.uid;
    if (currentUserId == null) {
      setState(() => isSubmitting = false);
      _showErrorDialog("Please login to submit a rating");
      return;
    }

    _submitRatingToFirebase(currentUserId);
  }

  void _submitRatingToFirebase(String currentUserId) {
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentUserId);

    userRef.once().then((userSnap) {
      if (userSnap.snapshot.value == null) {
        setState(() => isSubmitting = false);
        _showErrorDialog("User information not found");
        return;
      }

      final userData = userSnap.snapshot.value as Map<dynamic, dynamic>;
      final userName = userData['name'] as String? ?? "Anonymous";

      DatabaseReference rateHelperRef = FirebaseDatabase.instance
          .ref()
          .child("helpers")
          .child(widget.assignedHelperId!)
          .child("ratings");

      rateHelperRef.once().then((snap) {
        double newAverageRatings;
        if (snap.snapshot.value == null) {
          newAverageRatings = countRatingStars.toDouble();
        } else {
          double pastRating = double.parse(snap.snapshot.value.toString());
          newAverageRatings = (pastRating + countRatingStars) / 2;
        }

        newAverageRatings = double.parse(newAverageRatings.toStringAsFixed(1));

        DatabaseReference ratingDetailsRef = FirebaseDatabase.instance
            .ref()
            .child("helpers")
            .child(widget.assignedHelperId!)
            .child("ratingDetails")
            .push();

        final ratingData = {
          'rating': countRatingStars,
          'userId': currentUserId,
          'userName': userName,
          'timestamp': ServerValue.timestamp,
        };

        Map<String, dynamic> updates = {};
        updates['/ratings'] = newAverageRatings.toString();
        updates['/ratingDetails/${ratingDetailsRef.key}'] = ratingData;

        FirebaseDatabase.instance
            .ref()
            .child("helpers")
            .child(widget.assignedHelperId!)
            .update(updates)
            .then((_) {
          _submitComment(userName);
        }).catchError((error) {
          setState(() => isSubmitting = false);
          _showErrorDialog("Error submitting rating: $error");
        });
      }).catchError((error) {
        setState(() => isSubmitting = false);
        _showErrorDialog("Error fetching previous rating: $error");
      });
    }).catchError((error) {
      setState(() => isSubmitting = false);
      _showErrorDialog("Error fetching user information: $error");
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  void _submitComment(String userName) {
    String comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      DatabaseReference commentRef = FirebaseDatabase.instance
          .ref()
          .child("helpers")
          .child(widget.assignedHelperId!)
          .child("comments")
          .push();

      Map<String, dynamic> commentData = {
        'comment': comment,
        'userId': firebaseAuth.currentUser?.uid,
        'userName': userName,
        'timestamp': ServerValue.timestamp,
      };

      commentRef.set(commentData).then((_) {
        _completeRatingSubmission();
      }).catchError((error) {
        setState(() => isSubmitting = false);
        _showErrorDialog("Error submitting comment: $error");
      });
    } else {
      _completeRatingSubmission();
    }
  }

  void _completeRatingSubmission() {
    setState(() {
      isRatingSubmitted = true;
      isSubmitting = false;
    });

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text("Thank You!"),
        content: Text("Your rating has been submitted successfully."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateToSplashScreen();
            },
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  void _navigateToSplashScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (c) => SplashScreen()),
            (route) => false,
      );
    });
  }

  Future<bool> _onWillPop() async {
    if (!isRatingSubmitted) {
      Fluttertoast.showToast(
        msg: "Please submit your rating before leaving.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = darkTheme ? Colors.amber : Colors.green;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: darkTheme ? Colors.grey[900] : Colors.grey[100],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rate_review,
                    size: 80,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Rate Your Helper",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: darkTheme ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "How was your experience with the helper?",
                    style: TextStyle(
                      fontSize: 16,
                      color: darkTheme ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: darkTheme ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() => countRatingStars = index + 1);
                              },
                              child: Icon(
                                index < countRatingStars
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 40,
                                color: Colors.amber,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          countRatingStars > 0
                              ? _ratingDescriptions[countRatingStars - 1]
                              : "Tap to rate",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Add a comment (optional)",
                    style: TextStyle(
                      fontSize: 16,
                      color: darkTheme ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "What did you like or what could be improved?",
                      hintStyle: TextStyle(
                        color: darkTheme ? Colors.grey[500] : Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: darkTheme ? Colors.grey[800] : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(15),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (countRatingStars == 0 || isSubmitting)
                          ? null
                          : _submitRating,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: isSubmitting
                          ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                          : Text(
                        "SUBMIT RATING",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (isRatingSubmitted) ...[
                    const SizedBox(height: 20),
                    Icon(
                      Icons.check_circle,
                      size: 60,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Thank you for your feedback!",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}