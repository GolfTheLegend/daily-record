import 'package:daily_record/components/background.dart';
import 'package:flutter/material.dart';

class CreateActivePage extends StatefulWidget {
  const CreateActivePage({super.key});

  @override
  State<CreateActivePage> createState() => _CreateActivePageState();
}

class _CreateActivePageState extends State<CreateActivePage> {
  @override
  Widget build(BuildContext context) {
    return Background(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  "19",
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "กุมภาพันธ์ 2568",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => print("Tapped"),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(7, 12),
                        ),
                      ],
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Center(
                        child: Icon(Icons.add, size: 60, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(color: Colors.blue[100]),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: []),
                SizedBox(width: 5),
                const Text('ถึง',style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                SizedBox(width: 5),
                Row(children: []),
              ],
            ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(color: Colors.blue[200]),
            ),
          ),
        ],
      ),
    );
  }
}
