//
//  APIService.swift
//  TriviaApp
//
//  Created by Paloma Pichardo on 4/7/26.
//

import Foundation //for URL, URLSession, JSONDecoder
import UIKit


//Codable: convert to/from JSON automatically
struct TriviaResponse: Codable {
    let responseCode: Int
    let results: [APIQuestion]
    
    //Mapping JSON convention to our properties
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

struct APIQuestion: Codable {
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    //Mapping JSON convention to our properties
    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

class APIService {
    //Only one shared instance of APIService in the app
    static let sharedAPIService = APIService()
    private init() {}
    
    func fetchQuestions(amt: Int, category: Int, difficulty: String, completion: @escaping (Result<[Question], Error>) -> Void) {
        //Completion handler, code runs after data is ready
        let urlstr = "https://opentdb.com/api.php?amount=\(amt)&category=\(category)&difficulty=\(difficulty)&type=multiple"
        
        //Checking if url exists
        guard let url = URL(string: urlstr) else {
            print("URL is not valid")
            return
        }
        
        //dataTask sends HTTP request
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                print ("No data was fetched")
                return
            }
            
            //Attempting to decode JSON into a TriviaResponse
            do {
                let decodr = JSONDecoder()
                let trivResp = try decodr.decode(TriviaResponse.self, from: data)
                
                //Each result to a Question struct
                let questions = trivResp.results.map {apiQuestion in
                    //Combining all answers (correct and incorrect)
                    let ans = (apiQuestion.incorrectAnswers + [apiQuestion.correctAnswer]).map {$0.htmlDecoded} .shuffled()
                    
                    return Question(
                        text: apiQuestion.question.htmlDecoded,
                        answers: ans,
                        correctAnswer: apiQuestion.correctAnswer.htmlDecoded
                    )
                }
                
                DispatchQueue.main.async {
                    completion(.success(questions))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

extension String {
    var htmlDecoded: String {
        //string into bytes
        guard let data = self.data(using: .utf8) else {return self}
        //using NSAttributedString HTML parsing
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        //HTML encoded characters to standard text
        guard let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else { return self }
        return attributed.string
    }
}
