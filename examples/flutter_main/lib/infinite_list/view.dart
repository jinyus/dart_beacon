part of 'infinite_list.dart';

class InfiniteListPage extends StatelessWidget {
  const InfiniteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: math.min(500, MediaQuery.of(context).size.width * 0.8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text('Infinite List', style: k24Text),
                Expanded(
                  child: Builder(builder: (ctx) {
                    final controller = ctx.read<InfiniteController>();
                    final count = controller.parsedItems.watch(ctx).length;
                    return ListView.separated(
                      itemBuilder: (context, index) {
                        final item = controller.parsedItems.value[index];

                        return switch (item) {
                          ItemData(value: final value) =>
                            ItemTile(title: value),
                          ItemLoading() => BottomWidget(controller),
                          ItemError(error: final err) =>
                            BottomWidget(controller, error: err),
                        };
                      },
                      itemCount: count,
                      separatorBuilder: (_, __) => const SizedBox(height: 5),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ItemTile extends StatelessWidget {
  const ItemTile({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: k24Text),
      tileColor: Theme.of(context).colorScheme.secondaryContainer,
    );
  }
}

class BottomWidget extends StatefulWidget {
  const BottomWidget(
    this.controller, {
    super.key,
    this.error,
  });

  final Object? error;
  final InfiniteController controller;

  @override
  State<BottomWidget> createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<BottomWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // this widgets gets built when we reach the end of the list,
      // therefore, we should load more items
      if (widget.error == null) {
        widget.controller.pageNum.increment();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.error == null) {
      return const Center(child: CircularProgressIndicator());
    }

    const style = TextStyle(fontSize: 20);
    if (widget.error is NoMoreItemsException) {
      return const Text(
        'No More Items',
        style: style,
        textAlign: TextAlign.center,
      );
    }

    return Column(
      children: [
        Text(
          widget.error?.toString() ?? 'Unknown Error',
          style: style,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        ElevatedButton(
          style: btnStyle,
          onPressed: widget.controller.rawItems.reset,
          child: const Text('retry'),
        )
      ],
    );
  }
}

final btnStyle = ElevatedButton.styleFrom(
  textStyle: k32Text,
  minimumSize: const Size(100, 60),
);
