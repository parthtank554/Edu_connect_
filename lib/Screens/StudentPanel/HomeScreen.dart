import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'CourseDetail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  String? userId;

  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userId = user.uid; // Fetch the userId

        userName = userDoc.data()?['fullName'] ?? 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150.0),
        child: Stack(
          children: [
            _buildAppBarBackground(),
            _buildSearchBar(),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildCourseGrid(),
      ),
    );
  }

  Widget _buildAppBarBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName != null ? "Hi $userName," : "Hi there,",
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                "Welcome back!",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      left: 20.0,
      right: 20.0,
      bottom: 15.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search courses by title',
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.blueAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No courses available.'));
        }

        final courses = snapshot.data!.docs;
        final filteredCourses = courses.where((course) {
          final title = (course['title'] ?? '').toString().toLowerCase();
          return title.contains(searchQuery);
        }).toList();

        if (filteredCourses.isEmpty) {
          return const Center(child: Text('No matching courses found.'));
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            childAspectRatio: 0.75,
          ),
          itemCount: filteredCourses.length,
          itemBuilder: (context, index) {
            var course = filteredCourses[index];
            return _buildCourseCard(course);
          },
        );
      },
    );
  }

  Widget _buildCourseCard(QueryDocumentSnapshot course) {
    final courseId = course.id;
    final courseTitle = course['title'] ?? 'No Title';
    final courseDescription =
        course['description'] ?? 'No Description available';
    final courseCategory = course['category'] ?? 'Uncategorized';
    final coursePrice = course['price'] ?? '0';
    final courseImage = course['image'] ?? '';
    final pdf = course['pdf'];
    final video = course['videoUrl'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(
              courseId: courseId,
              courseTitle: courseTitle,
              courseImage: courseImage,
              courseDescription: courseDescription,
              lectures: [], userId: userId!,
              pdfUrl:pdf ,
              videoUrl: video,
              // quizzes: [],
            ),
          ),
        );
      },
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                child: courseImage.isNotEmpty
                    ? Image.network(
                        courseImage,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.book, size: 50, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    courseCategory,
                    style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                  ),
                  // Text(
                  //   '\$${coursePrice}',
                  //   style: const TextStyle(color: Colors.green, fontSize: 14.0),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
