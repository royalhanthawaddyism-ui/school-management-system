import 'package:flutter/material.dart';

class YearList extends StatelessWidget {
  const YearList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Color List')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.palette, size: 64, color: Colors.purple),
            SizedBox(height: 16),
            Text(
              'Here is your Color List Page!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
