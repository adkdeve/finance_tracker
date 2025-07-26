import 'dart:convert';
import 'package:finance_recorder/screens/FriendsScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventTitle;
  final String eventDescription;
  final Color cardColor;
  final VoidCallback onDelete;

  const EventDetailScreen({
    Key? key,
    required this.eventTitle,
    required this.eventDescription,
    required this.cardColor,
    required this.onDelete,
  }) : super(key: key);

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  double totalOwe = 0.0;
  double totalDue = 0.0;
  double totalPaid = 0.0;
  List<Friend> friendsInEvent = [];
  List<Friend> allFriends = [];
  Map<String, double> paidAmountMap = {};
  Map<String, double> oweAmountMap = {};
  Map<String, double> dueAmountMap = {};
  late String eventTitle;
  late String eventDescription;

  @override
  void initState() {
    super.initState();
    eventTitle = widget.eventTitle;
    eventDescription = widget.eventDescription;
    _loadFriendsInEvent();
  }

  Future<void> _loadFriendsInEvent() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Load friends specific to this event
      List<String>? friendsJson = prefs.getStringList('${eventTitle}_friendsInEvent');
      List<String>? allFriendsJson = prefs.getStringList('friends');

      setState(() {
        if (friendsJson != null) {
          friendsInEvent = friendsJson.map((jsonStr) => Friend.fromJson(json.decode(jsonStr))).toList();
        }
        if (allFriendsJson != null) {
          allFriends = allFriendsJson.map((jsonStr) => Friend.fromJson(json.decode(jsonStr))).toList();
        }

        // Load paid, owe, and due amounts from SharedPreferences
        String? paidAmountMapJson = prefs.getString('${eventTitle}_paidAmountMap');
        String? oweAmountMapJson = prefs.getString('${eventTitle}_oweAmountMap');
        String? dueAmountMapJson = prefs.getString('${eventTitle}_dueAmountMap');

        // Decode each map if they exist in SharedPreferences
        if (paidAmountMapJson != null) {
          paidAmountMap = Map<String, double>.from(json.decode(paidAmountMapJson));
        }
        if (oweAmountMapJson != null) {
          oweAmountMap = Map<String, double>.from(json.decode(oweAmountMapJson));
        }
        if (dueAmountMapJson != null) {
          dueAmountMap = Map<String, double>.from(json.decode(dueAmountMapJson));
        }

        // Initialize totals
        _updateTotals();
      });
    } catch (e) {
      debugPrint('Error loading friends data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load friends data.')),
      );
    }
  }

  Future<void> _saveFriendsInEvent() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Save list of friends in the event
      List<String> friendsJson = friendsInEvent.map((friend) => json.encode(friend.toJson())).toList();
      await prefs.setStringList('${eventTitle}_friendsInEvent', friendsJson);

      // Save paid, owe, and due amounts as JSON-encoded maps
      await prefs.setString('${eventTitle}_paidAmountMap', json.encode(paidAmountMap));
      await prefs.setString('${eventTitle}_oweAmountMap', json.encode(oweAmountMap));
      await prefs.setString('${eventTitle}_dueAmountMap', json.encode(dueAmountMap));

      // Update the global friends list with updated totals
      for (var friend in friendsInEvent) {
        var matchingFriend = allFriends.firstWhere(
              (f) => f.name == friend.name,
          orElse: () => Friend(
            name: '',
            email: '',
            phoneNumber: '',
            isAddedToEvent: false,
            totalPaid: 0.0,
            totalOwe: 0.0,
            totalDue: 0.0,
          ),
        );

        if (matchingFriend.name.isNotEmpty) {
          // Add the current values to the existing totals
          matchingFriend.totalPaid += paidAmountMap[friend.name] ?? 0.0;
          matchingFriend.totalOwe += oweAmountMap[friend.name] ?? 0.0;
          matchingFriend.totalDue += dueAmountMap[friend.name] ?? 0.0;
        }
      }

      // Save updated allFriends list back to SharedPreferences
      List<String> allFriendsJson = allFriends.map((friend) => json.encode(friend.toJson())).toList();
      await prefs.setStringList('friends', allFriendsJson);
    } catch (e) {
      debugPrint('Error saving friends data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save friends data.')),
      );
    }
  }

  void _deleteFriend(Friend friend) {
    setState(() {
      friendsInEvent.remove(friend);
      paidAmountMap.remove(friend.name);
      oweAmountMap.remove(friend.name);
      dueAmountMap.remove(friend.name);

      _updateTotals();
    });

    _saveFriendsInEvent(); // Save updated data to SharedPreferences
  }

  void _updateTotals() {
    totalOwe = oweAmountMap.values.fold(0.0, (sum, amount) => sum + amount);
    totalDue = dueAmountMap.values.fold(0.0, (sum, amount) => sum + amount);
    totalPaid = paidAmountMap.values.fold(0.0, (sum, amount) => sum + amount);
  }

  void _showAddFriendDialog() {
    Map<String, TextEditingController> paidControllers = {};
    Map<String, TextEditingController> oweControllers = {};
    Map<String, TextEditingController> dueControllers = {};
    Set<int> expandedTiles = {};

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Friend to Event'),
          content: SizedBox(
            width: double.maxFinite,
            child: allFriends.isNotEmpty
                ? StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: allFriends.length,
                  itemBuilder: (context, index) {
                    final friend = allFriends[index];
                    bool isAdded = friendsInEvent.contains(friend);

                    paidControllers.putIfAbsent(friend.name, () => TextEditingController());
                    oweControllers.putIfAbsent(friend.name, () => TextEditingController());
                    dueControllers.putIfAbsent(friend.name, () => TextEditingController());

                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: (friend.avatar != null && friend.avatar!.existsSync())
                                ? FileImage(friend.avatar!)
                                : null,
                            child: (friend.avatar == null || !friend.avatar!.existsSync())
                                ? Text(friend.name[0])
                                : null,
                          ),
                          title: Text(friend.name),
                          subtitle: Text(friend.email),
                          trailing: isAdded ? const Icon(Icons.check, color: Colors.green) : null,
                          onTap: () {
                            setDialogState(() {
                              if (expandedTiles.contains(index)) {
                                expandedTiles.remove(index);
                              } else {
                                expandedTiles.add(index);
                              }
                            });
                          },
                        ),
                        if (expandedTiles.contains(index))
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              children: [
                                TextField(
                                  controller: paidControllers[friend.name],
                                  decoration: const InputDecoration(
                                    labelText: 'Paid',
                                    border: UnderlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: oweControllers[friend.name],
                                  decoration: const InputDecoration(
                                    labelText: 'Owe',
                                    border: UnderlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: dueControllers[friend.name],
                                  decoration: const InputDecoration(
                                    labelText: 'Due',
                                    border: UnderlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      double paidAmount = double.tryParse(paidControllers[friend.name]!.text) ?? 0.0;
                                      double oweAmount = double.tryParse(oweControllers[friend.name]!.text) ?? 0.0;
                                      double dueAmount = double.tryParse(dueControllers[friend.name]!.text) ?? 0.0;

                                      if (paidAmount > 0) {
                                        paidAmountMap[friend.name] = paidAmount;
                                      }
                                      if (oweAmount > 0) {
                                        oweAmountMap[friend.name] = oweAmount;
                                      }
                                      if (dueAmount > 0) {
                                        dueAmountMap[friend.name] = dueAmount;
                                      }

                                      friendsInEvent.add(friend);
                                      _updateTotals();
                                    });

                                    _saveFriendsInEvent();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            )
                : const Text('No friends available to add.'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.cardColor.withOpacity(0.7),
      appBar: AppBar(
        title: Text(eventTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: widget.onDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 20),
            Text(
              eventTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              eventDescription,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            _buildPeopleSection(),
            const SizedBox(height: 20),
            _buildDuesSection(),
            const SizedBox(height: 20),
            _buildOwesSection(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: _showEditEventBottomSheet, // Call to the new bottom sheet dialog function
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0x90CAF9),
            foregroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: const TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
          ),
          child: const Text('Edit Event Details'),
        ),
      ),
    );
  }

  void _showEditEventBottomSheet() {
    TextEditingController nameController = TextEditingController(text: eventTitle);
    TextEditingController descriptionController = TextEditingController(text: eventDescription);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Event Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Event Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Event Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      eventTitle = nameController.text;
                      eventDescription = descriptionController.text;
                    });
                    // Pass updated title and description back to EventRecordScreen
                    Navigator.pop(context);
                    Navigator.pop(context, {
                      'updatedTitle': eventTitle,
                      'updatedDescription': eventDescription,
                    });
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text('Rs. ${totalPaid.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black54, fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Total Paid Amount', style: TextStyle(color: Colors.black)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Owes: Rs.${totalOwe.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
              Text('Dues: Rs.${totalDue.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('People', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              friendsInEvent.isNotEmpty
                  ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: friendsInEvent.length,
                itemBuilder: (context, index) {
                  Friend friend = friendsInEvent[index];
                  double amountPaid = paidAmountMap[friend.name] ?? 0.0;

                  return Column(
                    children: [
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(friend.name, style: const TextStyle(color: Colors.white)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteFriend(friend); // Call the delete method when pressed
                              },
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Amount Paid', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(
                              'Rs.${amountPaid.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Colors.white54),
                    ],
                  );
                },
              )
                  : const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No friends added to the event',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ),
              const Divider(color: Colors.white54), // Divider between the list and the button
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _showAddFriendDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A6BB2),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add Friend to Event'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDuesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('People with Dues', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10),
          child: friendsInEvent.isNotEmpty
              ? Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: friendsInEvent.length,
                itemBuilder: (context, index) {
                  Friend friend = friendsInEvent[index];
                  double amountDue = dueAmountMap[friend.name] ?? 0.0;

                  return Column(
                    children: [
                      ListTile(
                        title: Text(friend.name, style: const TextStyle(color: Colors.white)),
                        trailing: Text(
                          'Due: Rs.${amountDue.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      const Divider(height: 1, color: Colors.white54),
                    ],
                  );
                },
              ),
            ],
          )
              : const Center(
            child: Text(
              'No dues found',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOwesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('People Who Owe', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10),
          child: friendsInEvent.isNotEmpty
              ? Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: friendsInEvent.length,
                itemBuilder: (context, index) {
                  Friend friend = friendsInEvent[index];
                  double owesAmount = oweAmountMap[friend.name] ?? 0.0;

                  return Column(
                    children: [
                      ListTile(
                        title: Text(friend.name, style: const TextStyle(color: Colors.white)),
                        trailing: Text(
                          'Owes: Rs.${owesAmount.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      const Divider(height: 1, color: Colors.white54),
                    ],
                  );
                },
              ),
            ],
          )
              : const Center(
            child: Text(
              'No one owes any amount',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

}


