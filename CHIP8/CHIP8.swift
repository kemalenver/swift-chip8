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
    var memory: [Byte] = Array(repeating: 0, count: 4096)

    // 16 registers v0...vE.  last register is a carry flag
    var v: [Byte] = Array(repeating: 0, count: 16)

    // index register
    var I: Word = 0

    // Program Counter, programs start at address 200
    var pc: Word = 0x200

    var graphics: [Byte] = Array(repeating: 0, count: 64 * 32)

    var delayTimer: Byte = 0
    var soundTimer: Byte = 0

    var stack: [Word] = Array(repeating: 0, count: 16)
    var sp: Word = 0

    init(program: [Byte]) {
        self.loadInterpreter()
        self.loadFont()
        self.load(program: program)

        self.printMemory()
    }

    private func loadInterpreter() {
        // Interpreter is stored from x0 to x50
        let interpreter: [Byte] = Array(repeating: 0xAA, count: 0x1FF)
        self.memory.replaceSubrange(0x00..<0x1FF, with: interpreter)
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
        print("stepping")
    }

    func printMemory() {

        let rowSize = 16
        let numberOfRows = self.memory.count / rowSize

        for i in 0..<rowSize {
            print("0x\(String(format:"%02X", i))", terminator: " | ")
        }
        print()
        for _ in 0..<rowSize {
            print("----", terminator: " | ")
        }
        print()

        for i in 0..<numberOfRows {

            for j in i*rowSize..<(i*rowSize + 16) {
                print("0x\(String(format:"%02X", self.memory[j]))", terminator: " | ")
            }
            print()
        }
    }
}

