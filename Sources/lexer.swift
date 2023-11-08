//
//  lexer.swift
//
//
//  Created by matty on 11/6/23.
//

import Foundation

struct LexerError: Error {
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
    
    func scan() throws -> [Token] {
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
        case "(": return .LParen
        case ")": return .RParen
        case ";": return .Semicolon
        case ":": return .Colon
        case ",": return .Comma
        case "+": return .Plus
        case "-": return .Minus
        case "/": return .Slash
        case "*": return .Star
        case "=":
            if peek() == "=" {
                advance()
                return .EqEq
            } else {
                return .Eq
            }
        case "!":
            if peek() == "=" {
                advance()
                return .BangEq
            } else {
                return .Bang
            }
        case "<":
            if peek() == "=" {
                advance()
                return .LtEq
            } else {
                return .Lt
            }
        case ">":
            if peek() == "=" {
                advance()
                return .GtEq
            } else {
                return .Gt
            }
        case "\"": return try string()
        case "\n":
            line += 1
            return .NewLine
        default: break
        }
        
        if isAtEnd { return .Eof }
        throw LexerError(message: "Illegal Token at line \(line)")
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
        case "l": return checkKeyword(rest: "et", begin: 1, len: 2, token: .Let)
        case "r": return checkKeyword(rest: "eturn", begin: 1, len: 5, token: .Return)
        case "e": 
            if source[start..<current].count > 1 {
                switch source[source.index(after: start)] {
                case "n": return checkKeyword(rest: "d", begin: 2, len: 1, token: .End)
                case "l": return checkKeyword(rest: "se", begin: 2, len: 2, token: .Else)
                default: break
                }
            }
        case "i":
            if source[start..<current].count == 2 {
                switch source[source.index(after: start)] {
                case "f": return .If
                case "n": return .In
                default: break
                }
            }
        case "t": return checkKeyword(rest: "rue", begin: 1, len: 3, token: .True)
        case "n": return checkKeyword(rest: "il", begin: 1, len: 2, token: .Nil)
        case "p": return checkKeyword(rest: "rint", begin: 1, len: 4, token: .Print)
        case "f":
            if source[start..<current].count > 1 {
                switch source[source.index(after: start)] {
                case "u": return checkKeyword(rest: "n", begin: 2, len: 1, token: .Fun)
                case "o": return checkKeyword(rest: "r", begin: 2, len: 1, token: .For)
                case "a": return checkKeyword(rest: "lse", begin: 2, len: 3, token: .False)
                default: break
                }
            }
        default: break
        }
        return .Ident(String(source[start..<current]))
    }
    
    func checkKeyword(rest: String, begin: Int, len: Int, token: Token) -> Token {
        if source[start..<current].count == begin + len && String(source[source.index(start, offsetBy: begin)..<current]) == rest {
            return token
        }
        return .Ident(String(source[start..<current]))
    }
    
    func num() throws -> Token {
        while isDigit(peek()) { advance() }
        
        if peek() == "." && isDigit(peekNext()) {
            advance()
            while isDigit(peek()) { advance() }
            if isAlpha(peek()) { throw LexerError(message: "invalid number at line \(line)")}
            let string = String(source[start..<current])
            guard let num = Double(string) else {
                throw LexerError(message: "invalid value. expected Double at line \(line)")
            }
            return .Float(num)
        } else {
            if isAlpha(peek()) { throw LexerError(message: "invalid number at line \(line)")}

            let string = String(source[start..<current])
            guard let num = Int(string) else {
                throw LexerError(message: "invalid value. expected Int at line \(line)")
            }
            return .Int(num)
        }
    }
    
    func string() throws -> Token {
        while peek() != "\"" && !isAtEnd {
            advance()
            if peek() == "\n" { line += 1 }
        }
        
        if isAtEnd {
            throw LexerError(message: "Unterminated string")
        }
        advance()
        
        let string = String(source[source.index(after: start)..<source.index(before: current)])
        return .String(string)
    }
}
