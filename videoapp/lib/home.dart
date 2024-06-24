import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  final String phoneNumber;

  const Home({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController nameController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String welcomeMessage = '';

  @override
  void initState() {
    super.initState();
    checkExistingUser();
  }

  Future<void> checkExistingUser() async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: widget.phoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        setState(() {
          welcomeMessage = 'Welcome back, ${userData['name']}!';
        });
      }
    } catch (e) {
      setState(() {
        welcomeMessage = 'Error retrieving user data: $e';
      });
    }
  }

  Future<void> saveName(String name) async {
    try {
      await firestore.collection('users').add({
        'name': name,
        'phoneNumber': widget.phoneNumber, // Save the phone number
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        welcomeMessage = 'Welcome, $name!';
      });
    } catch (e) {
      setState(() {
        welcomeMessage = 'Failed to save data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Enter Name",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String enteredName = nameController.text;
                  if (enteredName.isNotEmpty) {
                    saveName(enteredName);
                  } else {
                    setState(() {
                      welcomeMessage = 'Please enter a name';
                    });
                  }
                },
                child: const Text('Submit'),
              ),
              const SizedBox(height: 20),
              Text(
                welcomeMessage,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
