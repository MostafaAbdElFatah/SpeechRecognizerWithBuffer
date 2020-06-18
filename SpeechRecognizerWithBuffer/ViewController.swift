//
//  ViewController.swift
//  asd
//
//  Created by Mostafa Abd ElFatah on 6/17/20.
//  Copyright © 2020 asd. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController {
    
    private var timeoutTimer: Timer?
    @IBOutlet weak var detectedTextLabel: UILabel!
    
    let audioEngine = AVAudioEngine()
    var recognitionTask: SFSpeechRecognitionTask?
    var request: SFSpeechAudioBufferRecognitionRequest!
    var speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
    }
    @IBAction func startButtonTapped(_ sender: UIButton) {
        self.recordAndRecognizeSpeech()
    }
    
    private func recordAndRecognizeSpeech(){
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        }
        catch {
            return print (error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else{
            return
        }
        if !myRecognizer.isAvailable{
            return
        }
        speechRecognizer?.delegate = self
        request = SFSpeechAudioBufferRecognitionRequest()
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler:
            { [weak self] result, error  in
                if result != nil{
                    let flag = result?.isFinal
                    
                    if flag == true {
                        print("is final")
                    }
                    if let result = result{
                        let bestString = result.bestTranscription.formattedString
                        print(bestString)
                        self?.detectedTextLabel.text = bestString
                    }else if let error = error{
                        print(error)
                    }
                    self?.timeoutTimer?.invalidate()
                    self?.timeoutTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { [weak self] _ in
                        print("the last")
                        self?.audioEngine.stop()
                    })
                }
            })
    }
    
    
    
    
    

}


extension ViewController:SFSpeechRecognitionTaskDelegate, SFSpeechRecognizerDelegate{
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        print("finish:didFinishSuccessfully")
    }
    
    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        print("finish:speechRecognitionTaskFinishedReadingAudio")
    }
    
}
