//
//  main.swift
//  Sudoku-Swift
//
//  Created by Isak on 11/23/14.
//  Copyright (c) 2014 Isak Sky. All rights reserved.
//

import Foundation

typealias Puzzle =  [Int]
var puzzles : [Puzzle] = []
var tmpPuzzle : Puzzle = []
var readError : NSError?

if let s = NSString(contentsOfFile: "sudoku.txt", encoding: NSUTF8StringEncoding, error: &readError) as? String {
    s.enumerateLines({ (line, stop) -> () in
        if line.hasPrefix("Grid") {
            if tmpPuzzle.count > 0 {
                puzzles.append(tmpPuzzle)
                tmpPuzzle = []
            }
        } else {
            for c in line {
                let c = String(c)
                let digit = c.toInt()
                tmpPuzzle.append(digit!)
            }
        }
    })
} else {
    println("Problem reading file. Error: \(readError)")
    exit(1)
}

println("There are \(puzzles.count) puzzles")

func printPuzzle(puzzle: Puzzle) -> Void {
    for i in 0..<puzzle.count {
        let d = puzzle[i]
        print(d)
        print(" ")
        if i % 9 == 8 {
            print("\n")
        }
    }
}

func rowValues(puzzle: Puzzle, idx: Int) -> [Int] {
    let row = idx / 9
    let idxs = map(0...8) { col in col + (row * 9) }
    let vs = map(idxs) { idx in puzzle[idx] }
    return filter(vs) { v in v != 0 }
}

func colValues(puzzle: Puzzle, idx: Int) -> [Int] {
    let col = idx % 9
    let idxs = map(0...8) { row in col + (row * 9)}
    let vs = map(idxs) { puzzle[$0] }
    let ret = filter(vs) { $0 != 0 }
    return ret
}

func subGridIdxs(idx: Int) -> SequenceOf<Int> {
    let col = idx % 9
    let row = idx / 9
    let scol = (col / 3) * 3
    let srow = (row / 3) * 3
    return product2(0...2, 0...2) { r, c in scol + c + (srow + r) * 9 }
}

func subGridValues(puzzle: Puzzle, idx: Int) -> [Int] {
    let idxs = subGridIdxs(idx)
    let vs = map(idxs) { idx in puzzle[idx] }
    return filter(vs) { v in v != 0 }
}

func possByIdx(puzzle: Puzzle, idx: Int) -> [Int] {
    let v = puzzle[idx]
    if v == 0 {
        let colVs = colValues(puzzle, idx)
        let rowVs = rowValues(puzzle, idx)
        let subGridVs = subGridValues(puzzle, idx)
        let taken = colVs + rowVs + subGridVs
        return filter(1...9) {v in !contains(taken, v) }
    } else {
        return [v]
    }
}

func isSolved(puzzle: Puzzle) -> Bool {
    return !contains(puzzle, 0)
}

func solve(puzzle: Puzzle) -> Puzzle? {
    let unfilledIdxs = lazy(0...80).filter { idx in puzzle[idx] == 0 }
    let allPoss = unfilledIdxs.map { idx in (possible: possByIdx(puzzle, idx), idx: idx) }

    let best = reduce2(allPoss, (possible: [1,2,3,4,5,6,7,8,9], idx: -1)) { memo, e, done in
        if e.possible.count <= 1 {
            done = true
            return e
        } else {
            return e.possible.count < memo.possible.count ? e : memo
        }
    }
    
    if best.possible.isEmpty {
        return nil
    } else {
        let pPuzzles = lazy(best.possible).map { v -> Puzzle in
            var p = Array(puzzle)
            p[best.idx] = v
            return p
        }
        return firstMatch(pPuzzles, isSolved) ?? firstValue(lazy(pPuzzles).map(solve))
    }
}

for (i, p) in enumerate(puzzles) {
    println("Puzzle \(i + 1):")
    if let solvedP = solve(p) {
        printPuzzle(solvedP)
    } else {
        println("Could not solve puzzle")
    }
}

