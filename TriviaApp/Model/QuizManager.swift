//
//  QuizManager.swift
//  TriviaApp
//
//  Created by Paloma Pichardo on 4/7/26.
//

class QuizManager {
    //MARK: Properties
    private(set) var score: Int = 0
    private(set) var currentIdx: Int = 0
    private var questions: [Question] = []
    private(set) var streak: Int = 0
    private(set) var amountCorrect: Int = 0
    
    //MARK: Computed properties (logic gets rerun everytime we access)
    var currentQuestion: Question? {
        guard (currentIdx < questions.count) else {return nil}
        return questions[currentIdx]
    }
    
    var totalQuestions: Int {
        return questions.count
    }
    
    var isDone: Bool {
        return currentIdx >= questions.count
    }
    
    //MARK: Quiz Setup
    //Setting up a quiz with new questions
    func loadQuestions(newquestions: [Question]) {
        questions = newquestions
        score = 0
        currentIdx = 0
        streak = 0
    }
    
    //MARK: Logic
    //Submitting an answer + setting index to next question
    //returns Bool: whether the current answer is correct
    func submitAns(_ answer: String) -> Bool {
        //return if currentQuestion == null
        guard let curr = currentQuestion else {return false}
        let isCorrect: Bool = (answer == curr.correctAnswer)
        
        if isCorrect {
            streak += 1
            amountCorrect += 1
            score += streakPoints()
        } else {
            streak = 0
        }
        
        currentIdx += 1
        return isCorrect
    }
    
    //Updating points added based on current streak
    //returns Int: amount of points to be added to score
    func streakPoints() -> Int {
        switch streak {
        case 3:
            return 15
        case 4:
            return 20
        case 5...:
            return 25
        default:
            return 10
        }
    }
    
}
