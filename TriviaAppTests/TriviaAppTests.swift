//
//  TriviaAppTests.swift
//  TriviaAppTests
//
//  Created by Paloma Pichardo on 4/10/26.
//

import Testing
import XCTest
@testable import TriviaApp

final class TriviaAppTests: XCTestCase {
    
    //MARK: setup
    var quizManager: QuizManager!
    var sampleQuestions: [Question]!
    
    override func setUp() {
        super.setUp()
        quizManager = QuizManager()
        sampleQuestions = [
            Question(
                text: "What is 2 + 2?",
                answers: ["3", "4", "5", "6"],
                correctAnswer: "4"
            ),
            Question(
                text: "What color is the sky?",
                answers: ["Red", "Green", "Blue", "Yellow"],
                correctAnswer: "Blue"
            ),
            Question(
                text: "What is the capital of France?",
                answers: ["London", "Berlin", "Madrid", "Paris"],
                correctAnswer: "Paris"
            )
        ]
        quizManager.loadQuestions(newquestions: sampleQuestions)
    }
    
    override func tearDown() {
        quizManager = nil
        sampleQuestions = nil
        super.tearDown()
    }
    
    //MARK: Loading questions
    func test_loadQuestions_setsCorrectTotal() {
        XCTAssertEqual(quizManager.totalQuestions, 3)
    }
    
    func test_loadQuestions_resetsScore() {
        _ = quizManager.submitAns("4")
        //reload
        quizManager.loadQuestions(newquestions: sampleQuestions)
        XCTAssertEqual(quizManager.score, 0)
    }
    
    func test_loadQuestions_resetsIndex() {
        _ = quizManager.submitAns("4")
        //reload
        quizManager.loadQuestions(newquestions: sampleQuestions)
        XCTAssertEqual(quizManager.currentIdx, 0)
    }
    
    func test_loadQuestions_resetsStreak() {
        _ = quizManager.submitAns("4")
        //reload
        quizManager.loadQuestions(newquestions: sampleQuestions)
        XCTAssertEqual(quizManager.streak, 0)
    }
    
    // MARK: answering questions
    func test_submitAnswer_correctAnswerReturnsTrue() {
        let result = quizManager.submitAns("4")
        XCTAssertTrue(result)
    }
    
    func test_submitAnswer_wrongAnswerReturnsFalse() {
        let result = quizManager.submitAns("99")
        XCTAssertFalse(result)
    }
    
    func test_submitAnswer_advancesIndex() {
        _ = quizManager.submitAns("4")
        XCTAssertEqual(quizManager.currentIdx, 1)
    }
    
    // MARK: scoring
    func test_scoring_correctAnswerAddsPoints() {
        _ = quizManager.submitAns("4")
        XCTAssertGreaterThan(quizManager.score, 0)
    }
    
    func test_scoring_wrongAnswerAddsNoPoints() {
        _ = quizManager.submitAns("wrong")
        XCTAssertEqual(quizManager.score, 0)
    }
    
    func test_scoring_firstCorrectAnswerWorthTenPoints() {
        _ = quizManager.submitAns("4")
        XCTAssertEqual(quizManager.score, 10)
    }
    
    // MARK: streak
    func test_streak_incrementsOnCorrectAnswer() {
        _ = quizManager.submitAns("4")
        XCTAssertEqual(quizManager.streak, 1)
    }
    
    func test_streak_resetsOnWrongAnswer() {
        _ = quizManager.submitAns("4")
        //Submitting wrong answer resets streak
        _ = quizManager.submitAns("wrong")
        XCTAssertEqual(quizManager.streak, 0)
    }
    
    func test_streak_threeInRowGivesBonusPoints() {
        let fiveQuestions = [
            Question(text: "Q1", answers: ["A", "B", "C", "D"], correctAnswer: "A"),
            Question(text: "Q2", answers: ["A", "B", "C", "D"], correctAnswer: "A"),
            Question(text: "Q3", answers: ["A", "B", "C", "D"], correctAnswer: "A"),
            Question(text: "Q4", answers: ["A", "B", "C", "D"], correctAnswer: "A"),
            Question(text: "Q5", answers: ["A", "B", "C", "D"], correctAnswer: "A")
        ]
        quizManager.loadQuestions(newquestions: fiveQuestions)
        
        _ = quizManager.submitAns("A") //10pts, streak = 1
        _ = quizManager.submitAns("A") //10pts, streak = 2
        _ = quizManager.submitAns("A") //15pts, streak = 3
        
        //10 + 10 + 15 = 35
        XCTAssertEqual(quizManager.score, 35)
    }
    
    func test_streak_fiveInRowGivesHighestBonus() {
        let fiveQuestions = [
            Question(text: "Q1", answers: ["A", "B", "C", "D"], correctAnswer: "A"),
            Question(text: "Q2", answers: ["A", "B", "C", "D"], correctAnswer: "A"),
            Question(text: "Q3", answers: ["A", "B", "C", "D"], correctAnswer: "A"),
            Question(text: "Q4", answers: ["A", "B", "C", "D"], correctAnswer: "A"),
            Question(text: "Q5", answers: ["A", "B", "C", "D"], correctAnswer: "A")
        ]
        quizManager.loadQuestions(newquestions: fiveQuestions)
        
        _ = quizManager.submitAns("A") //10pts, streak = 1
        _ = quizManager.submitAns("A") //10pts, streak = 2
        _ = quizManager.submitAns("A") //15pts, streak = 3
        _ = quizManager.submitAns("A") //20pts, streak = 4
        _ = quizManager.submitAns("A") //25pts, streak = 5
        
        //10 + 10 + 15 + 20 + 25 = 80
        XCTAssertEqual(quizManager.score, 80)
    }
    
    // MARK: question progression
    func test_currentQuestion_returnsFirstQuestionInitially() {
        XCTAssertEqual(quizManager.currentQuestion?.text, "What is 2 + 2?")
    }
    
    func test_currentQuestion_returnsNilWhenFinished() {
        _ = quizManager.submitAns("4")
        _ = quizManager.submitAns("Blue")
        _ = quizManager.submitAns("Paris")
        XCTAssertNil(quizManager.currentQuestion)
    }
    
    func test_isFinished_falseWhenQuestionsRemain() {
        XCTAssertFalse(quizManager.isDone)
    }
    
    func test_isFinished_trueWhenAllAnswered() {
        _ = quizManager.submitAns("4")
        _ = quizManager.submitAns("Blue")
        _ = quizManager.submitAns("Paris")
        XCTAssertTrue(quizManager.isDone)
    }
}
