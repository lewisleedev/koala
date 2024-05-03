import 'package:flutter/material.dart';

class KoalaCard extends StatelessWidget{
  final Widget child;
  final double? height;

  const KoalaCard({super.key, required this.child, this.height});

  @override build(BuildContext context) {
    return  Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: child
          ),
    );
  }
}