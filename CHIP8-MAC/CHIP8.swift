//
//  Copyright © 2019 Kemal. All rights reserved.
//

import Foundation

typealias Byte = UInt8
typealias Word = UInt16

struct Fonts {
    static let Standard: [Byte] = [
    /* 0 */ 0xF0, 0x90, 0x90, 0x90, 0xF0,
    /* 1 */ 0x20, 0x60, 0x20, 0x20, 0x70,
    /* 2 */ 0xF0, 0x10, 0xF0, 0x80, 0xF0,
    /* 3 */ 0xF0, 0x10, 0xF0, 0x10, 0xF0,
    /* 4 */ 0x90, 0x90, 0xF0, 0x10, 0x10,
    /* 5 */ 0xF0, 0x80, 0xF0, 0x10, 0xF0,
    /* 6 */ 0xF0, 0x80, 0xF0, 0x90, 0xF0,
    /* 7 */ 0xF0, 0x10, 0x20, 0x40, 0x40,
    /* 8 */ 0xF0, 0x90, 0xF0, 0x90, 0xF0,
    /* 9 */ 0xF0, 0x90, 0xF0, 0x10, 0xF0,
    /* A */ 0xF0, 0x90, 0xF0, 0x90, 0x90,
    /* B */ 0xE0, 0x90, 0xE0, 0x90, 0xE0,
    /* C */ 0xF0, 0x80, 0x80, 0x80, 0xF0,
    /* D */ 0xE0, 0x90, 0x90, 0x90, 0xE0,
    /* e */ 0xF0, 0x80, 0xF0, 0x80, 0xF0,
    /* F */ 0xF0, 0x80, 0xF0, 0x80, 0x80
    ]
}

class CHIP8 {

    // 4k of memory, 512 bytes
    // 0x000-0x1FF - Chip 8 interpreter (contains font set in emu)
    // 0x050-0x0A0 - Used for the built in 4x5 pixel font set (0-F)
    // 0x200-0xFFF - Program ROM and work RAM
    var memory: [Byte] = [Byte](repeating: 0, count: 4096)

    // 16 registers v0...vE.  last register is a carry flag
    var V: [Byte] = [Byte](repeating: 0, count: 16)

    // index register
    var I: Word = 0

    // Program Counter, programs start at address 200
    var pc: Word = 0x200

    var graphics: [Byte] = [Byte](repeating: 0, count: 64 * 32)

    var delayTimer: Byte = 0
    var soundTimer: Byte = 0

    var stack: [Word] = [Word](repeating: 0, count: 16)
    var sp: Int = 0

    var drawFlag: Bool = false

    init(program: [Byte]) {
        self.loadInterpreter()
        self.loadFont()
        self.load(program: program)
    }

    private func loadInterpreter() {
        // Interpreter is stored from x0 to x1FF
        let interpreter: [Byte] = Array(repeating: 0x0, count: 0x1FF)
        self.memory.replaceSubrange(0x00..<0x00 + interpreter.count, with: interpreter)
    }

    private func loadFont() {
        // Fonts are stored at offset x50
        self.memory.replaceSubrange(0x50..<0x50+Fonts.Standard.count, with: Fonts.Standard)
    }

    private func load(program: [Byte]) {
        // Programs are stored from offset x200
        self.memory.replaceSubrange(0x200..<0x200 + program.count, with: program)
        pc = 0x200
    }

    func step() {
        
        self.drawFlag = false
        
        let opCode = self.fetchOpCode()
        
        switch opCode {

        case .clearScreen:
            self.clearScreen()

        case .setValue(let vx, let value):
            self.setValue(vx: vx, value: value)
            
        case .setIndex(let address):
            self.setIndex(address: address)
            
        case .draw(let vx, let vy, let rows):
            self.draw(vx: vx, vy: vy, rows: rows)
            
        case .callSub(let address):
            self.callSub(address: address)
            
        case .storeBinaryCodedDecimal(let vx):
            self.storeBinaryCodedDecimal(vx: vx)
            
        case .registerLoad(let vx):
            self.registerLoad(vx: vx)
            
        case .setSpriteAddress(let vx):
            self.setSpriteAddress(vx: vx)
            
        case .addToRegister(let vx, let value):
            self.addToRegister(vx: vx, value: value)
            
        case .returnFromSub:
            self.returnFromSub()
            
        case .setDelayTimer(let vx):
            self.setDelayTimer(vx: vx)
            
        case .storeDelayTimer(let vx):
            self.storeDelayTimer(vx: vx)

        case .skipIfEqual(let vx, let value):
            self.skipIfEqual(vx: vx, value: value)

        case .jump(let address):
            self.jump(address: address)
        }
        
        if delayTimer > 0 {
            delayTimer -= 1
        }
    }
    
