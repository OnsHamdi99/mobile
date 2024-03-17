import 'package:activity_shop/pages/activites_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ActivityDetailsPage extends StatefulWidget {
  final String activityId;

  const ActivityDetailsPage({super.key, required this.activityId});

  @override
  State<ActivityDetailsPage> createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  

  Future<Activity?> _getActivityDetails() async {
    final docSnapshot = await _firestore.collection('activites').doc(widget.activityId).get();
    if (docSnapshot.exists) {
      return Activity.fromFirestore(docSnapshot);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activité'),
           centerTitle: true,
              backgroundColor: Colors.green,
      ),
      body: FutureBuilder<Activity?>(
        future: _getActivityDetails(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final activity = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.network(activity.imageUrl),
                    SizedBox(height: 16.0),
                    Text(
                      activity.titre,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Text('Catégorie: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(activity.categorie),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16.0),
                        Text(' ${activity.lieu}'),
                        Spacer(),
                        Icon(Icons.group, size: 16.0),
                        Text(' Max: ${activity.nombreMax}'),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(Icons.euro_symbol, size: 16.0),
                        Text(' ${activity.price}'),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Retour'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _addToCart(activity);
                          },
                          child: Text('Ajouter au panier'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
  
            return Text('Error: ${snapshot.error}');
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
  
   Future<void> _addToCart(Activity activity) async {

try {

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final cartDoc = _firestore.collection('paniers').doc(uid);
    await cartDoc.get().then((doc) async {
      if (!doc.exists) {
        await cartDoc.set({
          'activities': FieldValue.arrayUnion([]), 
        });
      }
    });
    await _firestore.collection('paniers').doc(uid).update({
      'activities': FieldValue.arrayUnion([activity.id])
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Activité ajoutée au panier')),
    );
  } catch (error) {
    print('Error adding to cart: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur lors de l\'ajout au panier')),
    );
  }
}
}