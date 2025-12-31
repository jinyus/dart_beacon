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
                  child: RefreshIndicator(
                    onRefresh: () async => controller.refresh(),
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        },
                      ),
                      child: Builder(builder: (ctx) {
                        final items = controller.items.watch(ctx);

                        return ListView.separated(
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return switch (item) {
                              ItemData d => ItemTile(title: d.value),
                              ItemLoading() => const LoadingIndicator(),
                              ItemError e => ErrorDisplay(error: e.error),
                              ItemEnd() => const NoMoreItems(),
                            };
                          },
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 5),
                        );
                      }),
                    ),
                  ),
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

class NoMoreItems extends StatelessWidget {
  const NoMoreItems({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        'No More Items',
        style: TextStyle(fontSize: 20),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    required this.error,
    super.key,
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
        const SizedBox(height: 5),
        ElevatedButton(
          style: btnStyle,
          onPressed: () => infiniteControllerRef.read(context).retryOnError(),
          child: const Text('retry'),
        ),
      ],
    );
  }
}

final btnStyle = ElevatedButton.styleFrom(
  textStyle: k32Text,
  minimumSize: const Size(100, 60),
);
