# Big 🧠 TriviaApp

### Take-Home Kata by Paloma Pichardo

A native iOS trivia app built in Swift using UIKit. Users select a category and difficulty, then answer 10 multiple choice questions fetched live from the Open Trivia Database. The app tracks score, rewards consecutive correct answers with streak bonuses, and lets users share their results via the native iOS share sheet.

## Running the App

Requirements: A Mac with Xcode 15 or later installed. Network access needed.
1. Clone the repository
2. Open TriviaApp.xcodeproj in Xcode
3. Select any iPhone simulator from the dropdown at the top (iPhone 15 or later recommended)
4. Press the Play button or ⌘R to build and run

## Features:
- Category & difficulty selection: choose from 25 categories and 3 difficulty levels before each quiz
- Live question fetching: questions are fetched from the Open Trivia Database API at the start of every quiz
- 15-second countdown timer: each question has a timer that turns red in the final 5 seconds; running out of time counts as a wrong answer
- Correct answer feedback: after each answer, the correct choice is highlighted green before moving on
- Streak bonus scoring: consecutive correct answers award increasing bonus points, tracked and displayed in real time
- Results screen: displays final score with a personalized feedback message based on performance
- Share results: a native iOS share sheet lets users send their score to friends via Messages, Mail, or any installed app


## Planning & Design:

Development began with a written project proposal covering functionality, tech stack, component breakdown, and potential risks before any code was written. A simple wireframe was sketched out for all three screens prior to implementation to inform layout decisions in code.

The wireframe and full proposal are included in this repository as PROPOSAL.md

Architecture:
The app follows the MVC (Model-View-Controller) pattern, the standard architecture for iOS development.



## Tech Stack: 

Swift, UIKit, URLSession, Codable, UIActivityViewController, MVC, XCTest, Open Trivia Database API

## Known Issues:
- Messages not appearing in share sheet (simulator only):
  - The Messages option does not appear in the iOS Simulator because iMessage requires a real device with an active Apple ID. Share functionality works as expected on a physical iPhone.
- Swift 6 concurrency warning:
  - A warning appears on the TriviaResponse struct regarding Swift 6 actor-isolated Codable conformance. This does not affect functionality and is a known Swift 6 strictness issue with Codable conformance in networked contexts. The project targets Swift 5.


## Future Improvements:
- Adaptive UI Layout:
  - Currently several UI elements have fixed sizes hardcoded in the Auto Layout constraints, most notably the answer buttons, which may clip or truncate longer answer text. A future improvement would replace fixed heightAnchor constraints with dynamic sizing.
- Learn Mode:
  - A secondary mode that isolates missed questions and repeats them until each has been answered correctly at least once. Would shift the app from purely testing knowledge to actively building it.
- Persistent Leaderboard:
  - Local high score tracking using UserDefaults so users can see their best scores across sessions.
- Increased test coverage

