import 'package:coupown_admin/Const/app_colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DealsOfTheDay extends StatefulWidget {
  static const String id = "\webPageAdvertisementList";
  const DealsOfTheDay({super.key});

  @override
  _DealsOfTheDayState createState() => _DealsOfTheDayState();
}

class _DealsOfTheDayState extends State<DealsOfTheDay> {
  final DatabaseReference _adsRef = FirebaseDatabase.instance.ref('advertisements/deals_of_the_day_ad');
  List<Map<String, dynamic>> _advertisements = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAdvertisements();
  }

  // Fetch advertisements
  void _fetchAdvertisements() {
    setState(() => _isLoading = true);
    _adsRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final ads = data.entries.map((entry) {
          final ad = entry.value as Map<dynamic, dynamic>;
          return {
            'id': entry.key,
            'companyName': ad['companyname'] ?? '',
            'fromDate': ad['fromDate'] ?? '',
            'toDate': ad['toDate'] ?? '',
            'phone': ad['phone'] ?? '',
            'selectedImage': ad['selectedImage'] ?? '',
            'selectedOption': ad['selectedOption'] ?? '',
            'webLink': ad['webLink'] ?? '',
          };
        }).toList();

        // Remove expired ads
        ads.removeWhere((ad) => _isExpired(ad['toDate']));
        setState(() {
          _advertisements = ads;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  // Check if an ad has expired
  bool _isExpired(String toDate) {
    try {
      final expiryDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(toDate.split('>').first.trim());
      return DateTime.now().isAfter(expiryDate);
    } catch (_) {
      return false;
    }
  }

  // Edit advertisement
  void _editAdvertisement(String adId, Map<String, dynamic> adData) {
    final controllers = {
      'companyName': TextEditingController(text: adData['companyName']),
      'fromDate': TextEditingController(text: adData['fromDate']),
      'toDate': TextEditingController(text: adData['toDate']),
      'phone': TextEditingController(text: adData['phone']),
      'selectedOption': TextEditingController(text: adData['selectedOption']),
      'webLink': TextEditingController(text: adData['webLink']),
      'selectedImage': TextEditingController(text: adData['selectedImage']),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Advertisement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: controllers.entries
                .map((entry) => TextField(controller: entry.value, decoration: InputDecoration(labelText: entry.key)))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final updates = controllers.map((key, controller) => MapEntry(key, controller.text));
              _adsRef.child(adId).update(updates).then((_) {
                Navigator.pop(context);
                _fetchAdvertisements();
              });
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Delete advertisement
  void _deleteAdvertisement(String adId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Advertisement'),
        content: const Text('Are you sure you want to delete this advertisement?'),
        actions: [
          TextButton(
            onPressed: () {
              _adsRef.child(adId).remove().then((_) => _fetchAdvertisements());
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort advertisements by 'fromDate'
    _advertisements.sort((a, b) => DateTime.parse(b['fromDate']).compareTo(DateTime.parse(a['fromDate'])));

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _advertisements.length,
            itemBuilder: (context, index) {
              final ad = _advertisements[index];
              return Card(
                elevation: 5,
                color: _isExpired(ad['toDate']) ? Colors.grey[100] : Colors.blueGrey,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: ad['selectedImage'] != null
                      ? Image.network(ad['selectedImage'], width: 100, height: 50, fit: BoxFit.fill)
                      : const SizedBox.shrink(),
                  title: Text('Company Name: ${ad['companyName']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Option: ${ad['selectedOption']}'),
                      Text('From: ${ad['fromDate']}'),
                      Text('To: ${ad['toDate']}'),
                      Text('Phone: ${ad['phone']}'),
                      Text('Link: ${ad['webLink']}'),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _editAdvertisement(ad['id'], ad)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteAdvertisement(ad['id'])),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
