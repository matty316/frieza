//
//  parserTests.swift
//  
//
//  Created by matty on 11/6/23.
//

import XCTest
@testable import frieza

final class parserTests: XCTestCase {
    
    //MARK: Expr Tests
    func parseExpr(source: String) throws -> Expr? {
        let l = Lexer(source: source)
        let tokens = try l.scan()
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
        
        XCTAssertEqual(expr.token, .Minus)
        guard let right = expr.right as? Name else {
            XCTFail()
            return
        }
        XCTAssertEqual(right.name, "x")
        XCTAssertEqual(right.token, .Ident("x"))
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
            let tokens = try l.scan()
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
        
        XCTAssertEqual(expr.token, .Plus)
        
        let left = expr.left as! Name
        let right = expr.right as! Name
        
        XCTAssertEqual(left.name, "x")
        XCTAssertEqual(right.name, "y")
    }
    
    func testLiterals() throws {
        let sources = [
            "\"string\"",
            "10",
            "10.5",
        ]
        
        let exp: [Any] = [
            Literal(val: "string"),
            Literal(val: 10),
            Literal(val: 10.5)
        ]
        
        for (i, e) in exp.enumerated() {
            let s = sources[i]
            if let expr = try parseExpr(source: s) as? Literal<String> {
                let e = e as! Literal<String>
                XCTAssertEqual(expr.val, e.val)
            } else if let expr = try parseExpr(source: s) as? Literal<Int> {
                let e = e as! Literal<Int>
                XCTAssertEqual(expr.val, e.val)
            } else if let expr = try parseExpr(source: s) as? Literal<Double> {
                let e = e as! Literal<Double>
                XCTAssertEqual(expr.val, e.val)
            }
        }
    }
    
    func testAssignment() throws {
        let source = """
        x = "string"
        """
        
        let expr = try parseExpr(source: source) as! Assign
        XCTAssertEqual(expr.name, "x")
        let right = expr.right as! Literal<String>
        XCTAssertEqual(right.val, "string")
    }
    
    func testExpressionStmt() throws {
        let source = """
        x + 2
        2 + 3; "string" + "string"
        """
        
        let program = try Parser(tokens: Lexer(source: source).scan()).parse()
        
        XCTAssertEqual(program.count, 3)
    }
    
    func testExpressionStmtError() {
        let source = """
        x + 2
        2 + 3 "string" + "string"
        """
        
        do {
            let program = try Parser(tokens: Lexer(source: source).scan()).parse()
            XCTFail("did not throw an error")
        } catch let error as ParseError {
            XCTAssertEqual(error.message, "expected a ';' at line 2")
        } catch {
            XCTFail("wrong error")
        }
    }
}
