import 'dart:io' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentmobile/screens/dashboard.dart';

class TimelineScreen extends StatefulWidget {
  final String userId;

  const TimelineScreen({super.key, required this.userId});

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  late Stream<DocumentSnapshot> _registrationStream;
  Map<int, List<XFile>> _selectedFiles = {}; // Map to track selected files per request
  String? _uploadErrorMessage;
  Map<String, bool> _submissionStatus = {};

  @override
  void initState() {
    super.initState();
    _registrationStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .snapshots();

    _loadSubmissionStatus();
  }

  Future<void> _loadSubmissionStatus() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userDoc.exists) {
      setState(() {
        final timeline = List<Map<String, dynamic>>.from(userDoc['timeline'] ?? []);
        for (var i = 0; i < timeline.length; i++) {
          if (timeline[i]['status'] == 'Additional Info Requested' ||
              timeline[i]['status'] == 'Additional Info Submitted') {
            _submissionStatus['issubmitted${i + 1}'] = timeline[i]['issubmitted${i + 1}'] ?? false;
            _selectedFiles[i + 1] = []; // Initialize empty file list for each request
          }
        }
      });
    }
  }

 Future<void> _submitAdditionalInfo(String additionalInfo, int requestIndex) async {
  if (_selectedFiles[requestIndex] == null || _selectedFiles[requestIndex]!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select files to upload')),
    );
    return;
  }

  List<String> uploadedFileNames = [];
  try {
    for (var file in _selectedFiles[requestIndex]!) {
      String fileName = file.name;
      String filePath = 'uploads/${widget.userId}/$fileName';
      
      if (kIsWeb) {
        var bytes = await file.readAsBytes();
        var ref = firebase_storage.FirebaseStorage.instance.ref().child(filePath);
        var uploadTask = await ref.putData(bytes);
        var downloadUrl = await uploadTask.ref.getDownloadURL();
        uploadedFileNames.add(fileName); // Store only the file name
      } else {
        io.File fileToUpload = io.File(file.path);
        var uploadTask = await firebase_storage.FirebaseStorage.instance.ref(filePath).putFile(fileToUpload);
        String downloadUrl = await uploadTask.ref.getDownloadURL();
        uploadedFileNames.add(fileName); // Store only the file name
      }
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
    final userDoc = await docRef.get();
    final timeline = List<Map<String, dynamic>>.from(userDoc['timeline'] ?? []);
    final now = Timestamp.now();

    if (timeline.length > requestIndex - 1) {
      timeline[requestIndex - 1]['status'] = 'Additional Info Submitted';
      timeline[requestIndex - 1]['timestamp'] = now;
      timeline[requestIndex - 1]['issubmitted${requestIndex}'] = true;
      timeline[requestIndex - 1]['uploadedFiles'] = uploadedFileNames; // Store only file names
    }

    await docRef.update({
      'timeline': timeline,
    });

    setState(() {
      _selectedFiles[requestIndex] = []; // Clear selected files after submission
      _submissionStatus['issubmitted${requestIndex}'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Additional information submitted successfully')),
    );
  } catch (e) {
    setState(() {
      _uploadErrorMessage = e.toString();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to upload files: $_uploadErrorMessage')),
    );
  }
}

  Future<void> _pickFiles(int requestIndex) async {
    if (_submissionStatus['issubmitted${requestIndex}'] == true) return;

    final ImagePicker picker = ImagePicker();
    final List<XFile>? newFiles = await picker.pickMultiImage();

    if (newFiles != null) {
      setState(() {
        if (_selectedFiles[requestIndex] != null) {
          _selectedFiles[requestIndex]!.addAll(newFiles.where((newFile) =>
              !_selectedFiles[requestIndex]!.any((selectedFile) => selectedFile.name == newFile.name)));
        } else {
          _selectedFiles[requestIndex] = newFiles;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _registrationStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available.'));
          }

          final registrationData = snapshot.data!.data() as Map<String, dynamic>?;
          if (registrationData == null) {
            return const Center(child: Text('No registration data available.'));
          }

          final currentStatus = registrationData['status'] ?? 'Unknown';
          final timeline = List<Map<String, dynamic>>.from(registrationData['timeline'] ?? []);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimelineStep(
                    context,
                    status: 'Registration',
                    isCompleted: true,
                    isCurrent: currentStatus == 'Pending Review' ||
                        currentStatus == 'Pending Approval' ||
                        currentStatus == 'Approved',
                  ),
                  _buildTimelineStep(
                    context,
                    status: 'Pending Review',
                    isCompleted: currentStatus != 'Registration',
                    isCurrent: currentStatus == 'Pending Review',
                  ),
                  ..._buildAdditionalInfoSteps(timeline),
                  _buildTimelineStep(
                    context,
                    status: 'Pending Approval',
                    isCompleted: currentStatus == 'Pending Approval' ||
                        currentStatus == 'Approved',
                    isCurrent: currentStatus == 'Pending Approval',
                  ),
                  _buildTimelineStep(
                    context,
                    status: 'Approved',
                    isCompleted: currentStatus == 'Approved',
                    isCurrent: currentStatus == 'Approved',
                  ),
                  if (currentStatus == 'Approved')
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'CONGRATULATIONS YOUR APPLICATION IS APPROVED!!!',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _goToDashboard,
                          child: const Text('Go to DASHBOARD'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildAdditionalInfoSteps(List<Map<String, dynamic>> timeline) {
    List<Widget> steps = [];

    for (var i = 0; i < timeline.length; i++) {
      final entry = timeline[i];
      if (entry['status'] == 'Additional Info Requested' || entry['status'] == 'Additional Info Submitted') {
        bool isSubmitted = entry['issubmitted${i + 1}'] ?? false;
        steps.add(
          _buildTimelineStep(
            context,
            status: 'Additional Info Requested - ${i + 1}',
            isCompleted: isSubmitted,
            isCurrent: !isSubmitted,
            child: _buildAdditionalInfoSection(timeline, i + 1), // Pass index + 1 as requestIndex
          ),
        );
      }
    }

    return steps;
  }

  Widget _buildTimelineStep(BuildContext context,
    {required String status,
    required bool isCompleted,
    required bool isCurrent,
    Widget? child}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.access_time,
                color: isCompleted ? Colors.green : Colors.grey,
              ),
              if (status != 'Approved')
                Container(
                  width: 2,
                  height: 20,
                  color: isCompleted ? Colors.green : Colors.grey,
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              status,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCurrent ? Colors.blue : Colors.black,
              ),
            ),
          ),
        ],
      ),
      if (child != null) child,
    ],
  );
}

Widget _buildAdditionalInfoSection(List<Map<String, dynamic>> timeline, int requestIndex) {
  final additionalInfoRequest = timeline[requestIndex - 1];
  String message = additionalInfoRequest['message'] ?? 'Please provide the requested information.';
  List<String>? uploadedFiles = List<String>.from(additionalInfoRequest['uploadedFiles'] ?? []);
  bool isSubmitted = additionalInfoRequest['issubmitted${requestIndex}'] ?? false;

  return Padding(
    padding: const EdgeInsets.only(left: 30.0), // Adjust this value to match the line's position
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // NOTE: Message
        Text(
          'NOTE: $message',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Selected Files
        if (_selectedFiles[requestIndex] != null && _selectedFiles[requestIndex]!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected Files (${_selectedFiles[requestIndex]!.length}):',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              ..._selectedFiles[requestIndex]!.map((file) => Row(
                children: [
                  Expanded(
                    child: Text(
                      file.name, // Use the original file name
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedFiles[requestIndex]!.removeWhere((selectedFile) => selectedFile.name == file.name);
                      });
                    },
                  ),
                ],
              )),
            ],
          ),
        const SizedBox(height: 10),
        // Uploaded Files
        if (uploadedFiles.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: uploadedFiles
                .map((fileName) => Text(
                      '- $fileName',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ))
                .toList(),
          ),
        const SizedBox(height: 10),
        // Upload Files Button
        GestureDetector(
          onTap: isSubmitted ? null : () => _pickFiles(requestIndex),
          child: Text(
            'Upload Files',
            style: TextStyle(
              color: isSubmitted ? Colors.grey : Colors.blue,
              decoration: isSubmitted ? TextDecoration.none : TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Submit Button
        ElevatedButton(
          onPressed: isSubmitted
              ? null
              : () {
                  if (_selectedFiles[requestIndex] == null || _selectedFiles[requestIndex]!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select files to upload')),
                    );
                    return;
                  }
                  _submitAdditionalInfo(message, requestIndex);
                },
          child: const Text('Submit'),
        ),
      ],
    ),
  );
}


   void _goToDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Dashboard()),
    );
  }
}

