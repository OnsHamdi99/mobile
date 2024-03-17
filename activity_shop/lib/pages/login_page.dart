import 'package:activity_shop/services/authservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final credential = await AuthService().signIn(_email, _password);
      if (credential != null) {
        Navigator.pushReplacementNamed(context, '/activites');
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erreur'),
              content: Text('Impossible de se connecter.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Attention'),
            content: Text('Tous les champs doivent être remplis.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Shop'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'login'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer votre login.';
                  }
                  return null;
                },
                onSaved: (newValue) => _email = newValue!,
              ),
              SizedBox(height: 10.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer votre mot de passe.';
                  }
                  return null;
                },
                onSaved: (newValue) => _password = newValue!,
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _signIn,
                child: Text('Se connecter'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: Text('Créer un compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}