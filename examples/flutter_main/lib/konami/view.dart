part of 'konami.dart';

final konamiControllerRef = Ref.scoped((ctx) => KonamiController());

class KonamiPage extends StatefulWidget {
  const KonamiPage({super.key});

  @override
  State<KonamiPage> createState() => _KonamiPageState();
}

class _KonamiPageState extends State<KonamiPage> {
  late final fNode = FocusNode(
      // onKey: (node, e) {
      //   widget.controller.keys.set(e.logicalKey.keyLabel, force: true);
      //   return KeyEventResult.handled;
      // },
      );

  static const checker = IterableEquality();

  @override
  void initState() {
    konamiControllerRef.read(context).last10.subscribe(
      (codes) {
        if (codes.isEmpty || !mounted) return;
        final won = checker.equals(codes, konamiCodes);

        if (won) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Congratulations!'),
                content: const Text('KONAMI! You won!'),
                actions: <Widget>[
                  TextButton(
                    key: const ValueKey('close'),
                    child: const Text('Close'),
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
            const SnackBar(
              content: Text('Keep trying!'),
              duration: Duration(seconds: 2),
              padding: EdgeInsets.all(20),
            ),
          );
        }
      },
      startNow: false,
    );
    super.initState();
  }

  @override
  void dispose() {
    fNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      autofocus: true,
      focusNode: fNode,
      onKeyEvent: (e) {
        konamiControllerRef
            .read(context)
            .keys
            .set(e.logicalKey.keyLabel, force: true);
      },
      child: const Column(
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
    final keys = konamiControllerRef.select(
      context,
      (c) => c.last10.currentBuffer,
    );
    final lastKey = keys.lastOrNull;

    if (lastKey != null) {
      return Text('$lastKey (${keys.length})', style: k32Text);
    }
    return const Text('start typing...', style: k32Text);
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
        style: const TextStyle(
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
          minimumSize: const Size(100, 100)),
      onPressed: () {
        final controller = konamiControllerRef.read(context);
        controller.last10.reset();
        controller.keys.reset();
      },
      child: const Text('Reset'),
    );
  }
}
