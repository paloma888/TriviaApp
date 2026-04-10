//
//  ResultsViewController.swift
//  TriviaApp
//
//  Created by Paloma Pichardo on 4/9/26.
//

import UIKit

class ResultsViewController: UIViewController {
    private let score: Int
    private let amountCorrect: Int
    
    //MARK: UI
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 70)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let feedbackLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let percentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let againButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play Again", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(againTapped), for: .touchUpInside)
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share Your Results", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: Init
    
    init(score: Int, amountCorrect: Int) {
        self.score = score
        self.amountCorrect = amountCorrect
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        setupUI()
        showResults()
    }
    
    
    //MARK: setup
    private func setupUI() {
        view.addSubview(emojiLabel)
        view.addSubview(feedbackLabel)
        view.addSubview(scoreLabel)
        view.addSubview(againButton)
        view.addSubview(shareButton)
        view.addSubview(percentLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emojiLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55),
            feedbackLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 20),
            feedbackLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            feedbackLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scoreLabel.topAnchor.constraint(equalTo: feedbackLabel.bottomAnchor, constant: 15),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            percentLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            percentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            percentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            againButton.topAnchor.constraint(equalTo: percentLabel.bottomAnchor, constant: 50),
            againButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            againButton.widthAnchor.constraint(equalToConstant: 200),
            againButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.topAnchor.constraint(equalTo: againButton.bottomAnchor, constant: 15),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 200),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            
        ])
    }
    
    //Shows user their final score and provides feedback based on the percentage
    //of questions answered correctly
    private func showResults() {
        scoreLabel.text = "You scored \(score) points!"
        //Appromixation of percentage 
        let percent = Double(amountCorrect) / Double(10) * 100
        percentLabel.text = "Your accuracy was \(Int(percent.rounded()))%"
        switch percent {
        case 90...:
            emojiLabel.text = "👑"
            feedbackLabel.text = "Trivia Royalty!"
        case 70..<90:
            emojiLabel.text = "🎉"
            feedbackLabel.text = "Strong Performance!"
        case 50..<70:
            emojiLabel.text = "🫰"
            feedbackLabel.text = "Not bad!"
        case 30..<50:
            emojiLabel.text = "📚"
            feedbackLabel.text = "Could use some studying..."
        default:
            emojiLabel.text = "😅"
            feedbackLabel.text = "Are you sure you're trying?"
        }
    }
    
    //MARK: actions
    //Brings us back to the bottom of the navigation stack (HomeViewController)
    @objc private func againTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    //UIActivityViewController is the native iOS share sheet
    //applicationActivities: nil, no custom share actions
    @objc private func shareTapped() {
        let text = "I just scored \(score) points on the Big Brain Trivia Quiz! Can you beat me?"
        let activityViewCont = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityViewCont, animated: true)
    }
}
