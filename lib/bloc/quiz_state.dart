part of 'quiz_bloc.dart';

@immutable
sealed class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

final class QuizInitial extends QuizState {}

final class QuizLoading extends QuizState {}

final class QuizLoaded extends QuizState {
  final List<Results> questions;
  final int currentIndex;
  final int score;

  QuizLoaded(
      {required this.questions,
      required this.currentIndex,
      required this.score});

  @override
  List<Object?> get props => [questions, currentIndex, score];
}

final class QuizAnsChecked extends QuizState {
  final bool isCorrect;
  final QuizLoaded quizState;

  QuizAnsChecked({required this.isCorrect, required this.quizState});

  List<Object?> get props => [isCorrect, quizState];
}

final class QuizCompleted extends QuizState {
  final int totalScored;
  final int totalAnswered;

  QuizCompleted({required this.totalScored, required this.totalAnswered});

  List<Object?> get props => [totalScored, totalAnswered];
}

final class QuizError extends QuizState {
  final String errorMessage;

  QuizError({required this.errorMessage});
  List<Object?> get props => [errorMessage];
}
