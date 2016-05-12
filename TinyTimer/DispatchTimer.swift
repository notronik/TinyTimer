//
//  DispatchTimer.swift
//  Timer
//
//  Created by Nik on 10/05/2016.
//  Copyright © 2016 notro. All rights reserved.
//

import Foundation

class DispatchTimer {
    var timer: dispatch_source_t
    
    /**
     Create a new dispatch timer.
     
     - parameter interval: Interval for firings of this timer in seconds.
     - parameter queue:    Queue to run the timer on.
     - parameter block:    Block/Closure to run on fire.
     */
    init(interval: Double, queue: dispatch_queue_t, block: dispatch_block_t) {
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        
        dispatch_source_set_timer(self.timer,
                                  dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC))),
                                  UInt64(interval * Double(NSEC_PER_SEC)), UInt64(10.0 * Double(NSEC_PER_MSEC)))
        dispatch_source_set_event_handler(self.timer, block)
    }
    
    deinit {
        if running {
            stopTimer()
        }
        dispatch_source_cancel(self.timer)
    }
    
    /**
     Start the timer.
     */
    func startTimer() {
        dispatch_resume(self.timer)
        _running = true
    }
    
    /**
     Stop the timer.
     */
    func stopTimer() {
        dispatch_suspend(self.timer)
        _running = false
    }
    
    private var _running: Bool = false
    var running: Bool {
        get {
            return self._running
        }
    }
}