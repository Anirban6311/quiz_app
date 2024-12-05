import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream/features/authentication/presentation/pages/login_page.dart';

import '../bloc/quiz_bloc.dart';

class HomePage extends StatelessWidget {
  void _logout(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    pref.setBool('isLoggedIn', false);

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Logged Out")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        centerTitle: true,
        actions: [
          ElevatedButton(
              onPressed: () => _logout(context),
              child: Icon(Icons.logout_sharp))
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
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentQuestion.question!,
                    style: const TextStyle(fontSize: 16),
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
                  Text("Your total score is ${totalScore * 10}"),
                  const SizedBox(
                    height: 40,
                  ),
                  Text("Max Score ${totalAnswered * 10}"),
                  const SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                      onPressed: () =>
                          context.read<QuizBloc>().add(RestartQuizEvent()),
                      child: Text("Restart Quiz"))
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

class OptionTile extends StatelessWidget {
  final String option;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionTile({
    Key? key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          option,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
