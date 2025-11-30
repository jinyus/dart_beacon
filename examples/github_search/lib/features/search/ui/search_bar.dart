part of 'search_page.dart';

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = searchControllerRef.of(context).searchTerm.controller;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: controller,
        autocorrect: false,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: GestureDetector(
            onTap: controller.clear,
            child: const Icon(Icons.clear),
          ),
          border: const OutlineInputBorder(),
          hintText: 'Enter a search term',
        ),
      ),
    );
  }
}
