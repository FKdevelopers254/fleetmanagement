import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'forgotpassword.dart';
import 'glassbox.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async{


//show  indicator

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }on FirebaseAuthException catch (e){
      if (kDebugMode) {
        print(e);
      }
      showDialog(
          context:context,
          builder: (context){
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          }
      );
    }

    //showDialog(context: context, builder: (context){
    //  return const Center(child: CircularProgressIndicator());

    // },
    // );
    // Navigator.of(context).pop();
    
  }


  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
         //   backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('lib/assets/homepage.jpg',),fit: BoxFit.cover),
          ),
          child: GlassBoxxx(
            child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText('Matatu Management System',textStyle: GoogleFonts.abrilFatface(fontSize:28,fontWeight:FontWeight.bold,color: Colors.white)),
                      TyperAnimatedText('GPS Tracking App',textStyle: GoogleFonts.abrilFatface(fontSize:28,fontWeight:FontWeight.bold,color: Colors.white)),
                              
                      //   TyperAnimatedText('',textStyle: GoogleFonts.bebasNeue(fontSize:28,color: Colors.white)),
                              
                      //    TyperAnimatedText('WE GOT you!!',textStyle: GoogleFonts.bebasNeue(fontSize:28,color: Colors.white)),
                              
                    ],
                    pause: const Duration(milliseconds: 8000),
                              
                    stopPauseOnTap: true,
                    repeatForever: true,
                  ),
                ),
                //greetings

                const SizedBox(height: 10,),
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
                        controller:_emailController,
                        decoration: InputDecoration(
            
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(12),
                            ),
            
                            hintText: 'Email'
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
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
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.deepPurple),
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
                      )
                      ,
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return const ForgotPasswordPage();
                          }));
                        },
                        child: const Text('Forgot Password?',style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold,
                        ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
            
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: signIn,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepOrangeAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Sign In',
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
                const SizedBox(height: 25,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a Member?',style: TextStyle(fontWeight: FontWeight.bold,),),
                    GestureDetector(
                      onTap: widget.showRegisterPage,
                      child: const Text(' Register now', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold,
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
}
