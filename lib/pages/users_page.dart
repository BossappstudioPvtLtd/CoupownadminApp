import 'package:coupown_admin/Const/app_colors.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  static const String id = "\webPageUsers";

  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  // Sample data for users
  final List<Map<String, String>> users = [
    {"userID": "1", "userName": "John Doe", "phone": "123-456-7890"},
    {"userID": "2", "userName": "Jane Smith", "phone": "987-654-3210"},
    {"userID": "3", "userName": "Alice Johnson", "phone": "555-123-4567"},
    {"userID": "4", "userName": "Bob Brown", "phone": "555-987-6543"},
    {"userID": "5", "userName": "Charlie Davis", "phone": "555-678-1234"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColorPrimary,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Manage Users",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              // Responsive table
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    // For smaller screens, show a horizontally scrollable table
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        
                        columns: const [
                          DataColumn(
                            label: Text(
                              'User ID',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'User Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Phone',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Action',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        rows: users.map(
                          (user) {
                            return DataRow(
                              cells: [
                                DataCell(Text(user['userID']!)),
                                DataCell(Text(user['userName']!)),
                                DataCell(Text(user['phone']!)),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          // Handle edit action
                                          print('Editing user: ${user['userName']}');
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          // Handle delete action
                                          print('Deleting user: ${user['userName']}');
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ).toList(),
                      ),
                    );
                  } else {
                    // For larger screens, show the normal table without scroll
                    return DataTable(
                      columns: const [
                        DataColumn(
                          label: Text(
                            'User ID',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'User Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Phone',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Action',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      rows: users.map(
                        (user) {
                          return DataRow(
                            cells: [
                              DataCell(Text(user['userID']!)),
                              DataCell(Text(user['userName']!)),
                              DataCell(Text(user['phone']!)),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        // Handle edit action
                                        print('Editing user: ${user['userName']}');
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        // Handle delete action
                                        print('Deleting user: ${user['userName']}');
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
