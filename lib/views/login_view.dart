import 'package:flutter/material.dart';
import 'package:koala/services/login.dart';
import 'package:koala/views/main_view.dart';
import 'package:koala/widgets/home_tooltips.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _studentId = '';

  Future<void> _login() async {
    if (_username == '' || _password == '' || _studentId == '') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill in the entire form"),
          duration: Duration(seconds: 3)));
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Loading..."),
              ],
            ),
          ),
        );
      },
    );
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> loginRes =
          await loginHandler(_username, _password, _studentId);
      if (!context.mounted) return;
      if (loginRes['result'] == 1) {
        if (!context.mounted) return;
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainWidget(),
          ),
        );
      } else {
        if (!context.mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Login Failed"), duration: Duration(seconds: 3)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Login"),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 120),
                const Text("KOALA", style: TextStyle(fontSize: 25)),
                const Text("KHU's Opensouce App for Library Access",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                    )),
                const SizedBox(height: 15),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder()),
                        autofillHints: const [AutofillHints.username],
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _username = value;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder()),
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _password = value;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Student Number',
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your student number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _studentId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const HomeTooltipButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
