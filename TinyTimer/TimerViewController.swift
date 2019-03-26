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

class TimerViewController: NSViewController {
  @objc dynamic var interval: Date = Date(timeIntervalSinceReferenceDate: 0)
  var startTime: Date = Date()

  var asyncTimer: DispatchSourceTimer!
  var currentTimerState = TimerState.stopped
  var currentTransparencyState = TransparencyState.opaque

  @IBOutlet var bgView: NSView!
  @IBOutlet var startButton: NSButton!
  @IBOutlet var timeEdit: NSTextField!
  @IBOutlet var buttonBar: NSStackView!

  // MARK: - View Setup
  override func viewDidLoad() {
    super.viewDidLoad()

    asyncTimer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags.init(rawValue: 0), queue: DispatchQueue.main)
    asyncTimer.schedule(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), repeating: DispatchTimeInterval.seconds(1), leeway: DispatchTimeInterval.nanoseconds(10))
        
    asyncTimer.setEventHandler {
      // Stop the timer when it expires
      self.interval = self.interval.addingTimeInterval(-1)
      if self.calculateSecondsRemaining(self.interval) <= 0 {
        self.enterTimerState(TimerState.stopped)
        self.startButton.isEnabled = false
      }
    }
        
    controlTextDidChange(Notification(name: Notification.Name(""), object: timeEdit, userInfo: nil))
        
    let ta = NSTrackingArea(rect: self.view.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
    self.view.addTrackingArea(ta)
  }
    
  override func viewWillAppear() {
    guard let layer = bgView.layer else { return }
    layer.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(1.0).cgColor
    layer.cornerRadius = 4
    layer.borderColor = NSColor.windowFrameColor.cgColor
    layer.borderWidth = 1.0
  }

  override var representedObject: Any? {
    didSet { }
  }
    
  deinit {
    if let atimer = asyncTimer {
      atimer.cancel()
    }
  }
    
  private func enterTimerState(_ state: TimerState) {
    guard let atimer = asyncTimer, state != currentTimerState else { return }

    currentTimerState = state

    switch state {
    case .running:
      atimer.resume()
      timeEdit.isHidden = true

      if startButton.state != .on {
        startButton.state = .on
      }

      animateBecomeTransparent()
      break;

    case .stopped:
      atimer.suspend()
      timeEdit.isHidden = false
      buttonBar.isHidden = false

      if startButton.state != .off {
          startButton.state = .off
      }

      animateBecomeOpaque()
      break;
    }
  }

  private func calculateSecondsRemaining(_ date: Date) -> Int {
    // Calculate the number of seconds
    let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
    return components.second! + 60 * components.minute! + 60 * 60 * components.hour!
  }
}

// MARK: - Actions
extension TimerViewController {
  @IBAction func startStopBtnClick(_ sender: NSButton) {
    if sender.state == .on { // Start timer on ON state
      enterTimerState(TimerState.running)
    } else if sender.state == .off { // Stop timer on OFF state
      enterTimerState(TimerState.stopped)
    }
  }
}

// MARK: - NSTextFieldDelegate
extension TimerViewController: NSTextFieldDelegate {

  func controlTextDidChange(_ obj: Notification) {
    guard let field = obj.object as? NSTextField else { return }

    if let newInterval = field.objectValue as? Date,
      calculateSecondsRemaining(newInterval) > 0 {
      startTime = newInterval
      startButton.isEnabled = true
    } else {
      startButton.isEnabled = false
    }
  }
}

// MARK: - NSResponder (mouse in and out for background view)
extension TimerViewController {

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        
        if currentTimerState == .running {
            animateBecomeOpaque()
            buttonBar.isHidden = false
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        
        if currentTimerState == .running {
            animateBecomeTransparent()
            buttonBar.isHidden = true
        }
    }
}

// MARK: - Animations
extension TimerViewController {

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
                bglayer.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(CGFloat(opacity)).cgColor
                // Keep new color
                bganim.isRemovedOnCompletion = false
                bganim.fillMode = .forwards
                bglayer.add(bganim, forKey: "backgroundColor")
            CATransaction.commit()
        
            CATransaction.begin()
                let borderanim = CABasicAnimation(keyPath: "borderColor")
                borderanim.fromValue = bglayer.borderColor
                bglayer.borderColor = NSColor.windowFrameColor.withAlphaComponent(CGFloat(opacity)).cgColor
                // Keep new color
                borderanim.isRemovedOnCompletion = false
                borderanim.fillMode = .forwards
                bglayer.add(borderanim, forKey: "borderColor")
            CATransaction.commit()
        CATransaction.commit()
    }
}
