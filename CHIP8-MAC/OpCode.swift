//
//  OpCode.swift
//  CHIP8-MAC
//
//  Created by Kemal on 2/4/19.
//  Copyright © 2019 Kemal. All rights reserved.
//

import Foundation

enum OpCode {
    
    case clearScreen
    case setValue(vx: Int, value: Byte)
    case setIndex(address: Word)
    case draw(x: Int, y: Int, rows: Byte)
    case callSub(address: Word)
    case storeBinaryCodedDecimal(vx: Int)
    case registerLoad(vx: Int)
    case setSpriteAddress(vx: Int)
    case addToRegister(vx: Int, value: Byte)
    case returnFromSub
    case setDelayTimer(vx: Int)
    case storeDelayTimer(vx: Int)
    case skipIfEqual(vx: Int, value: Byte)
    case jump(address: Word)
    
    init(rawOpcode: Word) {
        let n1: Byte = Byte((rawOpcode & 0xF000) >> 12)
        let n2: Byte = Byte((rawOpcode & 0x0F00) >> 8)
        let n3: Byte = Byte((rawOpcode & 0x00F0) >> 4)
        let n4: Byte = Byte(rawOpcode & 0x000F)
        
        switch (n1, n2, n3, n4) {
        case (0x0, 0x0, 0xE, 0x0):
            self = .clearScreen

        case let (0x6, x, _, _):
            self = .setValue(vx: Int(x), value: Byte(rawOpcode & 0xFF))

        case (0xA, _, _, _):
            self = .setIndex(address: rawOpcode & 0xFFF)

        case let (0xD, vx, vy, rows):
            self = .draw(x: Int(vx), y: Int(vy), rows: rows)

        case (0x2, _, _, _):
            self = .callSub(address: rawOpcode & 0xFFF)
            
        case let (0xF, vx, 3, 3):
            self = .storeBinaryCodedDecimal(vx: Int(vx))
            
        case let (0xF, vx, 6, 5):
            self = .registerLoad(vx: Int(vx))
            
        case let (0xF, vx, 2, 9):
            self = .setSpriteAddress(vx: Int(vx))
        
        case let (0x7, vx, _, _):
            self = .addToRegister(vx: Int(vx), value: Byte(rawOpcode & 0xFF))
        
        case (0x0, 0x0, 0xE, 0xE):
            self = .returnFromSub
            
        case let (0xF, vx, 0x1, 0x5):
            self = .setDelayTimer(vx: Int(vx))
        
        case let (0xF, vx, 0x0, 0x7):
            self = .storeDelayTimer(vx: Int(vx))
        
        case let (0x3, vx, _, _):
            self = .skipIfEqual(vx: Int(vx), value: Byte(rawOpcode & 0xFF))
            
        case (0x1, _, _, _):
            self = .jump(address: rawOpcode & 0xFFF)

        default:
            print(String(format: "Unknown Op: %01X %01X %01X %01X", n1, n2, n3, n4))
            fatalError()
        }
    }
}
