import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:indoor_localization_app/firebase_options.dart';
import 'package:indoor_localization_app/routes.dart';
import 'package:indoor_localization_app/utils/authentication.dart';
import 'package:indoor_localization_app/widgets/auth_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indoor Localization App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Home'),
      debugShowCheckedModeBanner: false,
      routes: appRoutes,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          return Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
                actions: [
                  if (snapshot.hasData)
                    IconButton(
                      onPressed: () {
                        signOut();
                      },
                      icon: const Icon(Icons.exit_to_app),
                    ),
                ],
              ),
              body: snapshot.hasData
                  ? SizedBox.expand(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                color: Theme.of(context).primaryColor,
                                child: TextButton(
                                  child: const Text(
                                    'For map creators',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/for-creators');
                                  },
                                )),
                            Container(
                                color: Theme.of(context).primaryColor,
                                child: TextButton(
                                  child: const Text(
                                    'Map',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/map');
                                  },
                                )),
                          ]),
                    )
                  : const SizedBox.expand(
                      child: Center(
                        child: AuthDialog(),
                      ),
                    ));
        });
  }
}
