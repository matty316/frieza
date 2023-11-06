//
//  parserTests.swift
//  
//
//  Created by matty on 11/6/23.
//

import XCTest
@testable import frieza

final class parserTests: XCTestCase {
    
    func parseExpr(source: String) throws -> Expr? {
        let l = Lexer(source: source)
        let tokens = try l.tokens()
        let p = Parser(tokens: tokens)
        
        return try p.parseExpression()
    }

    func testParsePrefixExpression() throws {
        let source = """
        -x
        """
        
        guard let expr = try parseExpr(source: source) as? Unary else {
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

    func testGrouping() throws {
        let source = """
        (x + y)
        
        """
        guard let expr = try parseExpr(source: source) as? Grouping else {
            XCTFail()
            return
        }
        
        XCTAssert(expr.expr is Binary)
    }
    
    func testUnclosedParen() {
        let source = """
        (x + y
        """
        let l = Lexer(source: source)
        
        do {
            let tokens = try l.tokens()
            let p = Parser(tokens: tokens)
            _ = try p.parseExpression()
            XCTFail()
        } catch let error as ParseError {
            XCTAssertEqual(error.message, "unterminated grouping")
        } catch {
            XCTFail()
        }
    }
    
    func testBinaryPlus() throws {
        let source = """
        x + y
        
        """
        let expr = try parseExpr(source: source)
        guard let expr = expr as? Binary else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(expr.token, .Plus(1))
        
        let left = expr.left as! Name
        let right = expr.right as! Name
        
        XCTAssertEqual(left.name, "x")
        XCTAssertEqual(right.name, "y")
    }
}
