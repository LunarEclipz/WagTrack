import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:wagtrack/models/report_model.dart';
import 'package:wagtrack/services/logging.dart';

class NewsService with ChangeNotifier {
  static final FirebaseFirestore _db = GetIt.I<FirebaseFirestore>();
  static final _firestoreNewsCollection = _db.collection("news");

  static final FirebaseStorage _firebaseStorage = GetIt.I<FirebaseStorage>();
  static final Reference _storageRef = _firebaseStorage.ref();

  final List<AVSNews> _avsNews = [];
  List<AVSNews> get avsNews => _avsNews;

  /// Fetches all Medication Routine associated with a specific pet ID
  Future<List<AVSNews>> getAllNews() async {
    try {
      // Query Firestore for documents in the "symptoms" collection where "petID" field matches the provided petID
      final querySnapshot = await _firestoreNewsCollection.get();

      final List<AVSNews> news = [];
      for (final docSnapshot in querySnapshot.docs) {
        // Extract data from the document
        final newsData = docSnapshot.data();
        final AVSNews newsDetails = AVSNews.fromJson(newsData);
        news.add(newsDetails);
      }
      return news;
    } catch (e) {
      // **Bold Error Message**
      AppLogger.e("[NEWS] Error fetching News: $e", e);
      return []; // Return an empty list on error
    }
  }
}
