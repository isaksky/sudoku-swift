//
//  LazySequenceExtensions.swift
//  Sudoku-Swift
//
//  Created by Isak on 11/30/14.
//  Copyright (c) 2014 Isak Sky. All rights reserved.
//

import Foundation

extension LazySequence {
    func reduce<U>(seed: U, combine: (S.Generator.Element, U) -> U) -> U {
        var ret :U = seed
        var g = self.generate()
        while let e = g.next() {
            ret = combine(e, ret)
        }
        return ret
    }
}
