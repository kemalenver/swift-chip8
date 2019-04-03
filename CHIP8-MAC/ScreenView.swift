//
//  ScreenView.swift
//  CHIP8-MAC
//
//  Created by Kemal on 2/4/19.
//  Copyright © 2019 Kemal. All rights reserved.
//

import Cocoa

class ScreenView: NSView {

    let blockSize = 3

    var graphics: [Byte] = [Byte](repeating: 0, count: 64 * 32)
    
    override func draw(_ dirtyRect: NSRect) {

        super.draw(dirtyRect)
        
        NSColor.black.setFill()
        self.bounds.fill()
        
        
        let rect = CGRect(x: 0, y: 0, width: 64 * blockSize, height: 32 * blockSize)
        
        NSColor.red.setFill()
        NSBezierPath.fill(rect)
        
        NSColor.white.setStroke()
        NSBezierPath.stroke(rect)
        
        NSColor.white.setFill()
        let rectSize = CGSize(width: blockSize, height: blockSize)
        
        
        for i in 0..<self.graphics.count {
            
            let x = (i % 64)
            let y = (i / 64)
            
//            print("i: \(i) x: \(x) y: \(y)")
            
            if self.graphics[i] == 1 {
                NSRect(origin: CGPoint(x: CGFloat(x) * rectSize.width, y: CGFloat(y) * rectSize.height), size: rectSize).fill()
            }
        }
    }
}
