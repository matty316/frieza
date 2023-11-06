//
//  File.swift
//  
//
//  Created by matty on 11/6/23.
//

import Foundation

protocol PrefixParslet {
    func parse(parser: Parser, token: Token) throws -> Expr
}

protocol InfixParselet {
    func parse(parser: Parser, left: Expr, token: Token) throws -> Expr
    var precedence: Parser.Precedence { get }
}

struct NameParselet: PrefixParslet {
    func parse(parser: Parser, token: Token) throws -> Expr {
        Name(token: token, name: token.text)
    }
}

struct UnaryParselet: PrefixParslet {
    func parse(parser: Parser, token: Token) throws -> Expr {
        Unary(token: token, right: try parser.parseExpression())
    }
}

struct GroupingParselet: PrefixParslet {
    func parse(parser: Parser, token: Token) throws -> Expr {
        let expr = try parser.parseExpression()
        let next = try parser.consume()
        switch next {
        case .RParen(_): return Grouping(expr: expr)
        case .Eof: throw ParseError(message: "unterminated grouping")
        default: throw ParseError(message: "expected a ')'")
        }
        
    }
}

struct BinaryParselet: InfixParselet {
    let precedence: Parser.Precedence
    
    func parse(parser: Parser, left: Expr, token: Token) throws -> Expr {
        let right = try parser.parseExpression(precedence: precedence.rawValue)
        return Binary(left: left, right: right, token: token)
    }
}
