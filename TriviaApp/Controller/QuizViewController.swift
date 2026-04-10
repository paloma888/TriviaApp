//
//  QuizViewController.swift
//  TriviaApp
//
//  Created by Paloma Pichardo on 4/9/26.
//

import UIKit

class QuizViewController: UIViewController {
    
    //MARK: properties
    private let quizManager: QuizManager //Custom Init set below
    private var timer: Timer?
    private var timeRemaining: Int = 15
    
    //MARK: UI
    private var answerButtons: [UIButton] = []
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let streakLabel: UILabel  = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let answerOptions: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    //MARK: init
    init(quizManager: QuizManager) {
        self.quizManager = quizManager
        //Custom Init requires calling Init of parent class
        super.init(nibName: nil, bundle: nil)
    }
    
    //Crash if we attempt to call from storyboard, swift requirement
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: setup
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        setupUI()
        displayCurrentQuestion()
        beginTimer()
    }
    
    private func setupUI() {
        view.addSubview(progressLabel)
        view.addSubview(timerLabel)
        view.addSubview(streakLabel)
        view.addSubview(questionLabel)
        view.addSubview(answerOptions)
        
        for i in 0..<4 {
            let button = UIButton(type: .system)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            button.backgroundColor = .secondarySystemBackground
            button.setTitleColor(.label, for: .normal)
            button.layer.cornerRadius = 12
            button.titleLabel?.numberOfLines = 0
            button.tag = i
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
            answerButtons.append(button)
            answerOptions.addArrangedSubview(button)
        }
    
    
    NSLayoutConstraint.activate([
        progressLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
        progressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
        timerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        streakLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 8),
        streakLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        questionLabel.topAnchor.constraint(equalTo:streakLabel.bottomAnchor, constant: 10),
        questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        answerOptions.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 30),
        answerOptions.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        answerOptions.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        answerOptions.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        
    ])
  }
   
    //MARK: logic
    
    //Screen displays the question we are currently on
    private func displayCurrentQuestion() {
        guard let question = quizManager.currentQuestion else {return}
        questionLabel.text = question.text
        progressLabel.text = "Question \(quizManager.currentIdx + 1)/\(quizManager.totalQuestions)"
        updateStreakLabel()
        
        for(index, button) in answerButtons.enumerated() {
            button.setTitle(question.answers[index], for: .normal)
            button.backgroundColor = .secondarySystemBackground
            button.isEnabled = true
        }
        timeRemaining = 15
        timerLabel.text = "⏱ 15s"
    }
    
    //Streak label reflects user's current streak
    private func updateStreakLabel() {
        if quizManager.streak >= 3 {
            streakLabel.text = "🔥 \(quizManager.streak) streak! Bonus!"
        } else if quizManager.streak > 1 {
            streakLabel.text = "⚡️ \(quizManager.streak) in a row!"
        } else {
            streakLabel.text = ""
        }
    }
    
    //MARK: timer
    private func beginTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else {return}
            self.timeRemaining -= 1
            self.timerLabel.text = "⏱ \(self.timeRemaining)s"
            
            if self.timeRemaining <= 5 {
                self.timerLabel.textColor = .systemRed
            }
            
            if self.timeRemaining <= 0 {
                self.handleTimeUp()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    
    }
    
    private func handleTimeUp() {
        stopTimer()
        answerButtons.forEach { $0.isEnabled = false}
        showCorrectAnswer()
        
        //Showing our correct answer for 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {[weak self] in
            guard let self = self else {return}
            _ = self.quizManager.submitAns("")
            self.nextQuestion()
        }
    }
    
    //MARK: actions
    
    //Submits user's selected answer and displays the correct one, adjusts score accordingly
    @objc private func answerTapped(_ sender: UIButton) {
        stopTimer()
        //Disable use of buttons
        answerButtons.forEach {$0.isEnabled = false}
        guard let question = quizManager.currentQuestion else {return}
        let chosenAnswer = question.answers[sender.tag]
        let correct = chosenAnswer == question.correctAnswer
        
        if correct {
            sender.backgroundColor = .systemGreen
        } else {
            sender.backgroundColor = .systemRed
            showCorrectAnswer()
        }
        _ = quizManager.submitAns(chosenAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {[weak self] in
            guard let self = self else {return}
            self.nextQuestion()
        }
    }
    
    //Changes the correct answer's background to green, 1.5 seconds before moving on
    private func showCorrectAnswer() {
        guard let question = quizManager.currentQuestion else {return}
        for button in answerButtons {
            if button.title(for: .normal) == question.correctAnswer {
                button.backgroundColor = .systemGreen
            }
        }
    }
    
    //Display next question, or results if done
    private func nextQuestion() {
        timerLabel.textColor = .label
        if quizManager.isDone {
            goToResults()
        } else {
            displayCurrentQuestion()
            beginTimer()
        }
    }
    
    //MARK: moving to next screen
    private func goToResults() {
        let resultsViewCont = ResultsViewController(score: quizManager.score, amountCorrect: quizManager.amountCorrect)
        navigationController?.pushViewController(resultsViewCont, animated: true)
    }
}

