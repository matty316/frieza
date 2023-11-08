//
//  ast.swift
//  
//
//  Created by matty on 11/6/23.
//

import Foundation

//MARK: Expr
protocol Expr {}

struct Name: Expr {
    let token: Token
    let name: String
}

struct Unary: Expr {
    let token: Token
    let right: Expr
}

struct Grouping: Expr {
    let expr: Expr
}

struct Binary: Expr {
    let left: Expr
    let right: Expr
    let token: Token
}

struct Literal<T>: Expr {
    let val: T
}

struct Assign: Expr {
    let right: Expr
    let name: String
}

//MARK: Stmt
protocol Stmt {}

struct ExpressionStmt: Stmt {
    let expr: Expr
}
