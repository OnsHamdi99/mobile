import 'package:activity_shop/services/authservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _firebaseAuth = FirebaseAuth.instance;

  String _password = '';
  String _login = '';
  String _anniversaire = '';
  String _adresse = '';
  int _codePostal = 0;
  String _ville = '';
  var _isLoading = true;
  
  var _authService = AuthService(); 

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final uid = _firebaseAuth.currentUser!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();

  if (doc.exists) {
      setState(() {
        _password = doc['password'];
        _login = doc['email'];
        _anniversaire = doc['anniversaire'];
        _adresse = doc['adresse'];
        _codePostal = doc['code_postal'];
        _ville = doc['ville'];

      });
        _isLoading = false;
    }
  

    if (!doc.exists) {
      final user = _firebaseAuth.currentUser!;
      await _firestore.collection('users').doc(uid).set({
        'email': user.email,
        'password': "password1234",
        'anniversaire': "10/12/1995",
        'adresse': "1 rue de la paix",
        'code_postal': 12345,
        'ville':"Nice",
      });
         _isLoading = false;
    }


  }

  Future<void> _saveUserData() async {
    final uid = _firebaseAuth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).update({
      'anniversaire': _anniversaire,
      'adresse': _adresse,
      'code_postal': _codePostal,
      'ville': _ville,
    });
  }

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()):Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _login,
      
                decoration: InputDecoration(labelText: 'Login'),
                readOnly: true,
              ),
              TextFormField(
                initialValue: _password,
                decoration: InputDecoration(labelText: 'Password'),
                readOnly: true, 
                obscureText: true,
              ),

              TextFormField(
                initialValue: _adresse,
                decoration: InputDecoration(labelText: 'Adresse'),
                onSaved: (value) => _adresse = value!,
              ),
              TextFormField(
  validator: (value) {
    if (RegExp(r'^[0-9]+$').hasMatch(value!)) {
      return null;
    } else {
      return 'Le code postal doit être un nombre entier.';
    }
  },
  decoration: InputDecoration(labelText: 'Code postal'),
  onSaved: (value) => _codePostal = int.parse(value!),
),
              TextFormField(
                initialValue: _ville,
                decoration: InputDecoration(labelText: 'Ville'),
                onSaved: (value) => _ville = value!,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await _saveUserData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profil mis à jour')),
                    );

                  }
                },
                child: Text('Enregistrer'),
              ),
              ElevatedButton(
  onPressed: () async {
    await _authService.signOut();
    Navigator.pushReplacementNamed(context, '/');
  },
  child: Text('Se déconnecter'),
),
            ],
          ),
        ),
      ),
    );
  }
  
}