//
//  File.swift
//  
//
//  Created by matty on 11/6/23.
//

import Foundation

protocol Expr {
    
}

struct Name: Expr {
    let token: Token
    let name: String
}

struct Unary: Expr {
    let token: Token
    let right: Expr?
}

protocol Stmt {}
