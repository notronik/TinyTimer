//
//  QuestionLapViewController.swift
//  TinyTimer
//
//  Created by Nik on 12/05/2016.
//  Copyright © 2016 notro. All rights reserved.
//

import Cocoa

class QuestionLap: NSObject {
    @objc var questionNumber: Int
    @objc var duration: Date
    @objc var timeLeft: Date
    
    init(number questionNumber: Int, duration: Date, timeLeft: Date) {
        self.questionNumber = questionNumber
        self.duration = duration
        self.timeLeft = timeLeft
    }
}

protocol QuestionLapDelegate {
    func questionLapWillDisappear(_ questions: [QuestionLap])
}

class QuestionLapViewController: NSViewController {
    @objc dynamic var questions: [QuestionLap] = []
    var delegate: QuestionLapDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        delegate?.questionLapWillDisappear(self.questions)
    }
    
    @IBAction func clearButtonPressed(_ sender: AnyObject) {
        self.questions.removeAll()
    }
}
