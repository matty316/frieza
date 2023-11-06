//
//  lexerTests.swift
//  
//
//  Created by matty on 11/6/23.
//

import XCTest
@testable import frieza

final class lexerTests: XCTestCase {
    func test_lexer() {
        let source = """
        let num1 = 5
        let num2 = 10.5

        let string = "name"; let anotherString = "another name"

        fun add(x, y)
            return x + y
        end

        !-/*<> <= >= == !=

        if true
            return nil
        else
            print "free
            numba 9"
        end

        if x == 1: return "1"
        
        // test a comment
        
        for i in array
            print iffy
            print inny
        end
        """
        
        let exp: [Token] = [
            .Let(1),
            .Ident("num1", 1),
            .Eq(1),
            .Int(5, 1),
            .NewLine(2),
            .Let(2),
            .Ident("num2", 2),
            .Eq(2),
            .Float(10.5, 2),
            .NewLine(3),
            .NewLine(4),
            .Let(4),
            .Ident("string", 4),
            .Eq(4),
            .String("name", 4),
            .Semicolon(4),
            .Let(4),
            .Ident("anotherString", 4),
            .Eq(4),
            .String("another name", 4),
            .NewLine(5),
            .NewLine(6),
            .Fun(6),
            .Ident("add", 6),
            .LParen(6),
            .Ident("x", 6),
            .Comma(6),
            .Ident("y", 6),
            .RParen(6),
            .NewLine(7),
            .Return(7),
            .Ident("x", 7),
            .Plus(7),
            .Ident("y", 7),
            .NewLine(8),
            .End(8),
            .NewLine(9),
            .NewLine(10),
            .Bang(10),
            .Minus(10),
            .Slash(10),
            .Star(10),
            .Lt(10),
            .Gt(10),
            .LtEq(10),
            .GtEq(10),
            .EqEq(10),
            .BangEq(10),
            .NewLine(11),
            .NewLine(12),
            .If(12),
            .True(12),
            .NewLine(13),
            .Return(13),
            .Nil(13),
            .NewLine(14),
            .Else(14),
            .NewLine(15),
            .Print(15),
            .String("free\n    numba 9", 16),
            .NewLine(17),
            .End(17),
            .NewLine(18),
            .NewLine(19),
            .If(19),
            .Ident("x", 19),
            .EqEq(19),
            .Int(1, 19),
            .Colon(19),
            .Return(19),
            .String("1", 19),
            .NewLine(20),
            .NewLine(21),
            .NewLine(22),
            .NewLine(23),
            .For(23),
            .Ident("i", 23),
            .In(23),
            .Ident("array", 23),
            .NewLine(24),
            .Print(24),
            .Ident("iffy", 24),
            .NewLine(25),
            .Print(25),
            .Ident("inny", 25),
            .NewLine(26),
            .End(26),
            .Eof
        ]
        
        let l = Lexer(source: source)
        for e in exp {
            let t = try! l.nextToken()
            XCTAssertEqual(e, t)
        }
    }

    func testIllegal() {
        let source = """
        let 👿 = "devil"
        """
        let l = Lexer(source: source)
        _ = try! l.nextToken()
        let t = try! l.nextToken()
        XCTAssertEqual(t, .Illegal(1))
    }
}
