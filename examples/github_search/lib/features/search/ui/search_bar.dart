part of 'search_page.dart';

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final controller = searchControllerRef.read(context);
    _textController.addListener(() {
      controller.onTextChanged(_textController.text);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = searchControllerRef.of(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _textController,
        autocorrect: false,
        onChanged: controller.onTextChanged,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: GestureDetector(
            onTap: _textController.clear,
            child: const Icon(Icons.clear),
          ),
          border: const OutlineInputBorder(),
          hintText: 'Enter a search term',
        ),
      ),
    );
  }
}
