//
//  chunkTests.swift
//  
//
//  Created by matty on 11/6/23.
//

import XCTest
@testable import frieza

final class chunkTests: XCTestCase {

    func testConstant() throws {
        var chunk = Chunk()
        
        var constant = chunk.addConstant(val: 10)
        chunk.write(byte: OpCode.Constant.rawValue, line: 123)
        chunk.write(byte: UInt8(constant), line: 123)
        
        constant = chunk.addConstant(val: 5)
        chunk.write(byte: OpCode.Constant.rawValue, line: 123)
        chunk.write(byte: UInt8(constant), line: 123)
        
        constant = chunk.addConstant(val: 5.5)
        chunk.write(byte: OpCode.Constant.rawValue, line: 123)
        chunk.write(byte: UInt8(constant), line: 123)
        
        chunk.write(byte: OpCode.Return.rawValue, line: 123)
                
        var array = chunk.code
        let url = URL(fileURLWithPath: "/Users/matthewreed/projects/frieza/test")
        let data = Data(array)
        try! data.write(to: url)
        
        let newData = try! Data(contentsOf: url)
        print(newData)
    }

}
