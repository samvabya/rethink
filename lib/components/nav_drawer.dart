import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:rethink/screens/genai_screen.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 200,
            padding: EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Image.asset(
                'assets/rethink.png',
                height: 25,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
          ListTile(
            title: Text('New Chat'),
            onTap: () {
              Navigator.pop(context);
            },
            leading: Icon(Icons.add),
          ),
          // ListTile(
          //   title: Text('Incognito Chat'),
          //   onTap: () {},
          //   leading: Icon(Icons.visibility_off_outlined),
          // ),
          ListTile(
            title: AnimatedTextKit(
              totalRepeatCount: 1,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GenAIScreen()),
                );
              },
              animatedTexts: [
                ColorizeAnimatedText(
                  speed: Duration(milliseconds: 500),
                  'Generative AI',
                  textStyle: const TextStyle(fontSize: 16),
                  colors: [
                    Theme.of(context).colorScheme.onSecondary,
                    Colors.purple,
                    Colors.blue,
                    Theme.of(context).colorScheme.onSecondary,
                  ],
                ),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GenAIScreen()),
              );
            },
            leading: Icon(Icons.auto_awesome),
          ),
        ],
      ),
    );
  }
}
