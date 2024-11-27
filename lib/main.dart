import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'HomePage.dart';
import 'bloc/quiz_bloc.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => QuizBloc()..add(LoadQuizEvent()),
      child: MaterialApp(home: HomePage()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
