//
//  ClosedCaptioning.swift
//  SwiftUIClosedCaptioning
//
//  Created by Daniel Bolella on 10/9/19.
//  Copyright © 2019 Daniel Bolella. All rights reserved.
//

import Foundation
import Speech
import Firebase

class ClosedCaptioning: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var captioning: String = "Waiting to Start!"
    @Published var translation: String = "Buon Giorno!"
    @Published var isPlaying: Bool = false
    @Published var micEnabled: Bool = false
    
    private let translator: Translator
    
    init (){
        let options = TranslatorOptions(sourceLanguage: .en, targetLanguage: .it)
        translator = NaturalLanguage.naturalLanguage().translator(options: options)
        translator.downloadModelIfNeeded { (error) in
            guard error == nil else { return }
            self.micEnabled = true
        }
    }
    
    //Thanks to https://developer.apple.com/documentation/speech/recognizing_speech_in_live_audio
    func startRecording() throws {
        
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode

        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                // Update the text view with the results.
                self.captioning = result.bestTranscription.formattedString
                self.translator.translate(result.bestTranscription.formattedString) { (translatedText, error) in
                    guard error == nil,
                        let translatedText = translatedText
                        else { return }
                    self.translation = translatedText
                }
                self.translate(text: result.bestTranscription.formattedString)
                isFinal = result.isFinal
                print("Text \(result.bestTranscription.formattedString)")
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.isPlaying = false
            }
        }

        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    func micButtonTapped(){
        if audioEngine.isRunning {
            recognitionRequest?.endAudio()
            audioEngine.stop()
            isPlaying = false
        } else {
            do {
                try startRecording()
                isPlaying = true
            } catch {
                isPlaying = false
            }
        }
    }
    
    func translate(text: String){
        self.translator.translate(text) { (translatedText, error) in
            guard error == nil, let translatedText = translatedText else { return }
            self.translation = translatedText
        }
    }
    
    func getPermission(){
        // Asynchronously make the authorization request.
        SFSpeechRecognizer.requestAuthorization { authStatus in

            // Divert to the app's main thread so that the UI
            // can be updated.
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.micEnabled = true
                    
                case .denied, .restricted, .notDetermined:
                    self.micEnabled = false
                    
                default:
                    self.micEnabled = false
                }
            }
        }
    }
}
