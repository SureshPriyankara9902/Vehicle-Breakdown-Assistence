import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../global/global.dart';

class RatingsTabPage extends StatefulWidget {
  const RatingsTabPage({super.key});

  @override
  State<RatingsTabPage> createState() => _RatingsTabPageState();
}

class _RatingsTabPageState extends State<RatingsTabPage> {
  double ratingsNumber = 0;
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;
  String? errorMessage;
  String ratingQuality = "No Ratings";
  Map<String, String> userIdToName = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await Future.wait([
        _getRatingsData(),
        _fetchComments(),
      ]);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Failed to load data: ${e.toString()}";
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getRatingsData() async {
    try {
      if (firebaseAuth.currentUser == null) {
        throw Exception("User not logged in");
      }

      DatabaseReference ratingsRef = FirebaseDatabase.instance
          .ref()
          .child("helpers")
          .child(firebaseAuth.currentUser!.uid)
          .child("ratings");

      DataSnapshot snapshot = await ratingsRef.get();

      if (!mounted) return;

      setState(() {
        if (snapshot.exists && snapshot.value != null) {
          try {
            ratingsNumber = double.parse(snapshot.value.toString());
          } catch (e) {
            ratingsNumber = 0;
          }
        } else {
          ratingsNumber = 0;
        }
        _setRatingQuality(ratingsNumber);
      });
    } catch (e) {
      print("Error fetching ratings: $e");
      if (!mounted) return;
      setState(() {
        ratingsNumber = 0;
        ratingQuality = "Error Loading Ratings";
      });
    }
  }

  void _setRatingQuality(double rating) {
    setState(() {
      if (rating >= 4.5) ratingQuality = "Excellent";
      else if (rating >= 4.0) ratingQuality = "Very Good";
      else if (rating >= 3.0) ratingQuality = "Good";
      else if (rating >= 2.0) ratingQuality = "Fair";
      else if (rating > 0) ratingQuality = "Poor";
      else ratingQuality = "No Ratings";
    });
  }

  Future<void> _fetchComments() async {
    try {
      if (firebaseAuth.currentUser == null) {
        throw Exception("User not logged in");
      }

      DatabaseReference commentsRef = FirebaseDatabase.instance
          .ref()
          .child("helpers")
          .child(firebaseAuth.currentUser!.uid)
          .child("comments");

      DataSnapshot snapshot = await commentsRef.get();

      if (!mounted) return;

      if (snapshot.exists && snapshot.value != null) {
        try {
          final dynamic value = snapshot.value;
          if (value is Map) {
            List<Map<String, dynamic>> newComments = [];

            value.forEach((key, value) {
              if (value is Map) {
                Map<String, dynamic> commentData = Map<String, dynamic>.from(value);
                commentData['id'] = key;

                // Handle timestamp
                if (commentData['timestamp'] != null) {
                  try {
                    final timestamp = int.parse(commentData['timestamp'].toString());
                    commentData['timestamp'] = DateTime.fromMillisecondsSinceEpoch(timestamp);
                  } catch (e) {
                    commentData['timestamp'] = DateTime.now();
                  }
                } else {
                  commentData['timestamp'] = DateTime.now();
                }

                newComments.add(commentData);
              }
            });

            // Sort comments by timestamp
            newComments.sort((a, b) {
              final DateTime timeA = a['timestamp'] as DateTime;
              final DateTime timeB = b['timestamp'] as DateTime;
              return timeB.compareTo(timeA);
            });

            setState(() {
              comments = newComments;
            });
          }
        } catch (e) {
          print("Error parsing comments: $e");
          setState(() {
            comments = [];
            errorMessage = "Error parsing comments data";
          });
        }
      } else {
        setState(() {
          comments = [];
        });
      }
    } catch (e) {
      print("Error fetching comments: $e");
      if (!mounted) return;
      setState(() {
        comments = [];
        errorMessage = "Failed to load comments: ${e.toString()}";
      });
    }
  }

  Future<String> _getUserName(String? userId) async {
    if (userId == null || userId.isEmpty) {
      return "Unknown User";
    }

    if (userIdToName.containsKey(userId)) {
      return userIdToName[userId]!;
    }

    try {
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(userId);

      DataSnapshot snapshot = await userRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final value = snapshot.value;
        if (value is Map) {
          String name = value['name']?.toString() ?? "Unknown User";
          userIdToName[userId] = name;
          return name;
        }
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
    return "Unknown User";
  }

  Future<void> _deleteReview(String reviewId) async {
    try {
      if (firebaseAuth.currentUser == null) return;

      // Show confirmation dialog
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete Review"),
            content: const Text("Are you sure you want to delete this review?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (confirmDelete != true) return;

      // Delete from Firebase
      DatabaseReference reviewRef = FirebaseDatabase.instance
          .ref()
          .child("helpers")
          .child(firebaseAuth.currentUser!.uid)
          .child("comments")
          .child(reviewId);

      await reviewRef.remove();

      // Refresh data
      await _loadData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review deleted successfully")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete review: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
        title: const Text(
          'Feedback & Ratings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text("Retry"),
              ),
            ],
          ),
        )
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Average Rating Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Your Average Rating',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SmoothStarRating(
                      rating: ratingsNumber,
                      color: Colors.amber,
                      borderColor: Colors.grey[300],
                      size: 35,
                      spacing: 8,
                      starCount: 5,
                      allowHalfRating: true,
                      onRatingChanged: (v) {},
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ratingsNumber.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ratingQuality,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Based on ${comments.length} ${comments.length == 1 ? 'review' : 'reviews'}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white60 : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // User Reviews Section
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User Reviews',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (comments.isNotEmpty)
                    Text(
                      '${comments.length} ${comments.length == 1 ? 'comment' : 'comments'}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white60 : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            if (comments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reviews yet',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white38 : Colors.black38,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...comments.map((comment) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: _getUserName(comment['userId']?.toString()),
                        builder: (context, snapshot) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: isDarkMode ? Colors.white12 : Colors.grey[200],
                                    child: Text(
                                      (snapshot.data ?? 'U')[0].toUpperCase(),
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              snapshot.data ?? 'Loading...',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: isDarkMode ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  timeago.format(
                                                    comment['timestamp'] as DateTime,
                                                    allowFromNow: true,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: isDarkMode ? Colors.white54 : Colors.black54,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: isDarkMode ? Colors.white54 : Colors.grey[600],
                                                    size: 18,
                                                  ),
                                                  onPressed: () => _deleteReview(comment['id']),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        if (comment['comment']?.toString().isNotEmpty ?? false)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 0.001),
                                            child: Text(
                                              comment['comment']?.toString() ?? '',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: isDarkMode ? Colors.white70 : Colors.black87,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (comment['rating'] != null)
                                    SmoothStarRating(
                                      rating: double.tryParse(comment['rating'].toString()) ?? 0,
                                      color: Colors.amber,
                                      borderColor: Colors.grey[300],
                                      size: 20,
                                      spacing: 2,
                                      starCount: 5,
                                      allowHalfRating: true,
                                      onRatingChanged: (v) {},
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      )

                    ],
                  ),
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }
}