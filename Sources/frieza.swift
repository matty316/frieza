// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import ArgumentParser

@main
struct frieza: ParsableCommand {
    @Argument(help: "pass in a frieza file")
    var filename: String
    
    mutating func run() {
        let url = URL(fileURLWithPath: filename)
        
        do {
            let source = try String(contentsOf: url, encoding: .ascii)
            print(source)
        } catch {
            Self.exit(withError: ExitCode(65))
        }
    }
}
