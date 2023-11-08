//
//  token.swift
//
//
//  Created by matty on 11/6/23.
//

import Foundation

enum Token: Equatable {
    case Illegal, Eof //Sentenal
    case LParen, RParen, Colon, Comma, Semicolon //Punctuation
    case Let, If, Else, Fun, For, Return, End, True, False, Nil, Print, In //Keywords
    case Ident(String), Int(Int), Float(Double), String(String) //Values
    case Eq, EqEq, Plus, Minus, Slash, Star, Bang, BangEq, Lt, LtEq, Gt, GtEq //Operators
    case NewLine
}
