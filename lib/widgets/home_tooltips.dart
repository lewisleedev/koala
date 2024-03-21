import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/utils.dart';

class HomeTooltipButton extends StatelessWidget {
  const HomeTooltipButton({super.key});
  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: () {
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: const Text("How does Koala work?"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const Text(("""
Koala serves as an alternative frontend to the library website. It is functionally equivalent to logging in via a web browser, with the added benefit of making far fewer requests during the process.
             
Koala is a FOSS (Free and Open Source Software) project, meaning that you can read or possibly contribute to the source code itself. If you have doubts, you can always read the source code and build it yourself.
            
Koala requires no other permission than Internet access. It also does not send any data to any third party other than the school library server. Your credentials, which require constant access for the auto-login feature, are stored securely using the also open-sourced Hive's encrypted storage.

It is currently (and most likely will continue to be) impossible to turn off the auto-login feature, as it would be incredibly tedious to log in every time a session expires.  
            
Student number and username are two different thing that needs to be provided both separately. Student number is required separately during library seat service login.
            
For more information, read README.md at the repository.
            """)),
                TextButton(onPressed: () async {
                  const url = 'https://github.com/lewisleedev/koala';
                  if (!await launchUrl(Uri.parse(url))) {
                  if (!context.mounted) return;
                  showSnackbar(context, 'Can\'t launch url');
                  }
                }, child: const Text("Github Repository"))
              ],
            ),
          ),
        );
      });
    }, child: const Text("How does this work?"));
  }
}