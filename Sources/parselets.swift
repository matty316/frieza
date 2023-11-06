//
//  File.swift
//  
//
//  Created by matty on 11/6/23.
//

import Foundation

protocol PrefixParslet {
    func parse(parser: Parser, token: Token) throws -> Expr?
}

struct NameParselet: PrefixParslet {
    func parse(parser: Parser, token: Token) throws -> Expr? {
        Name(token: token, name: token.getText())
    }
}

struct UnaryParselet: PrefixParslet {
    func parse(parser: Parser, token: Token) throws -> Expr? {
        Unary(token: token, right: try parser.parseExpression())
    }
}
