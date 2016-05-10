//
//  ViewController.swift
//  Timer
//
//  Created by Nik on 10/05/2016.
//  Copyright © 2016 notro. All rights reserved.
//

import Cocoa


class ViewController: NSViewController, NSTextFieldDelegate {
    dynamic var interval: NSDate = NSDate(timeIntervalSinceReferenceDate: 0)
    
    var asyncTimer: DispatchTimer!
    
    @IBOutlet var bgView: NSView!
    @IBOutlet var startButton: NSButton!
    @IBOutlet var questionButton: NSButton!
    @IBOutlet var timesButton: NSButton!
    @IBOutlet var timeEdit: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        questionButton.hidden = true
        
        asyncTimer = DispatchTimer(interval: 1.0, queue: dispatch_get_main_queue()) {
            self.interval = self.interval.dateByAddingTimeInterval(-1)
        }
        
        controlTextDidChange(NSNotification(name: String(), object: timeEdit))
        
    }
    
    override func viewWillAppear() {
        guard let layer = bgView.layer, let window = bgView.window else { return }
        layer.backgroundColor = window.backgroundColor.colorWithAlphaComponent(1.0).CGColor
        layer.cornerRadius = 4
    }

    override var representedObject: AnyObject? {
        didSet {
            
        }
    }

    @IBAction func startStopBtnClick(sender: NSButton) {
        guard let atimer = asyncTimer else { return }
        
        if sender.state == NSOnState { // Start timer on ON state
            atimer.startTimer()
            questionButton.hidden = false
            timesButton.hidden = true
            timeEdit.hidden = true
            
//            if let window = NSApplication.sharedApplication().keyWindow as? TranslucentWindow {
                animateBecomeTransparent()
//            }
        } else if sender.state == NSOffState { // Stop timer on OFF state
            atimer.stopTimer()
            questionButton.hidden = true
            timesButton.hidden = false
            timeEdit.hidden = false
            
//            if let window = NSApplication.sharedApplication().keyWindow as? TranslucentWindow {
                animateBecomeOpaque()
//            }
        }
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        guard let field = obj.object as? NSTextField else { return }
        if let _ = field.objectValue as? NSDate {
            startButton.enabled = true
        } else {
            startButton.enabled = false
        }
    }

    // MARK: - Animations
    func animateBecomeTransparent() {
        guard let window = bgView.window else { return }
        animateBackgroundColor(window.backgroundColor.colorWithAlphaComponent(0.0).CGColor, interval: 0.5)
    }
    
    func animateBecomeOpaque() {
        guard let window = bgView.window else { return }
        animateBackgroundColor(window.backgroundColor.colorWithAlphaComponent(1.0).CGColor, interval: 0.5)
    }
    
    private func animateBackgroundColor(color: CGColor, interval: NSTimeInterval) {
        guard let layer = bgView.layer else { return }
        
        CATransaction.begin()
            CATransaction.setAnimationDuration(interval)
            let anim = CABasicAnimation(keyPath: "backgroundColor")
            anim.fromValue = layer.backgroundColor
            layer.backgroundColor = color
            // Keep new color
            anim.removedOnCompletion = false
            anim.fillMode = kCAFillModeForwards
            layer.addAnimation(anim, forKey: "backgroundColor")
        CATransaction.commit()
    }

}

