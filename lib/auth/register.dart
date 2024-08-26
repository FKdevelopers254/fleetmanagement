
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage,}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  bool _isPasswordVisible = false;
  Color _passwordBorderColor = Colors.grey;
  String missingAttributes = '';
  String notificationText = '';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _locationController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose(){


    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _locationController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future signUp() async{
    showDialog(context: context, builder: (context){
      return Center(child: CircularProgressIndicator());

    },
    );

    if(passwordConfirmed()) {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text.trim(),password: _passwordController.text.trim(),);
      addUserDetails(
          _firstnameController.text.trim(),
          _lastnameController.text.trim(),
          _emailController.text.trim(),
          _locationController.text.trim(),
          int.parse(_ageController.text.trim())
      );

    }
    Navigator.of(context).pop();


  }

  Future addUserDetails(String firstname, String lastname,String email, String location, int age) async{


    await FirebaseFirestore.instance.collection('users').add({
      'firstname':firstname,
      'lastname':lastname,
      'email':email,
      'dl':location,
      'phonumber':age,

    }
    );




  }

  bool passwordConfirmed(){
    if(_passwordController.text.trim() == _confirmpasswordController.text.trim()){
      return true;
    }
    else{
      return false;
    }


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                //greetings
                Text('Hello There',
                  style: GoogleFonts.mulish(
                    fontSize: 52,

                  ),
                ),
                SizedBox(height: 10,),
                Text('Register & Become a Member',
                  style: GoogleFonts.mulish(
                    fontSize: 20,
                  ),),
                SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),

                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: TextField(
                        controller: _firstnameController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          hintText: 'First Name',
                          fillColor: Colors.grey[200],
                          filled: true,

                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),

                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: TextField(
                        keyboardType: TextInputType.text,
                        controller: _lastnameController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          hintText: 'Last Name',
                          fillColor: Colors.grey[200],
                          filled: true,

                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),

                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: TextField(
                        keyboardType: TextInputType.text,
                        controller: _locationController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          hintText: 'Driver License No. ',
                          fillColor: Colors.grey[200],
                          filled: true,

                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),

                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _ageController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          hintText: 'Phone Number',
                          fillColor: Colors.grey[200],
                          filled: true,

                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),

                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: TextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          hintText: 'Email',
                          fillColor: Colors.grey[200],
                          filled: true,

                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),

                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: TextField(

                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        onChanged: (password) {
                          setState(() {
                            _passwordBorderColor = _evaluatePasswordStrength(password);
                          });
                        },

                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: _passwordBorderColor),
                            //  borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: _passwordBorderColor),
                              borderRadius: BorderRadius.circular(12),
                            ),


                            hintText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                Text(
                  missingAttributes.isNotEmpty ? 'Missing: $missingAttributes' : '',
                  style: TextStyle(color: _passwordBorderColor),

                ),
                Text(
                  notificationText,
                  style: TextStyle(color: _passwordBorderColor),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),

                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: TextField(
                        controller: _confirmpasswordController,
                        obscureText: !_isPasswordVisible,
                        onChanged: (password) {
                          setState(() {
                            _passwordBorderColor = _evaluatePasswordStrength(password);
                          });
                        },
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: _passwordBorderColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: _passwordBorderColor),
                              borderRadius: BorderRadius.circular(12),
                            ),


                            hintText: 'Confirm Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: signUp,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('A Member?',
                      style: TextStyle(fontWeight: FontWeight.bold,),),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Text('  Sign In', style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),
                  ],
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }


  Color _evaluatePasswordStrength(String password) {
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    String newMissingAttributes = '';
    if (!hasUppercase) {
      newMissingAttributes += 'Uppercase letter, ';
    }
    if (!hasLowercase) {
      newMissingAttributes += 'Lowercase letter, ';
    }
    if (!hasDigits) {
      newMissingAttributes += 'Digit, ';
    }
    if (!hasSpecialCharacters) {
      newMissingAttributes += 'Special character, ';
    }


    if (password.length < 6) {
      notificationText = 'Password must be at least 6 characters long.';
    }

    setState(() {
      missingAttributes = newMissingAttributes.isNotEmpty ? newMissingAttributes.substring(0, newMissingAttributes.length - 2) : '';
    });

    if (password.length < 6 || missingAttributes.isNotEmpty) {
      return Colors.red; // Weak password
    } else if (!hasUppercase || !hasLowercase || !hasDigits || !hasSpecialCharacters) {
      return Colors.orange; // Medium password
    } else {
      return Colors.green; // Strong password
    }
  }







}