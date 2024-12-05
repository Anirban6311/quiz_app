part of 'quiz_bloc.dart';

@immutable
abstract class QuizEvent extends Equatable {
  const QuizEvent();
  @override
  List<Object?> get props => [];
}

final class LoadQuizEvent extends QuizEvent {}

final class SelectAnsEvent extends QuizEvent {
  final String selectedAnswer;

  SelectAnsEvent({required this.selectedAnswer});
  @override
  List<Object?> get props => [];
}

final class NextQuesEvent extends QuizEvent {}

final class RestartQuizEvent extends QuizEvent {}
