import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:toastification/toastification.dart';

class EventOweDue {
  String eventId; // Unique identifier for the event
  double owe; // Amount the friend owes for this event
  double due; // Amount the friend is owed for this event
  EventOweDue? next; // Pointer to the next event's record in the linked list

  EventOweDue({
    required this.eventId,
    required this.owe,
    required this.due,
    this.next,
  });
}

class Friend {
  String name;
  String email;
  String phoneNumber;
  File? avatar;
  bool isAddedToEvent;
  double totalPaid; // Total amount the friend has paid
  double totalOwe; // Total amount the friend owes across all events
  double totalDue; // Total amount the friend is owed across all events
  EventOweDue? eventOweDueListHead; // Linked list head for event-wise owes and dues

  Friend({
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.avatar,
    this.isAddedToEvent = false,
    this.totalPaid = 0.0,
    this.totalOwe = 0.0,
    this.totalDue = 0.0,
    this.eventOweDueListHead,
  });

  // Add an owe/due entry for an event
  void addEventOweDue(String eventId, double owe, double due) {
    EventOweDue newEntry = EventOweDue(eventId: eventId, owe: owe, due: due);
    newEntry.next = eventOweDueListHead;
    eventOweDueListHead = newEntry;

    // Update totals
    totalOwe += owe;
    totalDue += due;
  }

  // Remove an owe/due entry for an event
  void removeEventOweDue(String eventId) {
    EventOweDue? current = eventOweDueListHead;
    EventOweDue? previous;

    while (current != null) {
      if (current.eventId == eventId) {
        // Subtract from totals
        totalOwe -= current.owe;
        totalDue -= current.due;

        // Remove the entry from the linked list
        if (previous == null) {
          eventOweDueListHead = current.next;
        } else {
          previous.next = current.next;
        }
        break;
      }
      previous = current;
      current = current.next;
    }
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatar': avatar?.path,
      'isAddedToEvent': isAddedToEvent,
      'totalPaid': totalPaid,
      'totalOwe': totalOwe,
      'totalDue': totalDue,
      'eventOweDueList': _linkedListToJson(eventOweDueListHead),
    };
  }

  // Deserialize from JSON
  static Friend fromJson(Map<String, dynamic> json) {
    return Friend(
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      avatar: json['avatar'] != null ? File(json['avatar']) : null,
      isAddedToEvent: json['isAddedToEvent'] ?? false,
      totalPaid: json['totalPaid'] ?? 0.0,
      totalOwe: json['totalOwe'] ?? 0.0,
      totalDue: json['totalDue'] ?? 0.0,
      eventOweDueListHead: _linkedListFromJson(json['eventOweDueList']),
    );
  }

  // Convert linked list to JSON format
  List<Map<String, dynamic>> _linkedListToJson(EventOweDue? head) {
    List<Map<String, dynamic>> jsonList = [];
    EventOweDue? current = head;

    while (current != null) {
      jsonList.add({
        'eventId': current.eventId,
        'owe': current.owe,
        'due': current.due,
      });
      current = current.next;
    }
    return jsonList;
  }

  // Convert JSON to linked list
  static EventOweDue? _linkedListFromJson(List<dynamic>? jsonList) {
    if (jsonList == null || jsonList.isEmpty) return null;

    EventOweDue? head;
    EventOweDue? current;

    for (var jsonEntry in jsonList) {
      EventOweDue newEntry = EventOweDue(
        eventId: jsonEntry['eventId'],
        owe: jsonEntry['owe'],
        due: jsonEntry['due'],
      );

      if (head == null) {
        head = newEntry;
        current = newEntry;
      } else {
        current!.next = newEntry;
        current = newEntry;
      }
    }
    return head;
  }
}

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<Friend> friends = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? friendsJson = prefs.getStringList('friends');
    if (friendsJson != null) {
      setState(() {
        friends = friendsJson.map((jsonStr) => Friend.fromJson(json.decode(jsonStr))).toList();
      });
    }
  }

  Future<void> _saveFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> friendsJson = friends.map((friend) => json.encode(friend.toJson())).toList();
    await prefs.setStringList('friends', friendsJson);
  }

  void _addFriend() {
    showDialog(
      context: context,
      builder: (context) {
        String newName = '';
        String newEmail = '';
        String newPhone = '';
        File? newAvatar;

        return AlertDialog(
          title: const Text('Add Friend'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setDialogState(() {
                            newAvatar = File(pickedFile.path);
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: newAvatar != null
                            ? FileImage(newAvatar!)
                            : const AssetImage("assets/avatar.jpg") as ImageProvider,
                        child: newAvatar == null
                            ? const Icon(Icons.camera_alt, size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Name',
                      onChanged: (value) => newName = value,
                    ),
                    _buildTextField(
                      label: 'Email',
                      onChanged: (value) => newEmail = value,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      label: 'Phone Number',
                      onChanged: (value) => newPhone = value,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (newName.isEmpty || newEmail.isEmpty || newPhone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill out all fields')),
                  );
                  return;
                }
                if (!emailRegex.hasMatch(newEmail)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid email address')),
                  );
                  return;
                }

                Friend newFriend = Friend(
                  name: newName,
                  email: newEmail,
                  phoneNumber: newPhone,
                  avatar: newAvatar,
                );

                setState(() {
                  friends.add(newFriend);
                });
                _saveFriends();
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addFriend,
          ),
        ],
      ),
      body: friends.isEmpty
          ? const Center(child: Text('No Friends Added'))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              alignment: Alignment.centerRight,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onDismissed: (direction) {
              setState(() {
                friends.removeAt(index);
              });
              _saveFriends(); // Save the updated list after deletion
              toastification.show(
                context: context,
                title: Text('Friend Deleted'),
                description: Text('${friend.name} has been removed from your list.'),
                type: ToastificationType.info, // Choose the type: success, info, warning, error
              );
            },            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: friend.avatar != null
                      ? FileImage(friend.avatar!)
                      : const AssetImage("assets/avatar.jpg") as ImageProvider,
                ),
                title: Text(friend.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(friend.email),
                    Text(friend.phoneNumber),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Owes: Rs.${friend.totalOwe.toStringAsFixed(2)}'),
                    Text('Dues: Rs.${friend.totalDue.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
