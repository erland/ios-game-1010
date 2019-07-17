//
//  Board.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

protocol BoardObserver : class {
    func blockAdded(_ block: Block)
    func blockRemoved(_ block: Block)
}
class Board {
    let name: String
    let width: Int = 10
    let height: Int = 10
    let board: Array2D<Block>
    var blocks: Set<Block> = Set()
    var observers: [BoardObserver] = []
    let debug = false
    
    init(name: String) {
        self.name = name
        self.board = Array2D<Block>(columns: self.width, rows: self.height)
    }
    
    convenience init(name: String, boardString: String) {
        self.init(name: name)
        initializeFromString(boardString: boardString)
    }
    
    
    func attachObserver(_ observer: BoardObserver) {
        for block in blocks {
            observer.blockAdded(block)
        }
        observers.append(observer)
    }
    
    func detachObserver(_ observer: BoardObserver) {
        if let index = (self.observers.firstIndex(where: { $0 === observer })) {
            self.observers.remove(at: index)
        }
    }
    
    func initializeFromString(boardString: String) {
        for block in blocks {
            removeBlockFromBoard(block)
            for observer in observers {
                observer.blockRemoved(block)
            }
        }
        blocks.removeAll()

        for y in 0..<height {
            for x in 0..<width {
                let i = width*y+x
                if boardString.count > i {
                    let ch = boardString[boardString.index(boardString.startIndex, offsetBy: i)]
                    if ch != " " {
                        if board[x,y] == nil {
                            _ = addBlock(type: ch, x: x, y: y)
                        }
                    }
                }
            }
        }
    }
    subscript(x: Int, y: Int) -> Block? {
        get {
            return board[x,y]
        }
    }

    private func isInsideBoard(x: Int, y: Int, width: Int, height: Int) -> Bool {
        if x<0 || x+width-1 >= self.width || y<0 || y+height-1 >= self.height {
            // Outside board
            if debug {
                print("Outside board")
            }
            return false
        }
        return true
    }
    
    func isPlacementPossible(block: Block, x: Int, y: Int) -> Bool {
        if !isInsideBoard(x: x, y: y, width: block.width, height: block.height) {
            return false
        }
        let offsets = block.offsets()
        for offset in offsets {
            if board[x+offset.x,y+offset.y] != nil && board[x+offset.x,y+offset.y] !== block {
                return false
            }
        }
        return true
    }

    func isPlacementPossible(block: Block) -> Bool {
        for y in 0...(height-block.height) {
            for x in 0...(width-block.width) {
                if board[x,y] == nil {
                    if isPlacementPossible(block: block, x: x, y: y) {
                        return true
                    }
                }
            }
        }
        return false
    }

    private func addBlock(type: Character, x: Int, y: Int) -> Bool {
        let block = Block(type: type, x: x, y: y)
        return addBlock(block: block, x: block.x, y: block.y)
    }
    
    func removeCompleted() -> Int {
        var toBeRemoved : Set<Block> = Set()
        for y in 0..<height {
            var full = true
            for x in 0..<width {
                if board[x,y] == nil {
                    full = false
                    break
                }
            }
            if full {
                for x in 0..<width {
                    toBeRemoved.insert(board[x,y]!)
                }
            }
        }
        for x in 0..<width {
            var full = true
            for y in 0..<height {
                if board[x,y] == nil {
                    full = false
                    break
                }
            }
            if full {
                for y in 0..<height {
                    toBeRemoved.insert(board[x,y]!)
                }
            }
        }
        let score = toBeRemoved.count
        for b in toBeRemoved {
            blocks.remove(b)
            board[b.x,b.y] = nil
            for observer in observers {
                observer.blockRemoved(b)
            }
        }
        return score
    }
    
    func addBlock(block: Block, x: Int, y: Int) -> Bool {
        let block = Block(type: block.type, x: x, y: y)
        if !isInsideBoard(x: x, y: y, width: block.width, height: block.height) {
            return false
        }
        if !isPlacementPossible(block: block, x: x, y: y) {
            // Already occupied
            if debug {
                print("Already occupied")
            }
            return false
        }
        
        for part in block.parts() {
            addBlockToBoard(part)
            blocks.insert(part)
            
            for observer in observers {
                observer.blockAdded(part)
            }
        }
        
        if debug {
            print("Board(\(name)): Added \(block.type) at: \(x),\(y)")
            debugBoard()
        }
        return true
    }
    
    private func addBlockToBoard(_ block: Block) {
        for offset in block.offsets() {
            board[block.x+offset.x,block.y+offset.y] = block
        }
    }
    
    private func removeBlockFromBoard(_ block: Block) {
        for offset in block.offsets() {
            if board[block.x+offset.x,block.y+offset.y] === block {
                board[block.x+offset.x,block.y+offset.y] = nil
            }
        }
    }

    private func moveBlock(block: Block, x: Int, y: Int) {
        
        if !isPlacementPossible(block: block, x: x, y: y) {
            return
        }
        
        removeBlockFromBoard(block)
        block.x = x
        block.y = y
        addBlockToBoard(block)
        
        if debug {
            print("Board(\(name)): Moved \(block.type) to \(x),\(y)")
            debugBoard()
        }
    }

    func asString() -> String {
        var result = ""
        for y in 0..<height {
            for x in 0..<width {
                if board[x,y] != nil {
                    let b = board[x,y]
                    result = result + "\(b!.type)"
                }else {
                    result = result + " "
                }
            }
        }
        return result
    }
    
    func debugBoard(debug: Bool? = nil) {
        if self.debug || (debug != nil && debug!) {
            
            print("Board contents")
            for y in 0..<height {
                for x in 0..<width {
                    if board[x,y] != nil {
                        let b = board[x,y]
                        print("\(b!.type)", terminator: "")
                    }else {
                        print(" ", terminator: "")
                    }
                }
                print()
            }
        }
    }
    
}
