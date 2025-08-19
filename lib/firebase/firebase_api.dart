import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';



class DataBaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  static Future<void> initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // create funciton that create a new document in the collectoin "individuals"
  Future<void> createIndividual(String name) async {

    try{
      await _firestore.collection('individuals').doc().set({
        'name': name,
      });

      // print('Individual created successfully');
    } catch (e) {
      print('Error creating individual: $e');
    }
  }

  // get all individuals
  Future<List<Map<String, dynamic>>> getAllIndividuals() async {
    try{
      final querySnapshot = await _firestore.collection('individuals').get();
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting individuals: $e');
      return [];
    }
  }

  // delete multiple individuals by their document ids
  Future<void> deleteIndividuals(List<String> individualIds) async {
    try {
      if (individualIds.isEmpty) return;
      WriteBatch batch = _firestore.batch();
      for (final id in individualIds) {
        final docRef = _firestore.collection('individuals').doc(id);
        batch.delete(docRef);
      }
      await batch.commit();
      // print('Deleted ${individualIds.length} individuals');
    } catch (e) {
      print('Error deleting individuals: $e');
      rethrow;
    }
  }

  // get leaderboard data sorted by task count
  Future<List<Map<String, dynamic>>> getLeaderboardData() async {
    try {
      final querySnapshot = await _firestore.collection('individuals').get();
      List<Map<String, dynamic>> leaderboardData = [];
      
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        int taskCount = 0;
        
        // Count tasks if taskNumbers array exists
        if (data.containsKey('taskNumbers') && data['taskNumbers'] is List) {
          taskCount = (data['taskNumbers'] as List).length;
        }
        
        leaderboardData.add({
          'id': doc.id,
          'name': data['name'] ?? 'Unknown User',
          'taskCount': taskCount,
        });
      }
      
      // Sort by task count in descending order (highest first)
      leaderboardData.sort((a, b) => (b['taskCount'] ?? 0).compareTo(a['taskCount'] ?? 0));
      
      return leaderboardData;
    } catch (e) {
      print('Error getting leaderboard data: $e');
      return [];
    }
  }

  // get individual user statistics
  Future<Map<String, dynamic>?> getUserStats(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('individuals').doc(userId).get();
      
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        int taskCount = 0;
        
        if (data.containsKey('taskNumbers') && data['taskNumbers'] is List) {
          taskCount = (data['taskNumbers'] as List).length;
        }
        
        return {
          'id': docSnapshot.id,
          'name': data['name'] ?? 'Unknown User',
          'taskCount': taskCount,
          'taskNumbers': data['taskNumbers'] ?? [],
        };
      }
      
      return null;
    } catch (e) {
      print('Error getting user stats: $e');
      return null;
    }
  }

  //create task in the collection "tasks" and this collection is in the individual document
  Future<void> createTask(String taskNumber, String individualId) async {
      DocumentReference individualDoc = _firestore.collection('individuals').doc(individualId);
      DocumentSnapshot docSnapshot = await individualDoc.get();
      // print('docSnapshot: $docSnapshot');
      // print('individualId: $individualId');
      // print('taskNumber: $taskNumber');
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        
        if (data.containsKey('taskNumbers')) {
          // Check if the task number already exists in the array
          List<dynamic> existingTaskNumbers = data['taskNumbers'] ?? [];
          if (existingTaskNumbers.contains(taskNumber)) {
            // If task number exists, remove it from the array
            await individualDoc.update({
              'taskNumbers': FieldValue.arrayRemove([taskNumber])
            });
          } else {
            // If task number doesn't exist, add it to the array
            await individualDoc.update({
              'taskNumbers': FieldValue.arrayUnion([taskNumber])
            });
          }
        } else {
          // If taskNumbers field doesn't exist, create it with the new number
          await individualDoc.update({
            'taskNumbers': [taskNumber]
          });
        }

        // print('Task created successfully');
      }

  }

  // Create a new takareer document in the "takareer" collection
  Future<void> createTakareer({
    required String title,
    required String place,
    required String day,
    required String date,
    required String number,
  }) async {
    try {
      await _firestore.collection('takareer').add({
        'title': title,
        'place': place,
        'day': day,
        'date': date,
        'number': number,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // print('Takareer created successfully');
    } catch (e) {
      print('Error creating takareer: $e');
      throw Exception('Failed to create takareer: $e');
    }
  }

  // get all takareer
  Future<List<Map<String, dynamic>>> getAllTakareer() async {
    try {
      final querySnapshot = await _firestore.collection('takareer').get();
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting takareer: $e');
      return [];
    }
  }

  // Get takareer from start of current week to now
  Future<List<Map<String, dynamic>>> getTakareerThisWeek() async {
    try {
      // Get the start of the current week (Sunday)
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
      final startOfWeekFormatted = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      
      // Get all takareer
      final querySnapshot = await _firestore.collection('takareer').get();
      
      // Filter takareer by date range
      final filteredTakareer = <Map<String, dynamic>>[];
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final dateStr = data['date'] as String?;
        
        if (dateStr != null && dateStr.isNotEmpty) {
          try {
            // Parse the date string (assuming format: dd/MM/yyyy)
            final dateParts = dateStr.split('/');
            if (dateParts.length == 3) {
              final day = int.parse(dateParts[0]);
              final month = int.parse(dateParts[1]);
              final year = int.parse(dateParts[2]);
              final takareerDate = DateTime(year, month, day);
              
              // Check if takareer date is within this week
              if (takareerDate.isAfter(startOfWeekFormatted.subtract(Duration(days: 1))) && 
                  takareerDate.isBefore(now.add(Duration(days: 1)))) {
                filteredTakareer.add({
                  'id': doc.id,
                  ...data,
                });
              }
            }
          } catch (e) {
            // Skip invalid dates
            continue;
          }
        }
      }
      
      // Sort by date (newest first)
      filteredTakareer.sort((a, b) {
        try {
          final aDateParts = (a['date'] as String).split('/');
          final bDateParts = (b['date'] as String).split('/');
          
          final aDate = DateTime(
            int.parse(aDateParts[2]),
            int.parse(aDateParts[1]),
            int.parse(aDateParts[0]),
          );
          final bDate = DateTime(
            int.parse(bDateParts[2]),
            int.parse(bDateParts[1]),
            int.parse(bDateParts[0]),
          );
          // print('aDate: $aDate');
          // print('bDate: $bDate');
          return bDate.compareTo(aDate);
        } catch (e) {
          return 0;
        }
      });
      
      return filteredTakareer;
    } catch (e) {
      print('Error getting takareer for this week: $e');
      return [];
    }
  }

  // delete takareer by id
  Future<void> deleteTakareer(String id) async {
    try {
      await _firestore.collection('takareer').doc(id).delete();
      // print('Takareer deleted successfully');
    } catch (e) {
      print('Error deleting takareer: $e');
      throw Exception('Failed to delete takareer: $e');
    }
  }


}

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns the current user or null if no user is signed in
  User? get user => _firebaseAuth.currentUser;

  /// Returns true if the current user's email is verified
  bool get isUserVerified => user?.emailVerified ?? false;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();



  /// Reloads the current user's data
  Future<void> reload() async {
    try {
      await user?.reload();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to reload user data');
    }
  }

  /// Sends password reset email to the specified email address
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to reset password');
    }
  }

 Future<String?> fetchUserPasswordByPhone(String phoneNumber) async {
  try {
    final formattedPhone = phoneNumber.trim() + "@phone.com";
    //print(formattedPhone);
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('phoneNumber', isEqualTo: formattedPhone)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs.first.data();
      //print("Password found: ${data['password']}");
      return data['password'];
    } else {
      //print("No user found with phone: $formattedPhone");
      return null;
    }
  } catch (e) {
    //print('Error fetching password by phone number: $e');
    return null;
  }
}

