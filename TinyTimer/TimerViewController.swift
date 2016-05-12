//
//  TimerViewController.swift
//  Timer
//
//  Created by Nik on 10/05/2016.
//  Copyright © 2016 notro. All rights reserved.
//

import Cocoa

enum TimerState {
    case Running, Stopped
}

enum TransparencyState {
    case Transparent, Opaque
}

class TimerViewController: NSViewController, NSTextFieldDelegate, QuestionLapDelegate {
    dynamic var interval: NSDate = NSDate(timeIntervalSinceReferenceDate: 0)
    var startTime: NSDate = NSDate()
    
    var asyncTimer: DispatchTimer!
    var currentTimerState = TimerState.Stopped
    var currentTransparencyState = TransparencyState.Opaque
    
    @IBOutlet var bgView: NSView!
    @IBOutlet var startButton: NSButton!
    @IBOutlet var questionButton: NSButton!
    @IBOutlet var timesButton: NSButton!
    @IBOutlet var timeEdit: NSTextField!
    @IBOutlet var buttonBar: NSStackView!
    
    var questionLaps: [QuestionLap] = []

    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        questionButton.hidden = true
        
        asyncTimer = DispatchTimer(interval: 1.0, queue: dispatch_get_main_queue()) {
            // Stop the timer when it expires
            self.interval = self.interval.dateByAddingTimeInterval(-1)
            if self.calculateSecondsRemaining(self.interval) <= 0 {
                self.enterTimerState(TimerState.Stopped)
                self.startButton.enabled = false
            }
        }
        
        controlTextDidChange(NSNotification(name: String(), object: timeEdit))
        
        let ta = NSTrackingArea(rect: self.view.bounds, options:
            [NSTrackingAreaOptions.MouseEnteredAndExited, NSTrackingAreaOptions.ActiveAlways],
                                owner: self, userInfo: nil)
        self.view.addTrackingArea(ta)
    }
    
    override func viewWillAppear() {
        guard let layer = bgView.layer else { return }
        layer.backgroundColor = NSColor.windowBackgroundColor().colorWithAlphaComponent(1.0).CGColor
        layer.cornerRadius = 4
        layer.borderColor = NSColor.windowFrameColor().CGColor
        layer.borderWidth = 1.0
    }

    override var representedObject: AnyObject? {
        didSet {
            
        }
    }

    // MARK: - Actions
    @IBAction func startStopBtnClick(sender: NSButton) {
        if sender.state == NSOnState { // Start timer on ON state
            enterTimerState(TimerState.Running)
        } else if sender.state == NSOffState { // Stop timer on OFF state
            enterTimerState(TimerState.Stopped)
        }
    }
    
    func enterTimerState(state: TimerState) {
        guard let atimer = asyncTimer where state != currentTimerState else { return }
        
        currentTimerState = state
        
        switch state {
        case .Running:
            atimer.startTimer()
            questionButton.hidden = false
            timesButton.hidden = true
            timeEdit.hidden = true
//            buttonBar.hidden = true // Don't hide, the mouse actions will do this. The mouse is on the button when it is pressed.
            
            if startButton.state != NSOnState {
                startButton.state = NSOnState
            }
            
            animateBecomeTransparent()
            break;
        case .Stopped:
            atimer.stopTimer()
            questionButton.hidden = true
            timesButton.hidden = false
            timeEdit.hidden = false
            buttonBar.hidden = false
            
            if startButton.state != NSOffState {
                startButton.state = NSOffState
            }
            
            animateBecomeOpaque()
            break;
        }
    }
    
    @IBAction func questionBtnPress(sender: AnyObject) {
        let duration = NSDate(timeIntervalSinceReferenceDate:
            Double(
                calculateSecondsRemaining(questionLaps.count > 0 ? questionLaps.last!.timeLeft : self.startTime)
                    - calculateSecondsRemaining(self.interval)))
        
        questionLaps.append(QuestionLap(number: questionLaps.count + 1,
            duration: duration,
            timeLeft: self.interval))
    }
    
    
    // MARK: - NSTextFieldDelegate
    override func controlTextDidChange(obj: NSNotification) {
        guard let field = obj.object as? NSTextField else { return }
        if let newInterval = field.objectValue as? NSDate where calculateSecondsRemaining(newInterval) > 0 {
            startTime = newInterval
            
            startButton.enabled = true
        } else {
            startButton.enabled = false
        }
    }
    
    // MARK: - NSResponder (mouse in and out for background view)
    override func mouseEntered(theEvent: NSEvent) {
        super.mouseEntered(theEvent)
        
        if currentTimerState == .Running {
            animateBecomeOpaque()
            buttonBar.hidden = false
        }
    }
    
    override func mouseExited(theEvent: NSEvent) {
        super.mouseExited(theEvent)
        
        if currentTimerState == .Running {
            animateBecomeTransparent()
            buttonBar.hidden = true
        }
    }

    // MARK: - Animations
    func animateBecomeTransparent() {
        guard currentTransparencyState != .Transparent else { return }
        
        currentTransparencyState = .Transparent
        animateBackgroundColor(0.0, interval: 0.2)
    }
    
    func animateBecomeOpaque() {
        guard currentTransparencyState != .Opaque else { return }
        
        currentTransparencyState = .Opaque
        animateBackgroundColor(1.0, interval: 0.2)
    }
    
    private func animateBackgroundColor(opacity: Float, interval: NSTimeInterval) {
        guard let bglayer = bgView.layer else { return }
        
        CATransaction.begin()
            CATransaction.setAnimationDuration(interval)
            CATransaction.begin()
                let bganim = CABasicAnimation(keyPath: "backgroundColor")
                bganim.fromValue = bglayer.backgroundColor
                bglayer.backgroundColor = NSColor.windowBackgroundColor().colorWithAlphaComponent(CGFloat(opacity)).CGColor
                // Keep new color
                bganim.removedOnCompletion = false
                bganim.fillMode = kCAFillModeForwards
                bglayer.addAnimation(bganim, forKey: "backgroundColor")
            CATransaction.commit()
        
            CATransaction.begin()
                let borderanim = CABasicAnimation(keyPath: "borderColor")
                borderanim.fromValue = bglayer.borderColor
                bglayer.borderColor = NSColor.windowFrameColor().colorWithAlphaComponent(CGFloat(opacity)).CGColor
                // Keep new color
                borderanim.removedOnCompletion = false
                borderanim.fillMode = kCAFillModeForwards
                bglayer.addAnimation(borderanim, forKey: "borderColor")
            CATransaction.commit()
        CATransaction.commit()
    }
    
    // MARK: - Preparation for segue
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "QuestionLapSegue" {
            if let controller = segue.destinationController as? QuestionLapViewController {
                controller.delegate = self
                controller.questions = questionLaps
            }
        }
    }
    
    // MARK: - QuestionLapDelegate
    func questionLapWillDisappear(questions: [QuestionLap]) {
        questionLaps = questions
    }
    
    // MARK: - Misc Utility
    func calculateSecondsRemaining(date: NSDate) -> Int {
        // Calculate the number of seconds
        let components = NSCalendar.currentCalendar().components([
            NSCalendarUnit.Hour,
            NSCalendarUnit.Minute,
            NSCalendarUnit.Second], fromDate: date)
        return components.second + 60 * components.minute + 60 * 60 * components.hour
    }

}