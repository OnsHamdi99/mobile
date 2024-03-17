import 'package:activity_shop/pages/activites_detail_page.dart';
import 'package:activity_shop/pages/panier_page.dart';
import 'package:activity_shop/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivitiesPage extends StatefulWidget {
  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Activity> _allActivities = []; 
  List<Activity> _filteredActivities = []; 
  String _selectedCategory = "Toutes"; 

  @override
  void initState() {
    super.initState();
    _getActivities();
  }

  void _getActivities() async {
    final activitiesQuery = await _firestore.collection('activites').get();
    _allActivities = activitiesQuery.docs.map((doc) => Activity.fromFirestore(doc)).toList();
    _filteredActivities = _allActivities;
    setState(() {});
  }

void _onCategorySelected(String category) {
  _selectedCategory = category;
  _filteredActivities = category == "Toutes"
    ? _allActivities // Show all activities for "Toutes"
    : _allActivities.where((activity) => activity.categorie == category).toList(); // Filter for specific category
  setState(() {});
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activités'),
        centerTitle: true,
        backgroundColor: Colors.green,
        bottom: PreferredSize(
          child: DefaultTabController(
            length: _getCategories().length, 
            child: TabBar(
              isScrollable: true, 
              labelColor: Colors.white,
              unselectedLabelColor: Color.fromARGB(255, 83, 83, 83),
              onTap: (index) => _onCategorySelected(_getCategories()[index]),
              tabs: _getCategories().map((category) => Text(category)).toList(),
            ),
          ),
          preferredSize: Size.fromHeight(40.0), 
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _filteredActivities.length,
              itemBuilder: (context, index) {
                final activity = _filteredActivities[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityDetailsPage(activityId: activity.id),
                    ),
                  ),
                  child: Card(
                    child: ListTile(
                      leading: Image.network(activity.imageUrl),
                      title: Text(activity.titre),
                      subtitle: Text('${activity.lieu} - ${activity.price}€'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
              break;
            case 2:
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilPage()), 
            
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Activités',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );

}

    List<String> _getCategories() {
    final categories = _allActivities.map((activity) => activity.categorie).toSet().toList();
    categories.sort(); 
    categories.insert(0, "Toutes"); 
    return categories;
  }
}

class Activity {
  final String id;
  final String titre;
  final String lieu;
  final String imageUrl;
  final int price;
  final int nombreMax;
  final String categorie;

  Activity({
    required this.id,
    required this.titre,
    required this.lieu,
    required this.imageUrl,
    required this.price,
    required this.nombreMax,
    required this.categorie,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    return Activity(
      id: doc.id,
      titre: doc['titre'],
      lieu: doc['lieu'],
      imageUrl: doc['image'],
      price: doc['prix'],
      nombreMax: doc['nombreMax'],
      categorie: doc['categorie'],
    );
  }
}