// cehck password if correct
Future<bool?> checkPassword( String password) async {
  try{
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get();
    if (querySnapshot.exists) {
      final data = querySnapshot.data() as Map<String, dynamic>;
      //print('data: ${data['password']}');
      //print('password: $password');
      if (data['password'] == password) {
        //print('password is correct');
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } catch (e) {
    //print('Error checking password: $e');
    return null;
  }
}

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to sign out');
    }
  }

  /// Signs in a user with email and password
  Future<void> loginUser({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      String cleanPhoneNumber = phoneNumber.replaceAll(' ', '');
      // print('cleanPhoneNumber: $cleanPhoneNumber');
      // print('password: $password');
      final UserCredential result = await _firebaseAuth
          .signInWithEmailAndPassword(
            email: "${cleanPhoneNumber.trim()}@phone.com",
            password: password.trim(),
          );
    } on FirebaseAuthException catch (error) {
      throw Exception('Invalid password');
    }
  }

  /// Registers a new user with phone number and password
  Future<UserCredential> registerUser({
    required String phoneNumber,
    required String password,
    required String fullName,
    String? email,
  }) async {
      // Remove all spaces from phone number
String cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      print('cleanPhoneNumber: $cleanPhoneNumber');
      print('password: $password');
      print('fullName: $fullName');
      print('email: $email');
      // Create user with email (using phone number as email)
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: "${cleanPhoneNumber.trim()}@phone.com",
            password: password.trim(),
          );

      // Save additional user data to Firestore
      if (userCredential.user != null) {
        await _firestore.collection('Users').doc(userCredential.user!.uid).set({
          'phoneNumber': "${cleanPhoneNumber.trim()}@phone.com",
          'fullName': fullName,
          'email': email,
          'password': password.trim(),
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
  }
}