// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:example/const.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:state_beacon/state_beacon.dart';

const konamiCodes = [
  "Arrow Up",
  "Arrow Up",
  "Arrow Down",
  "Arrow Down",
  "Arrow Left",
  "Arrow Right",
  "Arrow Left",
  "Arrow Right",
  "B",
  "A",
];

final _keys = Beacon.lazyThrottled<String>(duration: k100ms * 2);
final _last10 = Beacon.bufferedCount<String>(10);

class KonamiPage extends StatefulWidget {
  const KonamiPage({super.key});

  @override
  State<KonamiPage> createState() => _KonamiPageState();
}

class _KonamiPageState extends State<KonamiPage> {
  final fNode = FocusNode(
    onKey: (node, e) {
      _keys.set(e.data.logicalKey.keyLabel, force: true);
      return KeyEventResult.handled;
    },
  );

  @override
  void initState() {
    _last10.wrap(_keys, startNow: false);

    _last10.subscribe((codes) {
      if (codes.isEmpty) return;
      final won = IterableEquality().equals(codes, konamiCodes);

      if (won) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Congratulations!'),
              content: Text('KONAMI! You won!'),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Keep trying!'),
            duration: const Duration(seconds: 2),
            padding: const EdgeInsets.all(20),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    fNode.dispose();
    _keys.dispose();
    _last10.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      autofocus: true,
      focusNode: fNode,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('Enter the Konamic Codes', style: k32Text),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  KeyText('^'),
                  KeyText('^'),
                  KeyText('v'),
                  KeyText('v'),
                  KeyText('<'),
                  KeyText('>'),
                  KeyText('<'),
                  KeyText('>'),
                  KeyText('B'),
                  KeyText('A'),
                ],
              ),
            ],
          ),
          ResetButton(),
          LastKey(),
        ],
      ),
    );
  }
}

class LastKey extends StatelessWidget {
  const LastKey({super.key});

  @override
  Widget build(BuildContext context) {
    final keys = _last10.currentBuffer.watch(context);
    final lastKey = keys.lastOrNull;

    if (lastKey != null) {
      return Text('$lastKey (${keys.length})', style: k32Text);
    }
    return Text('start typing...', style: k32Text);
  }
}

class KeyText extends StatelessWidget {
  const KeyText(this.char, {super.key});

  final String char;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onSurface),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        char,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ResetButton extends StatelessWidget {
  const ResetButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          foregroundColor: Theme.of(context).colorScheme.onTertiary,
          textStyle: k24Text,
          minimumSize: Size(100, 100)),
      onPressed: () {
        _keys.reset();
        _last10.reset();
      },
      child: const Text('Reset'),
    );
  }
}
