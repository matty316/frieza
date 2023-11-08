//
//  lexerTests.swift
//  
//
//  Created by matty on 11/6/23.
//

import XCTest
@testable import frieza

final class lexerTests: XCTestCase {
    func testLexer() {
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
        10.
        """
        
        let exp: [Token] = [
            .Let,
            .Ident("num1"),
            .Eq,
            .Int(5),
            .NewLine,
            .Let,
            .Ident("num2"),
            .Eq,
            .Float(10.5),
            .NewLine,
            .NewLine,
            .Let,
            .Ident("string"),
            .Eq,
            .String("name"),
            .Semicolon,
            .Let,
            .Ident("anotherString"),
            .Eq,
            .String("another name"),
            .NewLine,
            .NewLine,
            .Fun,
            .Ident("add"),
            .LParen,
            .Ident("x"),
            .Comma,
            .Ident("y"),
            .RParen,
            .NewLine,
            .Return,
            .Ident("x"),
            .Plus,
            .Ident("y"),
            .NewLine,
            .End,
            .NewLine,
            .NewLine,
            .Bang,
            .Minus,
            .Slash,
            .Star,
            .Lt,
            .Gt,
            .LtEq,
            .GtEq,
            .EqEq,
            .BangEq,
            .NewLine,
            .NewLine,
            .If,
            .True,
            .NewLine,
            .Return,
            .Nil,
            .NewLine,
            .Else,
            .NewLine,
            .Print,
            .String("free\n    numba 9"),
            .NewLine,
            .End,
            .NewLine,
            .NewLine,
            .If,
            .Ident("x"),
            .EqEq,
            .Int(1),
            .Colon,
            .Return,
            .String("1"),
            .NewLine,
            .NewLine,
            .NewLine,
            .NewLine,
            .For,
            .Ident("i"),
            .In,
            .Ident("array"),
            .NewLine,
            .Print,
            .Ident("iffy"),
            .NewLine,
            .Print,
            .Ident("inny"),
            .NewLine,
            .End,
            .NewLine,
            .Int(10),
            .Eof
        ]
        
        let l = Lexer(source: source)
        for e in exp {
            let t = try! l.nextToken()
            XCTAssertEqual(e, t)
        }
    }

    func testErrors() {
        let sources = [
            "let 👿 = \"devil\"",
            "let string = \"string",
            "123num",
            "123.0float",
            "123.float"
        ]
        
        for source in sources {
            let l = Lexer(source: source)
            do {
                _ = try l.scan()
                XCTFail("did not throw an error")
            } catch let error as LexerError {
                XCTAssertFalse(error.message.isEmpty)
                print(error.message)
            } catch {
                XCTFail("wrong error")
            }
        }
    }
}
