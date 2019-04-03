//
//  Copyright © 2019 Kemal. All rights reserved.
//

import Foundation

typealias Byte = UInt8
typealias Word = UInt16

struct Fonts {
    static let Standard: [Byte] = [
        0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
        0x20, 0x60, 0x20, 0x20, 0x70, // 1
        0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
        0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
        0x90, 0x90, 0xF0, 0x10, 0x10, // 4
        0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
        0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
        0xF0, 0x10, 0x20, 0x40, 0x40, // 7
        0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
        0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
        0xF0, 0x90, 0xF0, 0x90, 0x90, // A
        0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
        0xF0, 0x80, 0x80, 0x80, 0xF0, // C
        0xE0, 0x90, 0x90, 0x90, 0xE0, // D
        0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
        0xF0, 0x80, 0xF0, 0x80, 0x80  // F
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
    
    public enum Key: Byte, CaseIterable {
        case num0 = 0x0
        case num1 = 0x1
        case num2 = 0x2
        case num3 = 0x3
        case num4 = 0x4
        case num5 = 0x5
        case num6 = 0x6
        case num7 = 0x7
        case num8 = 0x8
        case num9 = 0x9
        case A = 0xA
        case B = 0xB
        case C = 0xC
        case D = 0xD
        case E = 0xE
        case F = 0xF
    }
    private var keypad = [Bool](repeating: false, count: Key.allCases.count)
    private var lastPressedKey: Key?

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
//        self.memory.replaceSubrange(0..<Fonts.Standard.count, with: Fonts.Standard)
        self.memory.replaceSubrange(0x50..<0x50+Fonts.Standard.count, with: Fonts.Standard)
    }

    private func load(program: [Byte]) {
        // Programs are stored from offset x200
        self.memory.replaceSubrange(0x200..<0x200 + program.count, with: program)
        self.pc = 0x200
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

        case .random(let vx, let value):
            self.random(vx: vx, value: value)
        
        case .skipKeyNotPressed(let vx):
            self.skipKeyNotPressed(vx: vx)
        
        case .and(let vx, let vy):
            self.and(vx: vx, vy: vy)
        
        case .assign(let vx, let vy):
            self.assign(vx: vx, vy: vy)
            
        case .skipIfNotEqual(let vx, let value):
            self.skipIfNotEqual(vx: vx, value: value)
            
        case .addRegisters(let vx, let vy):
            self.addRegisters(vx: vx, vy: vy)

        case .subtractRegisters(let vx, let vy):
            self.subtractRegisters(vx: vx, vy: vy)

        case .setSoundTimer(let vx):
            self.setSoundTimer(vx: vx)

        case .skipRegistersNotEqual(let vx, let vy):
            self.skipRegistersNotEqual(vx: vx, vy: vy)
            
        case .subtractXfromY(let vx, let vy):
            self.subtractXfromY(vx: vx, vy: vy)

        case .or(let vx, let vy):
            self.or(vx: vx, vy: vy)
        case .xor(let vx, let vy):
            self.xor(vx: vx, vy: vy)

        case .shiftLeft(let vx, let vy):
            self.shiftLeft(vx: vx, vy: vy)

        case .shiftRight(let vx, let vy):
            self.shiftRight(vx: vx, vy: vy)
            
        case .writeMemory(let vx):
            self.writeMemory(vx: vx)
            
        case .addIndex(let vx):
            self.addIndex(vx: vx)
            
        case .waitKeyPress(let vx):
            if self.waitKeyPress(vx: vx) {
                return
            }
        }
        
        if self.delayTimer > 0 {
            self.delayTimer -= 1
        }
        
        if self.soundTimer > 0 {
            self.soundTimer -= 1
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
        print("clearScreen")
        for i in 0..<self.graphics.count {
            self.graphics[i] = Byte(0)
        }

        self.drawFlag = true
        self.pc += 2
   }
    
    private func setValue(vx: Int, value: Byte) {
        print("setValue")
        self.V[vx] = value
        pc += 2
    }
    
    private func setIndex(address: Word) {
        print("setIndex")
        self.I = address
        pc += 2
    }
    
    private func draw(vx: Int, vy: Int, rows: Byte) {
        print("draw")
        
        let height = Int(rows)
        let I = Int(self.I)
        
        var pixel: Byte
        
        self.V[0xF] = 0
        
        for yLine in 0..<height {
            pixel = self.memory[I + yLine]
            
            for xLine in 0..<8 {
                
                if (pixel & (0x80 >> xLine)) != 0 {
                    
                    if self.graphics[vx + xLine + ((vy + yLine) * 64)] == 1 {
                        self.V[0xF] = 1
                    }
                    
                    self.graphics[vx + xLine + ((vy + yLine) * 64)] ^= 1
                }
            }
        }
        
        
        self.drawFlag = true
        pc += 2
    }
    
    private func callSub(address: Word) {
        print("callSub")
        self.stack[self.sp] = self.pc
        self.sp += 1
        self.pc = address
    }
    
    private func storeBinaryCodedDecimal(vx: Int) {
        print("storeBinaryCodedDecimal")
        
        let x = self.V[vx]
        let address = Int(self.I)
        
        self.memory[address] = x / 100
        self.memory[address + 1] = (x / 10) % 10
        self.memory[address + 2] = (x % 100) % 10
        
        self.pc += 2
    }

