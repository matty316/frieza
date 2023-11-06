//
//  File.swift
//  
//
//  Created by matty on 11/6/23.
//

import Foundation

class Parser {
    let lexer: Lexer
    
    init(source: String) {
        self.lexer = Lexer(source: source)
    }
    
    func parseExpression() throws -> Expr? {
        let token = try lexer.nextToken()
        
        var prefixParselet: PrefixParslet? = nil
        switch token {
        case .Ident(_, _): prefixParselet = NameParselet()
        case .Minus(_): prefixParselet = UnaryParselet()
        default: break
        }
                
        guard let prefixParselet = prefixParselet else {
            throw ParseError(message: "cannot parse expression")
        }
        
        return try prefixParselet.parse(parser: self, token: token)
    }
}
