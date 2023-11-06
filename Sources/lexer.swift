//
//  lexer.swift
//
//
//  Created by matty on 11/6/23.
//

import Foundation

struct ParseError: Error {
    let message: String
}

class Lexer {
    private var current: String.Index
    private var start: String.Index
    private var source: String
    private var line: Int
    private var isAtEnd: Bool {
        current == source.endIndex
    }
    
    init(source: String) {
        self.current = source.startIndex
        self.start = source.startIndex
        self.source = source
        self.line = 1
    }
    
    func tokens() throws -> [Token] {
        var tokens = [Token]()
        while !isAtEnd {
            tokens.append(try nextToken())
        }
        return tokens
    }
    
    func nextToken() throws -> Token {
        skipWhitespace()
        start = current
        let c = advance()
        
        if isAlpha(c) { return ident() }
        if isDigit(c) { return try num() }
                
        switch c {
        case "(": return .LParen(line)
        case ")": return .RParen(line)
        case ";": return .Semicolon(line)
        case ":": return .Colon(line)
        case ",": return .Comma(line)
        case "+": return .Plus(line)
        case "-": return .Minus(line)
        case "/": return .Slash(line)
        case "*": return .Star(line)
        case "=":
            if peek() == "=" {
                advance()
                return .EqEq(line)
            } else {
                return .Eq(line)
            }
        case "!":
            if peek() == "=" {
                advance()
                return .BangEq(line)
            } else {
                return .Bang(line)
            }
        case "<":
            if peek() == "=" {
                advance()
                return .LtEq(line)
            } else {
                return .Lt(line)
            }
        case ">":
            if peek() == "=" {
                advance()
                return .GtEq(line)
            } else {
                return .Gt(line)
            }
        case "\"": return string()
        case "\n":
            line += 1
            return .NewLine(line)
        default: break
        }
        
        if isAtEnd { return .Eof }
        return .Illegal(line)
    }
}

//MARK: Helpers
private extension Lexer {
    
    func skipWhitespace() {
        while true {
            let c = peek()

            switch c {
            case " ", "\t", "\r":
                advance()
            case "/":
                if peekNext() == "/" {
                    while peek() != "\n" && !isAtEnd { advance() }
                } else {
                    return
                }
            default: return
            }
        }
    }
    
    @discardableResult
    func advance() -> Character {
        if isAtEnd { return "\0" }
        current = source.index(after: current)
        return source[source.index(before: current)]
    }
    
    func isAlpha(_ c: Character) -> Bool {
        c >= "a" && c <= "z" || c >= "A" && c <= "Z" || c == "_"
    }
    
    func isDigit(_ c: Character) -> Bool {
        c >= "0" && c <= "9"
    }
    
    func peek() -> Character {
        if isAtEnd { return "\0" }
        return source[current]
    }
    
    func peekNext() -> Character {
        if source.index(after: current) == source.endIndex { return "\0" }
        return source[source.index(after: current)]
    }
    
    func ident() -> Token {
        while isAlpha(peek()) || isDigit(peek()) { advance() }
        
        return lookupKeyword()
    }
    
    func lookupKeyword() -> Token {
        let c = source[start]
        switch c {
        case "l": return checkKeyword(rest: "et", begin: 1, len: 2, token: .Let(line))
        case "r": return checkKeyword(rest: "eturn", begin: 1, len: 5, token: .Return(line))
        case "e": 
            if source[start..<current].count > 1 {
                switch source[source.index(after: start)] {
                case "n": return checkKeyword(rest: "d", begin: 2, len: 1, token: .End(line))
                case "l": return checkKeyword(rest: "se", begin: 2, len: 2, token: .Else(line))
                default: break
                }
            }
        case "i":
            if source[start..<current].count == 2 {
                switch source[source.index(after: start)] {
                case "f": return .If(line)
                case "n": return .In(line)
                default: break
                }
            }
        case "t": return checkKeyword(rest: "rue", begin: 1, len: 3, token: .True(line))
        case "n": return checkKeyword(rest: "il", begin: 1, len: 2, token: .Nil(line))
        case "p": return checkKeyword(rest: "rint", begin: 1, len: 4, token: .Print(line))
        case "f":
            if source[start..<current].count > 1 {
                switch source[source.index(after: start)] {
                case "u": return checkKeyword(rest: "n", begin: 2, len: 1, token: .Fun(line))
                case "o": return checkKeyword(rest: "r", begin: 2, len: 1, token: .For(line))
                case "a": return checkKeyword(rest: "lse", begin: 2, len: 3, token: .False(line))
                default: break
                }
            }
        default: break
        }
        return .Ident(String(source[start..<current]), line)
    }
    
    func checkKeyword(rest: String, begin: Int, len: Int, token: Token) -> Token {
        if source[start..<current].count == begin + len && String(source[source.index(start, offsetBy: begin)..<current]) == rest {
            return token
        }
        return .Ident(String(source[start..<current]), line)
    }
    
    func num() throws -> Token {
        while isDigit(peek()) { advance() }
        
        if peek() == "." && isDigit(peekNext()) {
            advance()
            while isDigit(peek()) { advance() }
            let string = String(source[start..<current])
            guard let num = Double(string) else {
                throw ParseError(message: "cannot parse float")
            }
            return .Float(num, line)
        } else {
            let string = String(source[start..<current])
            guard let num = Int(string) else {
                throw ParseError(message: "cannot parse int")
            }
            return .Int(num, line)
        }
    }
    
    func string() -> Token {
        while peek() != "\"" && !isAtEnd {
            advance()
            if peek() == "\n" { line += 1 }
        }
        
        advance()
        
        let string = String(source[source.index(after: start)..<source.index(before: current)])
        return .String(string, line)
    }
}
