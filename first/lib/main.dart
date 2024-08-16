import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];
  void toggleFavorite(element) {
    if (favorites.contains(element)) {
      favorites.remove(element);
    } else {
      favorites.add(element);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  var extended = false;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = LikedPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      getLeading() {
        if (constraints.maxWidth >= 600) {
          return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                setState(() {
                  extended = !extended;
                });
              });
        }
      }

      if (constraints.maxWidth <= 600) {
        extended = false;
      }

      var navRail = NavigationRail(
        backgroundColor: Theme.of(context).colorScheme.surface,
        extended: extended,
        destinations: [
          NavigationRailDestination(
            icon: Icon(Icons.home),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.favorite),
            label: Text('Favorites'),
          ),
        ],
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
            extended = false;
          });
        },
        leading: getLeading(),
      );
      var safeArea = SafeArea(
        child: navRail,
      );

      return Scaffold(
        body: Row(
          children: [
            safeArea,
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.secondary,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    var nextButton = ElevatedButton(
      onPressed: () {
        appState.getNext();
      },
      child: Text('Next'),
    );

    var likeButton = ElevatedButton.icon(
      onPressed: () {
        appState.toggleFavorite(appState.current);
      },
      icon: Icon(icon),
      label: Text('Like'),
    );
    var buttonRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        likeButton,
        SizedBox(width: 10),
        nextButton,
      ],
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          buttonRow,
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
            subtitle: Text("a subtitle"),
            iconColor: Colors.lime.shade700,
          ),
      ],
    );
  }
}

class LikedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }
    final theme = Theme.of(context);
    final style = theme.textTheme.headlineMedium!.copyWith(
      color: theme.colorScheme.surface,
    );

    var children = <Widget>[];
    for (var element in appState.favorites) {
      var likeButton = ElevatedButton.icon(
        onPressed: () {
          appState.toggleFavorite(element);
        },
        icon: Icon(Icons.favorite),
        label: Text('Like'),
      );
      children.add(Column(children: [
        ListTile(
          title: Card(
            semanticContainer: false,
            color: theme.colorScheme.primary,
            // margin: EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(children: [
                Text(
                  element.asPascalCase,
                  style: style,
                  semanticsLabel: "${element.first} ${element.second}",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                likeButton
              ]),
            ),
          ),
          tileColor: theme.primaryColorLight,
          textColor: theme.colorScheme.surface,
        ),
      ]));
    }
    var main = Center(
      child: ListView(
        padding: EdgeInsets.all(20.0),
        physics: BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.normal),
        children: children,
      ),
    );
    return main;
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.surface,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asPascalCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
