//
//  token.swift
//
//
//  Created by matty on 11/6/23.
//

import Foundation

enum Token: Equatable {
    case Illegal(Int), Eof //Sentenal
    case LParen(Int), RParen(Int), Colon(Int), Comma(Int), Semicolon(Int) //Punctuation
    case Let(Int), If(Int), Else(Int), Fun(Int), For(Int), Return(Int), End(Int), True(Int), False(Int), Nil(Int), Print(Int), In(Int) //Keywords
    case Ident(String, Int), Int(Int, Int), Float(Double, Int), String(String, Int) //Values
    case Eq(Int), EqEq(Int), Plus(Int), Minus(Int), Slash(Int), Star(Int), Bang(Int), BangEq(Int), Lt(Int), LtEq(Int), Gt(Int), GtEq(Int) //Operators
    case NewLine(Int)
}