    private func fetchOpCode() -> OpCode {
        
        let opCodeLeft = self.memory[Int(self.pc)]
        let opCodeRight = self.memory[Int(self.pc) + 1]
        let rawOpCode = Word(opCodeLeft) << 8 | Word(opCodeRight)
        
        let opCode = OpCode(rawOpcode: rawOpCode)
        
        return opCode
    }
    
    private func clearScreen() {
        for i in 0..<self.graphics.count {
            self.graphics[i] = Byte(0)
        }

        self.drawFlag = true
        self.pc += 2
   }
    
    private func setValue(vx: Int, value: Byte) {
        print("set value \(vx) | \(value)")
        self.V[vx] = value
        pc += 2
    }
    
    private func setIndex(address: Word) {
        print("set index \(address)")
        self.I = address
        pc += 2
    }
    
    // TODO
    private func draw(vx: Int, vy: Int, rows: Byte) {
        print("draw")
        
        let startX = Int(self.V[vx])
        let startY = Int(self.V[vy])
        
        self.V[0xF] = 0
        
        for y in 0..<Int(rows) {
            var pixelRow = self.memory[Int(I) + y]
            for x in 0..<8 {
                if (pixelRow & 0x80) != 0 {
                    let screenY = (startY + y) % 32
                    let screenX = (startX + x) % 64
                    let screenIndex = (screenY * 32) + screenX
                    if self.graphics[screenIndex] == 1 {
                        V[0xF] = 1
                    }
                    self.graphics[screenIndex] ^= 1
                }
                pixelRow <<= 1
            }
        }
        
        self.drawFlag = true
        pc += 2
    }
    
    private func callSub(address: Word) {
        print("call sub \(address)")
        self.stack[self.sp] = self.pc
        self.sp += 1
        self.pc = address
    }
    
    private func storeBinaryCodedDecimal(vx: Int) {
        print("store binary coded dec \(vx)")
        
        let val = self.V[vx]
        let address = Int(self.I)
        
        self.memory[address] = val / 100
        self.memory[address + 1] = (val / 10) % 10
        self.memory[address + 2] = (val / 100) % 10
        
        self.pc += 2
    }

    private func registerLoad(vx: Int) {
        print("Loading registers \(vx)")
        let startAddress = Int(self.I)
        
        for i: Int in 0...vx {
            self.V[i] = self.memory[startAddress + i]
        }
        
        self.pc += 2
    }

    private func setSpriteAddress(vx: Int) {
        print("Set sprite address \(vx)")
        self.I = Word(self.V[vx] * 5)
        self.pc += 2
    }
    
    private func addToRegister(vx: Int, value: Byte) {
        print("Adding to register \(vx) \(value)")
        self.V[vx] = self.V[vx] &+ value
        self.pc += 2
    }
    
    private func returnFromSub() {
        print("return from sub")
        
        self.sp -= 1
        self.pc = self.stack[self.sp]
        
        self.pc += 2
    }
    
    private func setDelayTimer(vx: Int) {
        print("Set delay timer")
        
        self.delayTimer = self.V[vx]
        self.pc += 2
    }
    
    private func storeDelayTimer(vx: Int) {
        print("store delay timer \(vx)")
    
        self.V[vx] = self.delayTimer
        self.pc += 2
    }
    
    private func skipIfEqual(vx: Int, value: Byte) {
        
        print("skip if equal \(vx) \(value)")
        
        if self.V[vx] == value {
            self.pc += 2
        }
        
        self.pc += 2
    }
    
    private func jump(address: Word) {
        
        print("jump \(address)")
        
        self.pc = address
    }
    
    
    
    func memoryDescription() -> String {

        var memoryDescription = ""

        let rowSize = 32
        let numberOfRows = self.memory.count / rowSize

        for i in 0..<rowSize {
            memoryDescription += "\(String(format:"%02X", i)) | "
        }
        memoryDescription += "\n"
        for _ in 0..<rowSize {
            memoryDescription += "-- | "
        }
        memoryDescription += "\n"

        for i in 0..<numberOfRows {

            for j in i*rowSize..<(i*rowSize + rowSize) {
                memoryDescription += "\(String(format:"%02X", self.memory[j])) | "
            }
            memoryDescription += "\n"
        }

        return memoryDescription
    }
}

