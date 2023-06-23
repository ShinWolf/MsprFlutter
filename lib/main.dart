import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';




void main() {
  runApp(const MyApp());
  testWidgets('Test d\'affichage des posts et ajout de commentaire', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(MyApp()); // Remplacez MyApp() par votre widget principal

    // Act
    await tester.tap(find.text('Ajouter un commentaire').first);
    await tester.enterText(find.byType(TextField), 'Nouveau commentaire');
    await tester.tap(find.text('Ajouter'));

    // Assert
    expect(find.text('Nouveau commentaire'), findsOneWidget);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const LoginPage(),
    );
  }
}


class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  void _login(BuildContext context) {
    // Add your login logic here

    // Navigate to PostPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostPage(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Connexion',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _login(context),
              child: const Text('Entrer'),
            ),
          ],
        ),
      ),
    );
  }
}

class StatsPage extends StatefulWidget {
  final Map<String, dynamic> stats;

  const StatsPage({Key? key, required this.stats}) : super(key: key);

  @override
  _StatsPageState createState() => _StatsPageState();
}
class _StatsPageState extends State<StatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques des posts'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Statistiques des posts par jour',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            // Utilisez les données des statistiques ici
            // Par exemple, affichez-les dans un ListView
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.stats.length,
              itemBuilder: (BuildContext context, int index) {
                final date = widget.stats.keys.elementAt(index);
                final count = widget.stats.values.elementAt(index);
                return ListTile(
                  title: Text('Date: $date'),
                  subtitle: Text('Nombre de posts: $count'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Post {
  final String text;
  final String imageUrl;
  final List<String> comments;

  Post({
    required this.text,
    required this.imageUrl,
    required this.comments,
  });
}

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<Post> posts = [
    Post(
      text: 'Post 1',
      imageUrl: 'assets/images/plante1App.jpg',
      comments: ['Commentaire 1', 'Commentaire 2'],
    ),
    Post(
      text: 'Post 2',
      imageUrl: 'assets/images/plante2.jpg',
      comments: ['User1 : Commentaire 3', ' User2 : Commentaire 4'],
    ),
    Post(
      text: 'Post 3',
      imageUrl: 'assets/images/plante3.jpg',
      comments: [],
    ),
    // Add your posts here
  ];

  void _addPost(String text, String imageUrl) {
    final newPost = Post(
      text: text,
      imageUrl: imageUrl,
      comments: [],
    );

    setState(() {
      posts.add(newPost);
    });
  }

  Future<void> _showAddPostDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPostPage()),
    );

    if (result != null) {
      final text = result['text'] as String;
      final imageUrl = result['imageUrl'] as String;

      _addPost(text, imageUrl);
    }
  }

  Future<void> _showCommentDialog(int index) async {
    String comment = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un commentaire'),
          content: TextField(
            onChanged: (value) {
              comment = value;
            },
            decoration: const InputDecoration(labelText: 'Commentaire'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addComment(index, comment);
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _addComment(int index, String comment) {
    setState(() {
      posts[index].comments.add(comment);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (BuildContext context, int index) {
          final post = posts[index];
          return Card(
            child: Column(
              children: [
                Image.network(post.imageUrl),
                ListTile(
                  title: Text(
                    post.text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Commentaires :',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      for (final comment in post.comments)
                        Text('- $comment'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _showCommentDialog(index),
                  child: const Text('Ajouter un commentaire'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPostDialog();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                _showAddPostDialog();
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  String text = '';
  String imageUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  text = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Texte'),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  imageUrl = value;
                });
              },
              decoration: const InputDecoration(labelText: 'URL de l\'image'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({'text': text, 'imageUrl': imageUrl});
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}

