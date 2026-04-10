//
//  ViewController.swift
//  TriviaApp
//
//  Created by Paloma Pichardo on 4/7/26.
//

import UIKit

class HomeViewController: UIViewController {

    //MARK: UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Big Brain Trivia Quizzes"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false //positioning elements ourselves
        return label
    }()
    
    //selecting cateogry
    private let categoryPick: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    //selecting difficulty
    private let difficultyPick: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Easy", "Medium", "Hard"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    //start
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Your Quiz", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loader: UIActivityIndicatorView = {
        let load = UIActivityIndicatorView(style: .large)
        load.hidesWhenStopped = true
        load.translatesAutoresizingMaskIntoConstraints = false
        return load
    }()
    
    
    //MARK: data
    let categories: [(name: String, id: Int)] = [
        (name: "Any Category", id: 0),
        (name: "General Knowledge", id: 9),
        (name: "Books", id: 10),
        (name: "Film", id: 11),
        (name: "Music", id: 12),
        (name: "Musicals & Theatres", id: 13),
        (name: "Television", id: 14),
        (name: "Video Games", id: 15),
        (name: "Board Games", id: 16),
        (name: "Science & Nature", id: 17),
        (name: "Computers", id: 18),
        (name: "Mathematics", id: 19),
        (name: "Mythology", id: 20),
        (name: "Sports", id: 21),
        (name: "Geography", id: 22),
        (name: "History", id: 23),
        (name: "Politics", id: 24),
        (name: "Art", id: 25),
        (name: "Celebrities", id: 26),
        (name: "Animals", id: 27),
        (name: "Vehicles", id: 28),
        (name: "Comics", id: 29),
        (name: "Gadgets", id: 30),
        (name: "Japanese Anime & Manga", id: 31),
        (name: "Cartoon & Animations", id: 32)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad() //UIViewController sets up first
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
        categoryPick.delegate = self
        categoryPick.dataSource = self
    }
    
    //MARK: setup
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(categoryPick)
        view.addSubview(difficultyPick)
        view.addSubview(startButton)
        view.addSubview(loader)
        
        //setting dimensions + locations of ui elements
        NSLayoutConstraint.activate([
            //safeAreaLayoutGuide accounts for iPhone features
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            //aligning with screen's center
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryPick.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            categoryPick.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryPick.trailingAnchor.constraint(equalTo:view.trailingAnchor),
            difficultyPick.topAnchor.constraint(equalTo: categoryPick.bottomAnchor, constant: 20),
            difficultyPick.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            difficultyPick.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            startButton.topAnchor.constraint(equalTo: difficultyPick.bottomAnchor, constant: 40),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20)
        ])
        
    }
    
    private func setupActions() {
        //.touchUpInside is the standard tap gesture
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    //MARK: actions
    @objc private func startButtonTapped() {
        let pickedCategory = categories[categoryPick.selectedRow(inComponent: 0)]
        let difficultyLevels = ["easy", "medium", "hard"]
        let pickedDifficulty = difficultyLevels[difficultyPick.selectedSegmentIndex]
        
        startButton.isEnabled = false
        loader.startAnimating()
        
        //fetching from API
        //[weak self] prevents memory leaks caused by navigating away mid-request
        APIService.sharedAPIService.fetchQuestions(amt: 10, category: pickedCategory.id, difficulty: pickedDifficulty) { [weak self] result in
            
            //only continue if self hasn't been deallocated
            guard let self = self else {return}
            self.loader.stopAnimating()
            self.startButton.isEnabled = true
            
            switch result {
            case .success(let questions):
                let quizManager = QuizManager()
                quizManager.loadQuestions(newquestions: questions)
                let quizViewCont = QuizViewController(quizManager: quizManager)
                self.navigationController?.pushViewController(quizViewCont, animated: true)
                
            case .failure(let error):
                let errorMsg = UIAlertController(title: "Error", message: "Failed to load questions: \(error.localizedDescription)", preferredStyle: .alert)
                errorMsg.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(errorMsg, animated: true)
            }
        }
    }
}

//MARK: UIpickerview delegate + datasource
//Swift delegate pattern is used to feed data into the UIPickerView
extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView:UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].name
    }
}
