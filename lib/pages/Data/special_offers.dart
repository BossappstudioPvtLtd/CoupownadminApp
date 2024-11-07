import 'package:coupown_admin/Const/app_colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpecialOffers extends StatefulWidget {
  static const String id = "\webPageAdvertisementList";
  const SpecialOffers({super.key});

  @override
  _SpecialOffersState createState() => _SpecialOffersState();
}

class _SpecialOffersState extends State<SpecialOffers> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('advertisements/special_offers_ad');
  late DatabaseReference _adsRef;
  List<Map<String, dynamic>> _advertisements = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _adsRef = _dbRef;
    _fetchAdvertisements();
  }

  // Fetch advertisements from Firebase Realtime Database
  void _fetchAdvertisements() {
    setState(() {
      _isLoading = true; // Set loading to true when the fetch begins
    });

    _adsRef.onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.exists) {
        var data = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> ads = [];
        data.forEach((key, value) {
          ads.add({
            'id':
                key, // Add the advertisement ID for identifying each advertisement
            'companyName': value['companyname'] ?? '',
            'fromDate': value['fromDate'] ?? '',
            'toDate': value['toDate'] ?? '',
            'phone': value['phone'] ?? '',
            'selectedImage': value['selectedImage'] ?? '',
            'selectedOption': value['selectedOption'] ?? '',
            'webLink': value['webLink'] ?? '',
          });
        });

        // Create a list of ads that need to be removed (expired ads)
        List<String> expiredAds = [];
        ads.forEach((ad) {
          if (_isExpired(ad['toDate'])) {
            expiredAds.add(ad['id']); // Add the expired ad's ID to the list
          }
        });

        // Remove expired ads
        if (expiredAds.isNotEmpty) {
          Future.forEach(expiredAds, (adId) async {
            await _adsRef.child(adId).remove().then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expired advertisement deleted')),
              );
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to delete expired ad: $error')),
              );
            });
          }).then((_) {
            // After removing all expired ads, refresh the list of valid advertisements
            setState(() {
              _advertisements =
                  ads.where((ad) => !_isExpired(ad['toDate'])).toList();
              _isLoading = false; // Set loading to false when done
            });
          });
        } else {
          // If no expired ads were found, just update the list
          setState(() {
            _advertisements = ads;
            _isLoading = false; // Set loading to false when done
          });
        }
      } else {
        setState(() {
          _isLoading = false; // Set loading to false if no data found
        });
      }
    });
  }

  // Check if the advertisement has expired
  bool _isExpired(String toDate) {
    // Clean the string by removing the extra characters and trimming
    String cleanedDate = toDate
        .split('>')[0]
        .trim(); // Assuming '>' is part of the unwanted format

    // Now parse the cleaned date string
    try {
      final currentDate = DateTime.now();
      final expiryDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(cleanedDate);

      // Check if current time is after the expiry date or the same
      return currentDate.isAfter(expiryDate) ||
          currentDate.isAtSameMomentAs(expiryDate);
    } catch (e) {
      // Handle parsing error gracefully, maybe log the error or return false
      debugPrint('Error parsing date: $e');
      return false; // Assume the date is not expired in case of error
    }
  }

  // Edit an advertisement
  void _editAdvertisement(String adId, Map<String, dynamic> adData) {
    final companyNameController =
        TextEditingController(text: adData['companyName']);
    final fromDateController = TextEditingController(text: adData['fromDate']);
    final toDateController = TextEditingController(text: adData['toDate']);
    final phoneController = TextEditingController(text: adData['phone']);
    final selectedOptionController =
        TextEditingController(text: adData['selectedOption']);
    final webLinkController = TextEditingController(text: adData['webLink']);
    final selectedImageController =
        TextEditingController(text: adData['selectedImage']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Advertisement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: companyNameController,
                  decoration: const InputDecoration(labelText: 'Company Name'),
                ),
                TextField(
                  controller: fromDateController,
                  decoration: const InputDecoration(
                      labelText: 'From Date (YYYY-MM-DD)'),
                ),
                TextField(
                  controller: toDateController,
                  decoration:
                      const InputDecoration(labelText: 'To Date (YYYY-MM-DD)'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: selectedOptionController,
                  decoration:
                      const InputDecoration(labelText: 'Selected Option'),
                ),
                TextField(
                  controller: webLinkController,
                  decoration: const InputDecoration(labelText: 'Web Link'),
                ),
                TextField(
                  controller: selectedImageController,
                  decoration:
                      const InputDecoration(labelText: 'Selected Image URL'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Update the advertisement in Firebase with the new data
                _adsRef.child(adId).update({
                  'companyname': companyNameController.text,
                  'fromDate': fromDateController.text,
                  'toDate': toDateController.text,
                  'phone': phoneController.text,
                  'selectedOption': selectedOptionController.text,
                  'webLink': webLinkController.text,
                  'selectedImage': selectedImageController.text,
                }).then((_) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Advertisement updated successfully!')),
                  );
                  _fetchAdvertisements(); // Refresh the list after update
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Failed to update advertisement: $error')),
                  );
                });
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Delete an advertisement
  void _deleteAdvertisement(String adId) {
    // Show a confirmation dialog before deleting

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Advertisement'),
          content:
              const Text('Are you sure you want to delete this advertisement?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await _adsRef
                    .child(adId)
                    .remove(); // Delete the advertisement from Firebase
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Advertisement deleted successfully!')),
                );
                _fetchAdvertisements(); // Refresh the list after deletion
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort the advertisements by 'fromDate' in descending order
    _advertisements.sort((a, b) {
      DateTime fromDateA = DateTime.parse(a['fromDate']); // Parse fromDate
      DateTime fromDateB = DateTime.parse(b['fromDate']); // Parse fromDate
      return fromDateB.compareTo(fromDateA); // Sort in descending order
    });

    return _advertisements.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _advertisements.length,
            itemBuilder: (context, index) {
              final ad = _advertisements[index];
              bool expired =
                  _isExpired(ad['toDate']); // Check if the ad is expired
              return Card(
                elevation: 5,
                color: expired
                    ? Colors.grey[100]
                    : Colors.blueGrey, // Change color if expired
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      // Display the image only if it exists
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ad['selectedImage'] != null
                            ? Image.network(
                                ad['selectedImage'],
                                width: 100,
                                height: 50,
                                fit: BoxFit.fill,
                              )
                            : const SizedBox.shrink(),
                      ),
                      // Wrap the Column with Expanded to avoid overflow
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Company Name: ${ad['companyName']}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: appColorPrimary),
                              overflow: TextOverflow
                                  .ellipsis, // Prevents overflow if the text is too long
                              maxLines: 2, // Limits the text to two lines
                            ),
                            Text(
                              'Option: ${ad['selectedOption']}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: appColorPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text('From: ${ad['fromDate']}',
                                style: const TextStyle(
                                    color: appDark_parrot_green)),
                            Text('To: ${ad['toDate']}',
                                style: TextStyle(
                                    color: expired ? Colors.red : appDarkRed,
                                    fontWeight: FontWeight.bold)),
                            Text('Phone: ${ad['phone']}',
                                style: const TextStyle(color: appColorPrimary)),
                            Text('Link: ${ad['webLink']}',
                                style: const TextStyle(color: appColorPrimary)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      _editAdvertisement(ad['id'], ad),
                                  icon: const Icon(Icons.edit),
                                  color: appColorPrimary,
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _deleteAdvertisement(ad['id']),
                                  icon: const Icon(Icons.delete),
                                  color: appDarkRed,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
