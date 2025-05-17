import 'package:flutter/material.dart';

import '../../Custom_Widgets/GradientButton.dart';

class ChangeTemplateScreen extends StatelessWidget {
  final List<String> templatePaths = [
    'assets/template1.png',
    'assets/template2.png',
    'assets/template3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Change Certificate Template"),),
      body: 
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.black54,
                    indicatorColor: Colors.blue,
                    tabs: [
                      Tab(text: 'Pre-designed'),
                      Tab(text: 'Upload Custom'),
                    ],
                  ),
                  SizedBox(
                    height: 500, // Height for tab content
                    child: TabBarView(
                      children: [
                        // Pre-designed Templates Grid
                        GridView.builder(
                          padding: EdgeInsets.all(8),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: templatePaths.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Show template preview or selection logic
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    templatePaths[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
      
                        // Upload Custom Template
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Upload custom template logic
                            },
                            icon: Icon(Icons.upload_file),
                            label: Text('Upload Custom Template'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 24),
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            // Apply Button

             Padding(
               padding: const EdgeInsets.all(8.0),
               child: GradientButton(
                  buttonText: 'Apply Template',
                  onPressed: () {
                    // Save course details to database (e.g., Firebase)
                  },
                  gradientColors: [Colors.blue, Colors.blueAccent], label: '',child: Text(""), 
                ),
             )
    ],
              ),
    ));
  }
}
