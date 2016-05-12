//
//  QuestionLapViewController.swift
//  TinyTimer
//
//  Created by Nik on 12/05/2016.
//  Copyright © 2016 notro. All rights reserved.
//

import Cocoa

class QuestionLap: NSObject {
    var questionNumber: Int
    var duration: NSDate
    var timeLeft: NSDate
    
    init(number questionNumber: Int, duration: NSDate, timeLeft: NSDate) {
        self.questionNumber = questionNumber
        self.duration = duration
        self.timeLeft = timeLeft
    }
}

protocol QuestionLapDelegate {
    func questionLapWillDisappear(questions: [QuestionLap])
}

class QuestionLapViewController: NSViewController {
    dynamic var questions: [QuestionLap] = []
    var delegate: QuestionLapDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        delegate?.questionLapWillDisappear(self.questions)
    }
    
    @IBAction func clearButtonPressed(sender: AnyObject) {
        self.questions.removeAll()
    }
}
