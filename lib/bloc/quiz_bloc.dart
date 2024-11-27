import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:stream/data/quiz_data_model.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc() : super(QuizInitial()) {
    on<QuizEvent>(quizEvent);
    on<LoadQuizEvent>(loadQuizEvent);
    on<SelectAnsEvent>(selectAnsEvent);
    on<NextQuesEvent>(nextQuesEvent);
  }

  FutureOr<void> quizEvent(QuizEvent event, Emitter<QuizState> emit) {}
  FutureOr<void> loadQuizEvent(
      LoadQuizEvent event, Emitter<QuizState> emit) async {
    emit(QuizLoading());

    try {
      var client = http.Client();

      final response = await client.get(Uri.parse(
          'https://opentdb.com/api.php?amount=10&category=12&type=multiple'));
      if (response.statusCode == 200) {
        print("Connection is OK");

        final jsonData = jsonDecode(response.body);
        final quizData = QuizData.fromJson(jsonData);

        emit(QuizLoaded(
            questions: quizData.results ?? [], currentIndex: 0, score: 0));
      } else {
        emit(QuizError(
            errorMessage: "Unable to make connection ${response.statusCode}"));
      }
    } catch (e) {
      emit(QuizError(errorMessage: "$e"));
    }
  }

  FutureOr<void> selectAnsEvent(SelectAnsEvent event, Emitter<QuizState> emit) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;

      final currentQuestion = currentState.questions[currentState.currentIndex];
      bool isCorrect = (event.selectedAnswer == currentQuestion.correctAnswer);
      emit(QuizAnsChecked(isCorrect: isCorrect, quizState: currentState));
    }
  }

  FutureOr<void> nextQuesEvent(NextQuesEvent event, Emitter<QuizState> emit) {
    if (state is QuizAnsChecked) {
      final checkedState = state as QuizAnsChecked;
      final currentState = checkedState.quizState;

      //iterate over the quiz questions
      if (currentState.currentIndex < currentState.questions.length - 1) {
        emit(QuizLoaded(
            questions: currentState.questions,
            currentIndex: currentState.currentIndex + 1,
            score: checkedState.isCorrect
                ? currentState.score + 1
                : currentState.score));
      } else {
        final checkedState = state as QuizAnsChecked;
        final int totalScore = checkedState.quizState.score;
        emit(QuizCompleted(

            ///total scored might cause error
            totalScored: totalScore,
            totalAnswered: currentState.questions.length));
      }
    }
  }

  ///restart quiz logic could be written here
}
