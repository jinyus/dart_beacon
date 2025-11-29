part of 'infinite_list.dart';

final infiniteControllerRef = Ref.scoped(
  (ctx) => InfiniteController(PostRepository()),
);

class InfiniteListPage extends StatelessWidget {
  const InfiniteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = infiniteControllerRef.of(context);

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
                    final items = controller.parsedItems.watch(ctx);
                    return RefreshIndicator(
                      onRefresh: () async => controller.refresh(),
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          },
                        ),
                        child: ListView.separated(
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return switch (item) {
                              ItemData(:final value) => ItemTile(title: value),
                              ItemLoading() => const LoadingIndicator(),
                              ItemError(:final error) =>
                                ErrorDisplay(error: error),
                            };
                          },
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 5),
                        ),
                      ),
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

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // this widget gets built when we reach the end of the list,
      // therefore, we should load more items
      infiniteControllerRef.read(context).loadNextPage();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    super.key,
    required this.error,
  });

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          error.toString(),
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        if (error is! NoMoreItemsException) ...[
          const SizedBox(height: 5),
          ElevatedButton(
            style: btnStyle,
            onPressed: () => infiniteControllerRef.read(context).retryOnError(),
            child: const Text('retry'),
          )
        ]
      ],
    );
  }
}

final btnStyle = ElevatedButton.styleFrom(
  textStyle: k32Text,
  minimumSize: const Size(100, 60),
);
