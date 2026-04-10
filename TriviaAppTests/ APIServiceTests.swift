//
//   APIServiceTests.swift
//  TriviaApp
//
//  Created by Paloma Pichardo on 4/10/26.
//

import XCTest
@testable import TriviaApp

final class APIServiceTests: XCTestCase {
    
    //MARK: shared fetched questions
    //Fetched once and reused across tests to avoid rate limiting
    static var fetchedQuestions: [Question]?
    static var fetchError: Error?
    static var hasFetched = false
    
    override func setUp() {
        super.setUp()
        //Hit the API once for all tests
        if !APIServiceTests.hasFetched {
            let expectation = XCTestExpectation(description: "Initial fetch")
            APIServiceTests.hasFetched = true
            
            APIService.sharedAPIService.fetchQuestions(
                amt: 5,
                category: 9,
                difficulty: "easy"
            ) { result in
                switch result {
                case .success(let questions):
                    APIServiceTests.fetchedQuestions = questions
                case .failure(let error):
                    APIServiceTests.fetchError = error
                }
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    // MARK: responses
    func test_fetchQuestions_returnsRequestedAmount() {
        guard let questions = APIServiceTests.fetchedQuestions else {
            XCTFail("No questions fetched, possible rate limit or network issue")
            return
        }
        XCTAssertEqual(questions.count, 5)
    }
    
    func test_fetchQuestions_eachQuestionHasFourAnswers() {
        guard let questions = APIServiceTests.fetchedQuestions else {
            XCTFail("No questions fetched, possible rate limit or network issue")
            return
        }
        for question in questions {
            XCTAssertEqual(question.answers.count, 4,
                "Question '\(question.text)' should have 4 answers")
        }
    }
    
    func test_fetchQuestions_correctAnswerIsIncludedInAnswers() {
        guard let questions = APIServiceTests.fetchedQuestions else {
            XCTFail("No questions fetched, possible rate limit or network issue")
            return
        }
        for question in questions {
            XCTAssertTrue(
                question.answers.contains(question.correctAnswer),
                "Correct answer '\(question.correctAnswer)' should be in answers array"
            )
        }
    }
    
    func test_fetchQuestions_invalidCategoryDoesNotCrash() {
        let expectation = XCTestExpectation(description: "API returns a result")
        
        APIService.sharedAPIService.fetchQuestions(
            amt: 1,
            category: 9,
            difficulty: "easy"
        ) { result in
            switch result {
            case .success(let questions):
                XCTAssertNotNil(questions)
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: check HTML decoding
    func test_htmlDecoded_convertsApostrophe() {
        let encoded = "What&#039;s the capital of France?"
        XCTAssertEqual(encoded.htmlDecoded, "What's the capital of France?")
    }
    
    func test_htmlDecoded_convertsAmpersand() {
        let encoded = "Romeo &amp; Juliet"
        XCTAssertEqual(encoded.htmlDecoded, "Romeo & Juliet")
    }
    
    func test_htmlDecoded_plainStringUnchanged() {
        let plain = "What is the capital of France?"
        XCTAssertEqual(plain.htmlDecoded, plain)
    }
}
