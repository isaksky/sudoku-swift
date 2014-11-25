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

if let s = NSString(contentsOfFile: "/Users/Isak/dev/sudoku-haskell/sudoku.txt", encoding: NSUTF8StringEncoding, error: &readError) as? String {
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

func subGridIdxs(idx: Int) -> [Int] {
    let col = idx % 9
    let row = idx / 9
    let scol = (col / 3) * 3
    let srow = (row / 3) * 3
    var ret = [Int]()
    for r in 0...2 {
        for c in 0...2 { // TODO figure out how to map this
            ret.append(scol + c + (srow + r) * 9)
        }
    }
    return ret
}

func subGridValues(puzzle:Puzzle, idx: Int) -> [Int] {
    let idxs = subGridIdxs(idx)
    let vs = map(idxs) { idx in puzzle[idx] }
    return filter(vs) { v in v != 0 }
}

func concat<T>(arys: [T]...) -> [T] {
    var ret = [T]()
    for ary in arys {
        ret += ary
    }
    return ret
}

func possByIdx(puzzle: Puzzle, idx: Int) -> [Int] {
    let v = puzzle[idx]
    if v == 0 {
        let colVs = colValues(puzzle, idx)
        let rowVs = rowValues(puzzle, idx)
        let subGridVs = subGridValues(puzzle, idx)
        let taken = concat(colVs, rowVs, subGridVs)
        return filter(1...9) {v in !contains(taken, v) }
    } else {
        return [v]
    }
}

func fillObvious(puzzle: Puzzle) -> Puzzle {
    var retP = Array(puzzle)
    var changed : Bool
    
    do {
        changed = false
        for idx in 0...80 {
            let v = retP[idx]
            if v == 0 {
                let poss = possByIdx(retP, idx)
                if poss.count == 1 {
                    retP[idx] = poss[0]
                    changed = true
                    break
                }
            }
        }
    } while (changed)
    
    return retP
}

func isSolved(puzzle: Puzzle) -> Bool {
    return !contains(puzzle, 0)
}

//recSolve :: [Int] -> Maybe [Int]
//recSolve puzzle =
//let unfilledIdxs = filter (\ i -> puzzle !! i == 0) [0..80]
//allPoss = map (\ i -> (possByIdx puzzle i, i)) unfilledIdxs
//    -- Find the idx with the smallest number of possibilities
//(poss, idx) = minimumBy (\ (ps1, _) (ps2, _)  -> compare (length ps1) (length ps2)) allPoss
//in case poss of [] -> Nothing   -- There is a square with 0 possibilities. Cannot solve.
//_  -> let p_puzzles = map (\ p -> [if i == idx then p else puzzle !! i | i <- [0..80]]) poss
//p_puzzles_f = map fillObvious p_puzzles
//in (find isSolved p_puzzles_f) `orElse` firstM (map recSolve p_puzzles_f)

//func bestBy<T>(ary: [T], getBest: (T , T) -> T) -> T? {
//    var best : T? = nil
//    for t in ary {
//        if let tmp = best {
//            best = getBest(t, tmp)
//        } else {
//            best = t
//        }
//    }
//    return best
//}

func firstMatch<T>(ary: [T], isMatch: T -> Bool) -> T? {
    for e in ary {
        if isMatch(e) {
            return e
        }
    }
    return nil
}

func hasValue<T>(a: T?) -> Bool {
    if let b = a {
        return true
    }
    return false
}

func firstValue<T>(ary: [T?]) -> T? {
    for e in ary {
        if e != nil {
            return e
        }
    }
    return nil
}

func recSolve(puzzle: Puzzle) -> Puzzle? {
    let unfilledIdxs = filter(0...80) { idx in puzzle[idx] == 0 }
    let allPoss = map(unfilledIdxs) { idx in (poss: possByIdx(puzzle, idx), idx: idx) }
    let best = reduce(allPoss, allPoss[0]) { (best, e) in best.poss.count < e.poss.count ? best : e }
    
    if best.poss.isEmpty {
        return nil
    } else {
        let pPuzzles = map(best.poss) { v -> Puzzle in
            var p = Array(puzzle)
            p[best.idx] = v
            return fillObvious(p)
        }

        return firstMatch(pPuzzles, isSolved) ?? firstValue(map(pPuzzles, recSolve))
    }
}


for (i, p) in enumerate(puzzles) {
    println("Puzzle \(i + 1):")
    if let solvedP = recSolve(p) {
        printPuzzle(solvedP)
    } else {
        println("Could not solve puzzle")
    }

}
//let firstP = puzzles[0]
//let tmp = fillObvious(firstP)
//printPuzzle(tmp)
////printPuzzle(puzzles[0]);
////print(rowValues(puzzles[0], 0))
