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

//MARK: Prefix
struct NameParselet: PrefixParslet {
    func parse(parser: Parser, token: Token) throws -> Expr {
        switch token {
        case .Ident(let s, _): return Name(token: token, name: s)
        default: throw ParseError(message: "expected a name")
        }
        
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

struct LiteralParselet: PrefixParslet {
    func parse(parser: Parser, token: Token) throws -> Expr {
        switch token {
        case .String(let s, _): return Literal(val: s)
        case .Int(let i, _): return Literal(val: i)
        case .Float(let f, _): return Literal(val: f)
        default: throw ParseError(message: "cannot parse literal")
        }
    }
}

//MARK: Infix
struct BinaryParselet: InfixParselet {
    let precedence: Parser.Precedence
    
    func parse(parser: Parser, left: Expr, token: Token) throws -> Expr {
        let right = try parser.parseExpression(precedence: precedence.rawValue)
        return Binary(left: left, right: right, token: token)
    }
}

struct AssignParselet: InfixParselet {
    let precedence: Parser.Precedence
    
    func parse(parser: Parser, left: Expr, token: Token) throws -> Expr {
        guard let left = left as? Name else { throw ParseError(message: "left operand must be name") }
        
        let right = try parser.parseExpression(precedence: Parser.Precedence.Assignment.rawValue  - 1)
        return Assign(right: right, name: left.name)
    }
}

