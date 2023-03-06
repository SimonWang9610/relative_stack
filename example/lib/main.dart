import 'package:flutter/material.dart';
import 'package:relative_stack/relative_stack.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const RelativeStackExample(),
    );
  }
}

class RelativeStackExample extends StatelessWidget {
  const RelativeStackExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: RelativeStack(
            // clipBehavior: Clip.hardEdge,
            children: [
              Center(
                child: SizedBox.square(
                  dimension: 300,
                  child: GestureDetector(
                    onTap: () {
                      print("tap non relative widget");
                    },
                    child: ColoredBox(color: Colors.green),
                  ),
                ),
              ),
              RelativePositioned(
                id: 1,
                preferSize: const Size.square(150),
                targetAnchor: Alignment.center,
                followAnchor: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    print("tap: 1");
                  },
                  child: ColoredBox(color: Colors.red),
                ),
              ),
              RelativePositioned(
                id: 2,
                relativeTo: 1,
                followAnchor: Alignment.bottomRight,
                // shift: Offset(10, 10),
                preferSize: Size.square(100),
                child: GestureDetector(
                  onTap: () {
                    print("tap: 2");
                  },
                  child: ColoredBox(color: Colors.yellow),
                ),
              ),
              RelativePositioned(
                id: 3,
                relativeTo: 1,
                targetAnchor: Alignment.center,
                preferSize: Size(100, 50),
                shift: Offset(-10, 10),
                child: GestureDetector(
                  onTap: () {
                    print("tap: 3");
                  },
                  child: ColoredBox(color: Colors.blue),
                ),
              ),
              RelativePositioned(
                id: 4,
                // relativeTo: 1,
                targetAnchor: Alignment.topRight,
                followAnchor: Alignment.topRight,
                preferSize: Size.square(100),
                child: GestureDetector(
                  onTap: () {
                    print("tap: 4");
                  },
                  child: ColoredBox(color: Colors.black),
                ),
              ),
              RelativePositioned(
                id: 5,
                relativeTo: 1,
                targetAnchor: Alignment.bottomCenter,
                followAnchor: Alignment.topCenter,
                preferSize: Size.square(80),
                child: GestureDetector(
                  onTap: () {
                    print("tap: 5");
                  },
                  child: ColoredBox(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