    private func registerLoad(vx: Int) {
        print("registerLoad")
        let startAddress = Int(self.I)
        
        for i in 0...vx {
            self.V[i] = self.memory[startAddress + i]
        }
        
        self.pc += 2
    }

    private func setSpriteAddress(vx: Int) {
        print("setSpriteAddress")
        self.I = Word(self.V[vx] * 5)
        self.pc += 2
    }
    
    private func addToRegister(vx: Int, value: Byte) {
        print("addToRegister")
        self.V[vx] = self.V[vx] &+ value
        self.pc += 2
    }
    
    private func returnFromSub() {
        print("returnFromSub")
        
        self.sp -= 1
        self.pc = self.stack[self.sp]
        
        self.pc += 2
    }
    
    private func setDelayTimer(vx: Int) {
        print("setDelayTimer")
        
        self.delayTimer = self.V[vx]
        self.pc += 2
    }
    
    private func storeDelayTimer(vx: Int) {
        print("storeDelayTimer")
    
        self.V[vx] = self.delayTimer
        self.pc += 2
    }
    
    private func skipIfEqual(vx: Int, value: Byte) {
        
        print("skipIfEqual")
        
        if self.V[vx] == value {
            self.pc += 2
        }
        
        self.pc += 2
    }
    
    private func jump(address: Word) {
        
        print("jump")
        
        self.pc = address
    }
    
    private func random(vx: Int, value: Byte) {
        print("random")
        
        let result = Byte.random(in: 0...255) & value
        
        self.V[vx] = result
        
        self.pc += 2
    }
    
    // TODO
    private func skipKeyNotPressed(vx: Int) {
        print("skipKeyNotPressed")
        
        let pos = Int(self.V[vx])
        if !self.keypad[pos] {
            self.pc += 2
        }
       
        self.pc += 2
    }
    
    private func and(vx: Int, vy: Int) {
        print("and")
        self.V[vx] &= self.V[vy]
        self.pc += 2
    }
    
    private func assign(vx: Int, vy: Int) {
        print("assign")
        self.V[vx] = self.V[vy]
        self.pc += 2
    }
    
    private func skipIfNotEqual(vx: Int, value: Byte) {
        
        print("skipIfNotEqual")
        
        if self.V[vx] != value {
            self.pc += 2
        }
        
        self.pc += 2
    }
    
    private func addRegisters(vx: Int, vy: Int) {
        
        print("addRegisters")
        
        self.V[vx] = self.V[vx] &+ self.V[vy]
        
        self.V[0xF] = Int(self.V[vx]) + Int(self.V[vy]) > Byte.max ? 1 : 0
        
        self.pc += 2
    }
    
    private func subtractRegisters(vx: Int, vy: Int) {
        
        print("subtractRegisters")
        
        self.V[vx] = self.V[vx] &- self.V[vy]
        
        self.V[0xF] = self.V[vy] > self.V[vx] ? 1 : 0
        
        self.pc += 2
    }
    
    private func setSoundTimer(vx: Int) {
        print("setSoundTimer")
        
        self.soundTimer = self.V[vx]
        self.pc += 2
    }
    
    private func skipRegistersNotEqual(vx: Int, vy: Int) {
        
        print("skipRegistersNotEqual")
        
        if self.V[vx] == self.V[vy] {
            self.pc += 2
        }
        
        self.pc += 2
    }
    
    private func subtractXfromY(vx: Int, vy: Int) {
        print("subtractXfromY")
        
        self.V[0xF] = self.V[vy] < self.V[vx] ? 0 : 1
        self.V[vx] = self.V[vy] &- self.V[vx]
        
        self.pc += 2
    }
    
    private func or(vx: Int, vy: Int) {
        print("or")
        self.V[vx] |= self.V[vy]
        self.pc += 2
    }
    
    private func xor(vx: Int, vy: Int) {
        print("xor")
        self.V[vx] ^= self.V[vy]
        self.pc += 2
    }
    
    private func shiftLeft(vx: Int, vy: Int) {
        print("shiftLeft")
        
        self.V[0xF] = (self.V[vx] & 0x80) >> 7
        self.V[vx] <<= 1
        
        self.pc += 2
    }
    
    private func shiftRight(vx: Int, vy: Int) {
        print("shiftRight")
        
        self.V[0xF] = self.V[vx] & 1
        self.V[vx] >>= 1
        
        self.pc += 2
    }
    
    private func writeMemory(vx: Int) {
        print("writeMemory")
        let address = Int(self.I)
        
        for i in 0...vx {
            self.memory[address + i] = self.V[i]
        }
        
        self.pc += 2
        
    }
    
    private func addIndex(vx: Int) {
        print("addIndex")
        
        // Undocumented feature is the setting of carry flag!
        let value = Word(self.V[vx])
        self.V[0xF] = ((value + self.I) > Word(0xFFF)) ? 1 : 0
        
        self.I += value
        
        self.pc += 2
    }
    
    func waitKeyPress(vx: Int) -> Bool {
        print("waitKeyPress")
        
        // TODO: Handle inputs
        self.lastPressedKey = Key.num1
        
        if let key = self.lastPressedKey {
            self.V[vx] = key.rawValue
            self.lastPressedKey = nil
            
            self.pc += 2
            
            return false
        }
        
        return true
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

