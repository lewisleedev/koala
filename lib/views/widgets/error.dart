import 'package:flutter/material.dart';

class ErrorBox extends StatelessWidget {
  final String errMsg;

  const ErrorBox({super.key, required this.errMsg});
  
  @override build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Something went wrong", style: TextStyle(fontSize: 24),),
          const SizedBox(height: 6,),
          ExpansionTile(title: const Text("Full error"), shape: LinearBorder.none, children: [Text(errMsg)],),
          Text("Try refreshing or reporting the error via Github!", style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),),
        ],
      ),
    );
  }
}

class ErrorCantConnect extends StatelessWidget {
  const ErrorCantConnect({super.key});

  @override build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Can't connect to the server", style: TextStyle(fontSize: 24),),
            SizedBox(height: 6),
            Text("This is likely because you have no Internet access or the server is having some issue")
          ],
        ),
      ),
    );
  }
}
