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

// Given a sequence of optional values, return the first element with a value, if any
func firstValue<E, S: SequenceType where S.Generator.Element == Optional<E> >(seq: S) -> E? {
    var g = seq.generate()
    while let e:Optional<E> = g.next() {  // type annotation is neccessarry due to compiler bugs, see http://stackoverflow.com/questions/27178211/how-to-make-a-function-operate-on-a-sequence-of-optional-values
        if e != nil {
            return e
        }
    }
    return nil
}

// Given two sequences and a function, provides a new sequence of the results of calling that function on each pair from the sequences
func product2<E, ProductResultType, S: SequenceType where E == S.Generator.Element>(seq1: S, seq2: S, prod: (E, E) -> ProductResultType) -> SequenceOf<ProductResultType> {
    return SequenceOf<ProductResultType>(
        { () -> GeneratorOf<ProductResultType> in
            var g1 = seq1.generate()
            var g2 = seq2.generate()
            return GeneratorOf<ProductResultType> {
                if let e1 = g1.next() {
                    if let e2 = g2.next() {
                        return prod(e1, e2)
                    }
                }
                return nil
            }
        }
    )
}

// Like normal reduce, except provides an inout Bool in the combiner for short circuiting
func reduce2<E, R, S: SequenceType where E == S.Generator.Element>(seq: S, seed: R, combine:(R, E, inout Bool) -> R) -> R {
    var ret = seed
    var g = seq.generate()
    while let e = g.next() {
        var shortCircuit = false
        ret = combine(ret, e, &shortCircuit)
        if shortCircuit { return ret }
    }
    return ret
}

