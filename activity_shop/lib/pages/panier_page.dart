import 'package:activity_shop/pages/activites_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List<Activity> _activities = [];
  int _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _getCartActivities();
  }

  Future<void> _getCartActivities() async {
    final uid = _firebaseAuth.currentUser!.uid;
    final doc = await _firestore.collection('paniers').doc(uid).get();
    if (doc.exists) {
      final activitiesIds = (doc.data()!['activities'] as List).cast<String>();
      _activities = await Future.wait(activitiesIds.map((id) => _firestore.collection('activites').doc(id).get().then((doc) => Activity.fromFirestore(doc))));
      _calculateTotalPrice();
      setState(() {});
    }
  }

  void _calculateTotalPrice() {
    _totalPrice = 0;
    for (final activity in _activities) {
      _totalPrice += activity.price;
    }
  }


  Future<void> _removeFromCart(Activity activity) async {
    final uid = _firebaseAuth.currentUser!.uid;
    await _firestore.collection('paniers').doc(uid).update({
      'activities': FieldValue.arrayRemove([activity.id]),
    });
    _activities.remove(activity);
    _calculateTotalPrice();
    setState(() {});
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panier'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: _activities.isEmpty
          ? Center(child: Text('Votre panier est vide'))
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: _activities.length,
              separatorBuilder: (context, index) => SizedBox(height: 8.0),
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return Dismissible( // Keep Dismissible for swipe deletion
                  key: Key(activity.id),
                  onDismissed: (_) => _removeFromCart(activity),
                  direction: DismissDirection.endToStart,
                  background: Container(color: Colors.red),
                  child: Row(
                    children: [
                      // Activity image with a fixed size
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          activity.imageUrl,
                          height: 80.0,
                          width: 80.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Activity title
                            Text(
                              activity.titre,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            SizedBox(height: 8.0),
                            // Activity location
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16.0),
                                Text(' ${activity.lieu}'),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            // Activity price
                            Row(
                              children: [
                                Icon(Icons.euro_symbol, size: 16.0),
                                Text(' ${activity.price}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Add a delete icon button
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _removeFromCart(activity),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
// Total price
Text('Total: €$_totalPrice'),

ElevatedButton(
onPressed: () {
Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ActivitiesPage()));
},
child: Text('Retour'),
),
],
),
),
),
);

}
} 