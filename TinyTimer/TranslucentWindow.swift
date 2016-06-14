//
//  TranslucentWindow.swift
//  Timer
//
//  Created by Nik on 10/05/2016.
//  Copyright © 2016 notro. All rights reserved.
//

import Cocoa
import CoreGraphics

class TranslucentWindow: NSWindow {
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        
//        setup()
//    }
//    
    override init(contentRect: NSRect, styleMask aStyle: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        
        setup()
    }
    
    private func setup() {
        self.level = Int(CGWindowLevelKey.floatingWindow.rawValue) // Make the window float
        self.ignoresMouseEvents = false // Don't ignore mouse events
        self.backgroundColor = self.backgroundColor.withAlphaComponent(0.0)
        self.isOpaque = true
    }
    
    override var canBecomeKey: Bool {
        get {
            return true
        }
    }
    
    // MARK: - Make the window draggable
    // Taken from https://developer.apple.com/library/mac/samplecode/RoundTransparentWindow/Listings/Classes_CustomWindow_m.html
    var initialClickLocation: NSPoint = NSPoint()
    override func mouseDown(_ theEvent: NSEvent) {
        initialClickLocation = theEvent.locationInWindow
    }
    
    override func mouseDragged(_ theEvent: NSEvent) {
        guard let screenVisibleFrame = NSScreen.main()?.visibleFrame else { return }
        
        let windowFrame = self.frame
        var newOrigin = windowFrame.origin
        let currentLocation = theEvent.locationInWindow
        
        newOrigin.x += (currentLocation.x - initialClickLocation.x)
        newOrigin.y += (currentLocation.y - initialClickLocation.y)
        
        if (newOrigin.y + windowFrame.size.height) > (screenVisibleFrame.origin.y + screenVisibleFrame.size.height) {
            newOrigin.y = screenVisibleFrame.origin.y + (screenVisibleFrame.size.height - windowFrame.size.height);
        }
        
        self.setFrameOrigin(newOrigin)
    }
    
}
