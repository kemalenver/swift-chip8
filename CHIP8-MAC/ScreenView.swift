//
//  ScreenView.swift
//  CHIP8-MAC
//
//  Created by Kemal on 2/4/19.
//  Copyright © 2019 Kemal. All rights reserved.
//

import Cocoa

class ScreenView: NSView {

    let blockSize = 5

    var graphics: [Byte] = [Byte](repeating: 0, count: 64 * 32)
    
    override func draw(_ dirtyRect: NSRect) {

        super.draw(dirtyRect)
        
        NSColor.black.setFill()
        self.bounds.fill()
        
        NSColor.white.setStroke()
        let rect = CGRect(x: 0, y: 0, width: 64*5, height: 32*5)
        NSBezierPath.stroke(rect)
        
        NSColor.white.setFill()
        let rectSize = CGSize(width: 10, height: 10)
        
        for i in 0..<graphics.count {
            
            let x = i % 64
            let y = i % 32
            
            if self.graphics[i] == 1 {
                NSRect(origin: CGPoint(x: CGFloat(x) * rectSize.width, y: CGFloat(y) * rectSize.height), size: rectSize).fill()
            }
            
        }
        for x in 0..<64 {
            for y in 0..<32 {
                if self.graphics[y * 64 + x] == 1 {
                    NSRect(origin: CGPoint(x: CGFloat(x) * rectSize.width, y: CGFloat(y) * rectSize.height), size: rectSize).fill()
                }
            }
        }
    }
    
}
