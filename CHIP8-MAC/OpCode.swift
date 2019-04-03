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
    case random(vx: Int, value: Byte)
    case skipKeyNotPressed(vx: Int)
    case and(vx: Int, vy: Int)
    case assign(vx: Int, vy: Int)
    case skipIfNotEqual(vx: Int, value: Byte)
    case addRegisters(vx: Int, vy: Int)
    case subtractRegisters(vx: Int, vy: Int)
    case setSoundTimer(vx: Int)
    case skipRegistersNotEqual(vx: Int, vy: Int)
    case subtractXfromY(vx: Int, vy: Int)
    case or(vx: Int, vy: Int)
    case xor(vx: Int, vy: Int)
    case shiftLeft(vx: Int, vy: Int)
    case shiftRight(vx: Int, vy: Int)
    case writeMemory(vx: Int)
    case addIndex(vx: Int)
    case waitKeyPress(vx: Int)
    
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
        
        case let (0xC, vx, _, _):
            self = .random(vx: Int(vx), value: Byte(rawOpcode & 0xFF))
            
        case let (0xE, vx, 0xA, 0x1):
            self = .skipKeyNotPressed(vx: Int(vx))
        
        case let (0x8, vx, vy, 0x2):
            self = .and(vx: Int(vx), vy: Int(vy))
            
        case let (0x8, vx, vy, 0x0):
            self = .assign(vx: Int(vx), vy: Int(vy))
            
        case let (0x4, vx, _, _):
            self = .skipIfNotEqual(vx: Int(vx), value: Byte(rawOpcode & 0xFF))
            
        case let (0x8, vx, vy, 0x4):
            self = .addRegisters(vx: Int(vx), vy: Int(vy))
            
        case let (0x8, vx, vy, 0x5):
            self = .subtractRegisters(vx: Int(vx), vy: Int(vy))
            
        case let (0xF, vx, 0x1, 0x8):
            self = .setDelayTimer(vx: Int(vx))
            
        case let (0x5, vx, vy, 0x0):
            self = .skipRegistersNotEqual(vx: Int(vx), vy: Int(vy))
            
        case let (0x8, vx, vy, 0x7):
            self = .subtractXfromY(vx: Int(vx), vy: Int(vy))
            
        case let (0x8, vx, vy, 0x1):
            self = .or(vx: Int(vx), vy: Int(vy))
            
        case let (0x8, vx, vy, 0x3):
            self = .xor(vx: Int(vx), vy: Int(vy))
            
        case let (0x8, vx, vy, 0xE):
            self = .shiftLeft(vx: Int(vx), vy: Int(vy))
            
        case let (0x8, vx, vy, 0x6):
            self = .shiftRight(vx: Int(vx), vy: Int(vy))
            
        case let (0xF, vx, 0x5, 0x5):
            self = .writeMemory(vx: Int(vx))
            
        case let (0xF, vx, 0x1, 0xE):
            self = .addIndex(vx: Int(vx))
            
        case let (0xF, vx, 0x0, 0xA):
            self = .waitKeyPress(vx: Int(vx))

        default:
            print(String(format: "\nUnknown Op: %01X:%01X:%01X:%01X", n1, n2, n3, n4))
            fatalError()
        }
    }
}
