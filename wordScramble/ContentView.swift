//
//  ContentView.swift
//  wordScramble
//
//  Created by Nadia Ahmadian on 2023-01-15.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    //Alerts
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                    .textInputAutocapitalization(.never)                }
                Section{
                    ForEach(usedWords, id:\.self){
                        word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }.navigationTitle(rootWord)
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle,isPresented: $showingError){
                    Button("OK",role: .cancel){}
                } message : {
                    Text(errorMessage)
                }
                .toolbar {
                    Button("Start New Game",action: startGame)
                }
        }
    }
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startwords = try? String(contentsOf: startWordsURL){
                let allWords = startwords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                 return
            }
        }
           fatalError("Could not load start.txt from bundle")
    }
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count>0 else {return}
        
        guard isOriginal(word: answer) else{
            wordError(title: "Word used already", message: "Be more unique")
            return
        }
        guard isPossible(word: answer) else{
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        guard isReal(word: answer) else{
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        guard isLongEnough(word: answer) else{
            wordError(title: "Word is too short", message: "Tooooooo short!")
            return
        }
        
        guard isDifferFromRoot(word: answer) else{
            wordError(title: "Word is the same as the root", message: "Be more creative lazy ass!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func isOriginal(word : String) -> Bool{
        !usedWords.contains(word)
    }
    
    func isPossible(word:String) -> Bool{
        var tempWord = rootWord
        
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        
        return true
    }
    ///The final method is hard, because we need to use UITextChecker from UIKit. In order to bridge Swift strings to Objective-C strings safely, we need to create an instance of NSRange using the UTF-16 count of our Swift string. This isn’t nice, I know, but I’m afraid it’s unavoidable until Apple cleans up these APIs.
    
    func isReal(word : String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    func isLongEnough(word : String)->Bool{
        (word.count >= 3) ?  true : false

    }
    
    func isDifferFromRoot(word : String)-> Bool {
        word != rootWord ? true : false
            
    }
    
    
    func wordError(title : String , message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
