//
//  SequenceUtilities.swift
//  Sudoku-Swift
//
//  Created by Isak on 11/30/14.
//  Copyright (c) 2014 Isak Sky. All rights reserved.
//

import Foundation

func firstMatch<S where S: SequenceType>(seq: S, isMatch: S.Generator.Element -> Bool) -> S.Generator.Element? {
    for e in seq {
        if isMatch(e) {
            return e
        }
    }
    return nil
}

func firstValue<E, S: SequenceType where S.Generator.Element == Optional<E> >(seq: S) -> E? {
    var g = seq.generate()
    while let e:Optional<E> = g.next() {
        if e != nil {
            return e
        }
    }
    return nil
}

