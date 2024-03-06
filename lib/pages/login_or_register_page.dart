import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modernlogintute/pages/menu.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _googleSignIn = GoogleSignIn();

  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  Future<void> _signInWithEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // Navigate to the home page or other relevant screen
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const menu()),
        ); // Replace '/menu' with your desired route
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message!),
          ),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      // Navigate to the home page or other relevant screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const menu()),
      ); // Replace '/menu' with your desired route
    }
  }

  // Registration form fields and logic (replace with your implementation)
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Send verification email (optional, based on your requirements)
        await userCredential.user!.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
         content: Text('A verification email has been sent to your email address.'),
         ),
        );

        // Proceed to home screen or other relevant logic
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const menu()),
        ); // Replace '/menu' with your desired route
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message!),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(showLoginPage ? 'Login' : 'Register'),
        ),
        body: Padding(
        padding: const EdgeInsets.all(20.0),
    child: Form(
    key: _formKey,
    child: SingleChildScrollView( // Allow scrolling if necessary
    child: Column(
    children: [
    // Login or Register specific fields based on showLoginPage
    if (showLoginPage) ...[
    TextFormField(
    controller: _emailController,
    decoration: const InputDecoration(labelText: 'Email'),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your email address.';
    }
    return null;
    },
    ),
    const SizedBox(height: 10.0),
    TextFormField(
    controller: _passwordController,
    decoration: const InputDecoration(labelText: 'Password'),
    obscureText: true,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your password';}
    },
    ),
    const SizedBox(height: 20.0),
    ElevatedButton(
    onPressed: _signInWithEmail,
    child: const Text('Login with Email'),
    ),
    const SizedBox(height: 10.0),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    GestureDetector(
    onTap: _signInWithGoogle,
    child: Container(
    padding: const EdgeInsets.all(10.0),
    child: Image.asset('lib/images/google.png',
    width: 40.0,
    height: 40.0,
    ),
    ),
    ),
    ],
    ),
    ] else ...[
    // Registration form fields
    TextFormField(
    controller: _nameController,
    decoration: const InputDecoration(labelText: 'Name'),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your name.';
    }
    return null;
    },
    ),
    const SizedBox(height: 10.0),
    TextFormField(
    controller: _emailController,
    decoration: const InputDecoration(labelText: 'Email'),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your email address.';
    }
    return null;
    },
    ),
    const SizedBox(height: 10.0),
    TextFormField(
    controller: _passwordController,
    decoration: const InputDecoration(labelText: 'Password'),
    obscureText: true,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your password.';
    }
    return null;
    },
    ),
    const SizedBox(height: 10.0),
    TextFormField(
    controller: _confirmPasswordController,
    decoration: const InputDecoration(labelText: 'Confirm Password'),
    obscureText: true,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please confirm your password.';
    } else if (value != _passwordController.text) {
    return 'Passwords do not match.';
    }
    return null;
    },
    ),
    const SizedBox(height: 20.0),
    ElevatedButton(
    onPressed: _registerUser,
    child: const Text('Register'),
    ),
    ],
    TextButton(
    onPressed: togglePages,
    child: Text(showLoginPage ? 'Register' : 'Already have an account? Login'),
    ),
    ],
    ),
    ),
    ),
    ),
    );
    }
  }
