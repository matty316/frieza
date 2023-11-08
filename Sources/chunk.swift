//
//  chunk.swift
//  
//
//  Created by matty on 11/6/23.
//

import Foundation

struct LineStart {
    let line: Int
    let offset: Int
}

typealias Value = Double

enum OpCode: UInt8 {
    case Constant, Return
}

struct Chunk {
    var code = [UInt8]()
    var lines = [LineStart]()
    var constants = [Value]()
    
    mutating func write(byte: UInt8, line: Int) {
        code.append(byte)
        
        if lines.count > 0 && lines.last?.line == line {
            return
        }
        
        let lineStart = LineStart(line: line, offset: code.count - 1)
        lines.append(lineStart)
    }
    
    mutating func addConstant(val: Value) -> Int {
        self.constants.append(val)
        return self.constants.count - 1
    }
    
    mutating func disassembleChunk() -> String {
        var string = ""
        var i = 0
        while i < code.count {
            if let op = OpCode(rawValue: code[i]) {
                switch op {
                case .Constant:
                    i += 1
                    let constant = code[i]
                    let val = constants[Int(constant)]
                    string.append("Constant: \(val)\n\n")
                case .Return: string.append("Return\n")
                }
            }
            i += 1;
        }
        return string
    }
}
