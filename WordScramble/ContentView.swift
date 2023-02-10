//
//  ContentView.swift
//  WordScramble
//
//  Created by Matheus Müller on 09/02/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never) // Removes capital letters at the beginning
                }
                
                Section {
                    Text("\(score)")
                } header: {
                    Text("Score")
                        .font(.headline)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar {
                Button("Restart Game", action: restartGame)
            }
            .onSubmit(addNewWord) // Executed when the user press Return(Enter)
            .onAppear(perform: startGame) // Executes the function when the view is shown
            .alert(errorTitle, isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func restartGame() {
        usedWords = [String]()
        newWord = ""
        score = 0
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt file from Bundle!")
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not Possible", message: "You can't spell that word from '\(rootWord)'")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isEqual(word: answer) else {
            wordError(title: "Repeated word", message: "This word is the same as the initial word!")
            return
        }
        
        guard isTooSmall(word: answer) else {
            wordError(title: "Word is too small", message: "You need to write a word longer than 3 characters!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        if usedWords.count == 1 { // For every right word +5 points
            score = 5
        } else {
            score += 5
        }
        
        switch newWord.utf16.count { // More points depending on word length = +1 point per character
        case 3:
            score += 3
        case 4:
            score += 4
        case 5:
            score += 5
        case 6:
            score += 6
        case 7:
            score += 7
        default:
            score = score
        }
        
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt file from Bundle!")
    }
    
    func isTooSmall(word: String) -> Bool {
        word.utf16.count < 3 ? false : true
    }
    
    func isEqual(word: String) -> Bool {
        if word != rootWord {
            return true
        } else {
            return false
        }
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
