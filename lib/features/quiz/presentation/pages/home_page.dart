import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream/features/authentication/presentation/pages/login_page.dart';
import 'package:stream/features/quiz/presentation/pages/widgets/option_tile.dart';

import '../bloc/quiz_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _logout(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    pref.setBool('isLoggedIn', false);

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Logged Out")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Quiz App',
          style: TextStyle(color: Colors.black, fontSize: 23),
        ),
        centerTitle: true,
        actions: [
          ElevatedButton(
            onPressed: () => _logout(context),
            child: const Icon(
              Icons.logout_sharp,
              color: Colors.red,
            ),
          )
        ],
      ),
      body: BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is QuizLoaded) {
            final currentQuestion = state.questions[state.currentIndex];
            final options = [
              ...currentQuestion.incorrectAnswers!,
              currentQuestion.correctAnswer!
            ]..shuffle();
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${state.currentIndex + 1}',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentQuestion.question!,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  ...options.map((option) => OptionTile(
                        option: option,
                        isSelected: false,
                        onTap: () {
                          context.read<QuizBloc>().add(
                                SelectAnsEvent(selectedAnswer: option),
                              );
                        },
                      )),
                  const Spacer(),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: ElevatedButton(
                        onPressed: () {
                          context.read<QuizBloc>().add(SkipQuesEvent());
                        },
                        child: const Text("Skip this question")),
                  )
                ],
              ),
            );
          } else if (state is QuizAnsChecked) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.isCorrect ? 'Correct!' : 'Wrong Answer!',
                    style: TextStyle(
                      fontSize: 24,
                      color: state.isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<QuizBloc>().add(NextQuesEvent());
                    },
                    child: const Text('Next Question'),
                  ),
                ],
              ),
            );
          } else if (state is QuizCompleted) {
            int totalScore = state.totalScored;
            int totalAnswered = state.totalAnswered;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Your total score is ${totalScore * 10}",
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Text(
                    "Max Score ${totalAnswered * 10}",
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                      onPressed: () =>
                          context.read<QuizBloc>().add(RestartQuizEvent()),
                      child: const Text(
                        "Restart Quiz",
                        style: TextStyle(fontSize: 18),
                      ))
                ],
              ),
            );
          } else if (state is QuizError) {
            return const Center(
              child: Text(
                'Error: ',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          return const Center(child: Text('Quiz is over'));
        },
      ),
    );
  }
}