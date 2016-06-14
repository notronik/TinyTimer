//
//  TimerViewController.swift
//  Timer
//
//  Created by Nik on 10/05/2016.
//  Copyright © 2016 notro. All rights reserved.
//

import Cocoa

enum TimerState {
    case running, stopped
}

enum TransparencyState {
    case transparent, opaque
}

class TimerViewController: NSViewController, NSTextFieldDelegate, QuestionLapDelegate {
    @objc dynamic var interval: Date = Date(timeIntervalSinceReferenceDate: 0)
    var startTime: Date = Date()
    
    var asyncTimer: DispatchSourceTimer!
    var currentTimerState = TimerState.stopped
    var currentTransparencyState = TransparencyState.opaque
    
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
        questionButton.isHidden = true
        
        
        asyncTimer = DispatchSource.timer(flags: DispatchSource.TimerFlags.init(rawValue: 0), queue: DispatchQueue.main)
        asyncTimer.scheduleRepeating(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), interval: DispatchTimeInterval.seconds(1), leeway: DispatchTimeInterval.nanoseconds(10))
        
        asyncTimer.setEventHandler {
            // Stop the timer when it expires
            self.interval = self.interval.addingTimeInterval(-1)
            if self.calculateSecondsRemaining(self.interval) <= 0 {
                self.enterTimerState(TimerState.stopped)
                self.startButton.isEnabled = false
            }
        }
        
        controlTextDidChange(Notification(name: Notification.Name(""), object: timeEdit, userInfo: nil))
        
        let ta = NSTrackingArea(rect: self.view.bounds, options:
            [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways],
                                owner: self, userInfo: nil)
        self.view.addTrackingArea(ta)
    }
    
    override func viewWillAppear() {
        guard let layer = bgView.layer else { return }
        layer.backgroundColor = NSColor.windowBackgroundColor().withAlphaComponent(1.0).cgColor
        layer.cornerRadius = 4
        layer.borderColor = NSColor.windowFrameColor().cgColor
        layer.borderWidth = 1.0
    }

    override var representedObject: AnyObject? {
        didSet {
            
        }
    }
    
    deinit {
        if let atimer = asyncTimer {
            atimer.cancel()
        }
    }

    // MARK: - Actions
    @IBAction func startStopBtnClick(_ sender: NSButton) {
        if sender.state == NSOnState { // Start timer on ON state
            enterTimerState(TimerState.running)
        } else if sender.state == NSOffState { // Stop timer on OFF state
            enterTimerState(TimerState.stopped)
        }
    }
    
    func enterTimerState(_ state: TimerState) {
        guard let atimer = asyncTimer where state != currentTimerState else { return }
        
        currentTimerState = state
        
        switch state {
        case .running:
            atimer.resume()
            questionButton.isHidden = false
            timesButton.isHidden = true
            timeEdit.isHidden = true
//            buttonBar.hidden = true // Don't hide, the mouse actions will do this. The mouse is on the button when it is pressed.
            
            if startButton.state != NSOnState {
                startButton.state = NSOnState
            }
            
            animateBecomeTransparent()
            break;
        case .stopped:
            atimer.suspend()
            questionButton.isHidden = true
            timesButton.isHidden = false
            timeEdit.isHidden = false
            buttonBar.isHidden = false
            
            if startButton.state != NSOffState {
                startButton.state = NSOffState
            }
            
            animateBecomeOpaque()
            break;
        }
    }
    
    @IBAction func questionBtnPress(_ sender: AnyObject) {
        let duration = Date(timeIntervalSinceReferenceDate:
            Double(
                calculateSecondsRemaining(questionLaps.count > 0 ? questionLaps.last!.timeLeft: self.startTime)
                    - calculateSecondsRemaining(self.interval)))
        
        questionLaps.append(QuestionLap(number: questionLaps.count + 1,
            duration: duration,
            timeLeft: self.interval))
    }
    
    
    // MARK: - NSTextFieldDelegate
    override func controlTextDidChange(_ obj: Notification) {
        guard let field = obj.object as? NSTextField else { return }
        if let newInterval = field.objectValue as? Date where calculateSecondsRemaining(newInterval) > 0 {
            startTime = newInterval
            
            startButton.isEnabled = true
        } else {
            startButton.isEnabled = false
        }
    }
    
    // MARK: - NSResponder (mouse in and out for background view)
    override func mouseEntered(_ theEvent: NSEvent) {
        super.mouseEntered(theEvent)
        
        if currentTimerState == .running {
            animateBecomeOpaque()
            buttonBar.isHidden = false
        }
    }
    
    override func mouseExited(_ theEvent: NSEvent) {
        super.mouseExited(theEvent)
        
        if currentTimerState == .running {
            animateBecomeTransparent()
            buttonBar.isHidden = true
        }
    }

    // MARK: - Animations
    func animateBecomeTransparent() {
        guard currentTransparencyState != .transparent else { return }
        
        currentTransparencyState = .transparent
        animateBackgroundColor(0.0, interval: 0.2)
    }
    
    func animateBecomeOpaque() {
        guard currentTransparencyState != .opaque else { return }
        
        currentTransparencyState = .opaque
        animateBackgroundColor(1.0, interval: 0.2)
    }
    
    private func animateBackgroundColor(_ opacity: Float, interval: TimeInterval) {
        guard let bglayer = bgView.layer else { return }
        
        CATransaction.begin()
            CATransaction.setAnimationDuration(interval)
            CATransaction.begin()
                let bganim = CABasicAnimation(keyPath: "backgroundColor")
                bganim.fromValue = bglayer.backgroundColor
                bglayer.backgroundColor = NSColor.windowBackgroundColor().withAlphaComponent(CGFloat(opacity)).cgColor
                // Keep new color
                bganim.isRemovedOnCompletion = false
                bganim.fillMode = kCAFillModeForwards
                bglayer.add(bganim, forKey: "backgroundColor")
            CATransaction.commit()
        
            CATransaction.begin()
                let borderanim = CABasicAnimation(keyPath: "borderColor")
                borderanim.fromValue = bglayer.borderColor
                bglayer.borderColor = NSColor.windowFrameColor().withAlphaComponent(CGFloat(opacity)).cgColor
                // Keep new color
                borderanim.isRemovedOnCompletion = false
                borderanim.fillMode = kCAFillModeForwards
                bglayer.add(borderanim, forKey: "borderColor")
            CATransaction.commit()
        CATransaction.commit()
    }
    
    // MARK: - Preparation for segue
    override func prepare(for segue: NSStoryboardSegue, sender: AnyObject?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "QuestionLapSegue" {
            if let controller = segue.destinationController as? QuestionLapViewController {
                controller.delegate = self
                controller.questions = questionLaps
            }
        }
    }
    
    // MARK: - QuestionLapDelegate
    func questionLapWillDisappear(_ questions: [QuestionLap]) {
        questionLaps = questions
    }
    
    // MARK: - Misc Utility
    func calculateSecondsRemaining(_ date: Date) -> Int {
        // Calculate the number of seconds
        let components = Calendar.current().components([
            Calendar.Unit.hour,
            Calendar.Unit.minute,
            Calendar.Unit.second], from: date)
        return components.second! + 60 * components.minute! + 60 * 60 * components.hour!
    }

}
