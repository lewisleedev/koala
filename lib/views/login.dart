import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:koala/models/session.dart';
import 'package:koala/views/utils.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

import 'dashboard.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _studentIdController =
      TextEditingController(); // Controller for student ID
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<KoalaSession>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Observer(
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Koala",
                  style: TextStyle(fontSize: 42),
                ),
                const Text(
                  "Kyunghee University Open-source App for Library Access",
                  style: TextStyle(fontSize: 14),
                ),
                AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "아이디를 입력하세요";
                            } else {
                              return null;
                            }
                          },
                          autofillHints: const [AutofillHints.username],
                          autofocus: true,
                          keyboardType: TextInputType.text,
                          controller: _usernameController,
                          decoration: const InputDecoration(labelText: '아이디'),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "비밀번호를 입력하세요";
                            } else {
                              return null;
                            }
                          },
                          autofillHints: const [AutofillHints.password],
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: '비밀번호'),
                          obscureText: true,
                        ),
                        TextFormField(
                          controller: _studentIdController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "학번을 입력하세요";
                            }
                            if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                              return '학번은 10자리 숫자여야합니다';
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(labelText: '학번'),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          "인포21 아이디/비밀번호로 로그인하세요.\n자격 정보는 기기를 떠나지 않습니다.",
                          style: TextStyle(
                              fontSize: 12, color: Theme.of(context).hintColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        session.isLoggedIn?.status == FutureStatus.pending
                            ? const CircularProgressIndicator()
                            : FilledButton.tonalIcon(
                                style: ButtonStyle(minimumSize: MaterialStateProperty.all(const Size(double.infinity, 48))),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      await session.login(
                                        _usernameController.text,
                                        _passwordController.text,
                                        _studentIdController
                                            .text, // Pass the student ID to the login method
                                      );
                                      if (!context.mounted) return ;
                                      showSnackbar(context, "로그인되었습니다!");
                                      session.refreshDashboard();
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const KoalaApp()));
                                    } catch (e) {
                                      showSnackbar(context, e.toString());
                                    }
                                  }
                                },
                                icon: const Icon(Icons.login),
                                label: const Text('Login'),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _studentIdController.dispose(); // Dispose the student ID controller
    super.dispose();
  }
}
