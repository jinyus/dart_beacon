part of 'counter.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final btnStyle = IconButton.styleFrom(
      minimumSize: const Size(100, 100),
      backgroundColor:
          Theme.of(context).buttonTheme.colorScheme!.primaryContainer,
      shape: const CircleBorder(
        side: BorderSide(color: Colors.black),
      ),
    );

    return Provider(
        create: (_) => Controller(),
        builder: (ctx, _) {
          final controller = ctx.read<Controller>();
          final count = controller.count;

          count.observe(context, (prev, next) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.clearSnackBars();
            if (next > prev && next > 3) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Count cannot be greater than 3'),
                ),
              );
            } else if (next < prev && next < 0) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Count cannot be negative'),
                ),
              );
            }
          });
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Counter', style: TextStyle(fontSize: 48)),
              const Counter(),
              k16SizeBox,
              const FutureCounter(),
              k16SizeBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => count.value--,
                    style: btnStyle,
                  ),
                  k16SizeBox,
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => count.value++,
                    style: btnStyle,
                  ),
                ],
              ),
            ],
          );
        });
  }
}

class Counter extends StatelessWidget {
  const Counter({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.read<Controller>().count;
    return Text(
      count.watch(context).toString(),
      style: k40Text,
    );
  }
}

class FutureCounter extends StatelessWidget {
  const FutureCounter({super.key});

  @override
  Widget build(BuildContext context) {
    final derivedFutureCounter =
        context.read<Controller>().derivedFutureCounter;

    final textTheme = Theme.of(context).textTheme.headlineSmall;
    return switch (derivedFutureCounter.watch(context)) {
      AsyncData<String>(value: final v) => Text(v, style: textTheme),
      AsyncError(error: final e) => Text('$e', style: textTheme),
      _ => const CircularProgressIndicator(),
    };
  }
}
