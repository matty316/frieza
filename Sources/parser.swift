//
//  File.swift
//  
//
//  Created by matty on 11/6/23.
//

import Foundation

class Parser {
    private let tokens: [Token]
    private var current: Int
    private var currentToken: Token {
        guard current < tokens.count else { return .Eof }
        return tokens[current]
    }
    private var peek: Token {
        guard current + 1 < tokens.count else { return .Eof }
        return tokens[current + 1]
    }
    
    init(tokens: [Token]) {
        self.tokens = tokens
        self.current = 0
    }
    
    func parseExpression(precedence: Int = 0) throws -> Expr {
        var token = try consume()
        
        var prefixParselet: PrefixParslet? = nil
        switch token {
        case .Ident(_, _): prefixParselet = NameParselet()
        case .Minus(_): prefixParselet = UnaryParselet()
        case .LParen(_): prefixParselet = GroupingParselet()
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
            case .Plus(_), .Minus(_): infixParselet = BinaryParselet(precedence: .Sum)
            case .Slash(_), .Star(_): infixParselet = BinaryParselet(precedence: .Product)
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
        case .Minus(_), .Plus(_): return .Sum
        case .Slash(_), .Star(_): return .Product
        default: return .None
        }
    }
}
