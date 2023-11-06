//
//  parserTests.swift
//  
//
//  Created by matty on 11/6/23.
//

import XCTest
@testable import frieza

final class parserTests: XCTestCase {

    func testParsePrefixExpression() {
        let source = """
-x
"""
        let parser = Parser(source: source)
        let expr = try! parser.parseExpression()
        
        guard let expr = expr as? Unary else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(expr.token, .Minus(1))
        guard let right = expr.right as? Name else {
            XCTFail()
            return
        }
        XCTAssertEqual(right.name, "x")
        XCTAssertEqual(right.token, .Ident("x", 1))
    }

}
