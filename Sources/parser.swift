//
//  parser.swift
//  
//
//  Created by matty on 11/6/23.
//

import Foundation

struct ParseError: Error {
    let message: String
}

typealias Program = [Stmt]

class Parser {
    private let tokens: [Token]
    private var current: Int
    private var line: Int
    private var currentToken: Token {
        guard current < tokens.count else { return .Eof }
        return tokens[current]
    }
    private var isAtEnd: Bool {
        current >= tokens.count
    }
    
    init(tokens: [Token]) {
        self.tokens = tokens
        self.current = 0
        self.line = 1
    }
    
    func parse() throws -> Program {
        var program = Program()
        while !isAtEnd {
            program.append(try parseExpessionStmt())
        }
        return program
    }
    
    func parseExpessionStmt() throws -> Stmt {
        let expr = try parseExpression()
        switch currentToken {
        case .NewLine: 
            line += 1
            try consume()
        case .Semicolon, .Eof: 
            try consume()
        default: 
            throw ParseError(message: "expected a ';' at line \(line)")
        }
        
        return ExpressionStmt(expr: expr)
    }
    
    func parseExpression(precedence: Int = 0) throws -> Expr {
        var token = try consume()
        
        var prefixParselet: PrefixParslet? = nil
        switch token {
        case .Ident(_): prefixParselet = NameParselet()
        case .Minus: prefixParselet = UnaryParselet()
        case .LParen: prefixParselet = GroupingParselet()
        case .String(_), .Int(_), .Float(_): prefixParselet = LiteralParselet()
        default: break
        }
                
        guard let prefixParselet = prefixParselet else {
            throw ParseError(message: "cannot parse expression")
        }
        
        var left = try prefixParselet.parse(parser: self, token: token)
        
        while precedence < getPrecedence(token: currentToken).rawValue {
            token = try consume()
            var infixParselet: InfixParselet? = nil
            
            switch token {
            case .Plus, .Minus: infixParselet = BinaryParselet(precedence: .Sum)
            case .Slash, .Star: infixParselet = BinaryParselet(precedence: .Product)
            case .Eq: infixParselet = AssignParselet(precedence: .Assignment)
            default: break
            }
            if let infixParselet = infixParselet {
                left = try infixParselet.parse(parser: self, left: left, token: token)
            }
        }
        
        return left
    }
    
    @discardableResult
    func consume() throws -> Token {
         advance()
    }
}

//MARK: Helpers
private extension Parser {
    func advance() -> Token {
        if currentToken == .Eof {
            return Token.Eof
        }
        
        let token = currentToken
        current += 1;
        return token
    }
}

//MARK: Precedence
extension Parser {
    enum Precedence: Int {
        case None, Assignment, Conditional, Sum, Product, Exponent, Prefix, Postfix, Call
    }
    
    func getPrecedence(token: Token) -> Precedence {
        switch token {
        case .Minus, .Plus: return .Sum
        case .Slash, .Star: return .Product
        case .Eq: return .Assignment
        default: return .None
        }
    }
}
