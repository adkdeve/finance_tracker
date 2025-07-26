import 'package:finance_recorder/screens/EventDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventRecordScreen extends StatefulWidget {
  const EventRecordScreen({Key? key}) : super(key: key);

  @override
  _EventRecordScreenState createState() => _EventRecordScreenState();
}

class _EventRecordScreenState extends State<EventRecordScreen> {
  List<Map<String, String>> eventList = [];
  final List<Color> colorPalette = [
    Colors.pinkAccent.withOpacity(0.5),
    Colors.lightBlueAccent.withOpacity(0.5),
    Colors.lightGreenAccent.withOpacity(0.5),
    Colors.orangeAccent.withOpacity(0.5),
    Colors.purpleAccent.withOpacity(0.5),
    Colors.yellowAccent.withOpacity(0.5),
    Colors.tealAccent.withOpacity(0.5),
    Colors.redAccent.withOpacity(0.5),
    Colors.cyanAccent.withOpacity(0.5),
    Colors.amberAccent.withOpacity(0.5),
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? loadedEvents = prefs.getStringList('eventList');
    setState(() {
      eventList = loadedEvents?.map((eventString) {
        final parts = eventString.split('|');
        return {
          'title': parts[0],
          'timestamp': parts[1],
          'description': parts.length > 2 ? parts[2] : '',
        };
      }).toList() ??
          [];
    });
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> eventStrings = eventList
        .map((event) => '${event['title']}|${event['timestamp']}|${event['description']}')
        .toList();
    await prefs.setStringList('eventList', eventStrings);
  }

  void _showAddEventBottomSheet() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Event',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.grey),
                      onPressed: () {
                        Navigator.pop(context); // Close the bottom sheet
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
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
                    if (titleController.text.isNotEmpty) {
                      setState(() {
                        eventList.add({
                          'title': titleController.text,
                          'timestamp': DateTime.now().toString(),
                          'description': descriptionController.text,
                        });
                        _saveEvents();
                      });
                      Navigator.pop(context); // Close the bottom sheet
                    }
                  },
                  child: const Text('Add Event'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Records'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: eventList.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            if (index == eventList.length) {
              return _buildAddEventCard();
            } else {
              return _buildEventCard(index);
            }
          },
        ),
      ),
    );
  }

  Widget _buildAddEventCard() {
    return Card(
      key: const ValueKey('add-new-event'),
      color: Colors.blueAccent.withOpacity(0.3),
      child: InkWell(
        onTap: _showAddEventBottomSheet,
        child: const Center(
          child: Icon(
            Icons.add,
            size: 48,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(int index) {
    return Card(
      key: ValueKey(eventList[index]['title']),
      color: colorPalette[index % colorPalette.length],
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(
                eventTitle: eventList[index]['title']!,
                eventDescription: eventList[index]['description']!,
                cardColor: colorPalette[index % colorPalette.length],
                onDelete: () {
                  setState(() {
                    eventList.removeAt(index);
                    _saveEvents();
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          );

          // Check if result contains updated title and description
          if (result != null && result is Map<String, String>) {
            setState(() {
              eventList[index]['title'] = result['updatedTitle']!;
              eventList[index]['description'] = result['updatedDescription']!;
              _saveEvents();
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                eventList[index]['title']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                eventList[index]['description']!,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Created on: ${DateTime.parse(eventList[index]['timestamp']!).toLocal()}'.split('.')[0],
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
