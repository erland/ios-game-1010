//
//  Car.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

protocol BlockObserver {
    func blockUpdated(_ block: Block)
}
class Block : Hashable, NSCopying {
    var observers: [BlockObserver] = []
    let type: Character
    let width: Int
    let height: Int
    
    convenience init(x: Int, y: Int) {
        self.init(type: ".", x: x, y: y)
    }
    
    init(type: Character, x: Int, y: Int) {
        self.x = x
        self.y = y
        self.type = type
        var width = 0
        var height = 0
        for offset in Block.offsets(type: type) {
            if offset.x>=width {
                width = offset.x + 1
            }
            if offset.y>=height {
                height = offset.y + 1
            }
        }
        self.width = width
        self.height = height
        self.selected = false
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Block(type: self.type, x: self.x,y: self.y)
        copy.selected = self.selected
        return copy
    }
    
    func attachObserver(observer: BlockObserver) {
        observers.append(observer)
    }
    
    private func notifyObservers() {
        for observer in observers {
            observer.blockUpdated(self)
        }
    }
    var x: Int {
        didSet {
            notifyObservers()
        }
    }
    var y: Int {
        didSet {
            notifyObservers()
        }
    }
    var selected: Bool {
        didSet {
            notifyObservers()
        }
    }
    func parts() -> [Block] {
        var result: [Block] = []
        for offset in Block.offsets(type: type) {
            let block = Block(x: x+offset.x, y: y+offset.y)
            result.append(block)
        }
        return result
    }
    func offsets() -> [Position] {
        return Block.offsets(type:self.type)
    }

    class func offsets(type: Character) -> [Position] {
        switch type {
        case ".":
            return [Position(0,0)]
        case "-":
            return [Position(0,0),Position(1,0)]
        case "i":
            return [Position(0,0),Position(0,1)]
        case "_":
            return [Position(0,0),Position(1,0),Position(2,0)]
        case "I":
            return [Position(0,0),Position(0,1),Position(0,2)]
        case "r":
            return [Position(0,0),Position(1,0),Position(0,1)]
        case "l":
            return [Position(0,0),Position(0,1),Position(1,1)]
        case "j":
            return [Position(0,1),Position(1,1),Position(1,0)]
        case "t":
            return [Position(0,0),Position(1,0),Position(1,1)]
        case "h":
            return [Position(0,0),Position(1,0),Position(2,0),Position(3,0)]
        case "O":
            return [Position(0,0),Position(1,0),Position(2,0),Position(0,1),Position(1,1),Position(2,1),Position(0,2),Position(1,2),Position(2,2)]
        case "H":
            return [Position(0,0),Position(1,0),Position(2,0),Position(3,0),Position(4,0)]
        case "J":
            return [Position(0,2),Position(1,2),Position(2,2),Position(2,1),Position(2,0)]
        case "T":
            return [Position(0,0),Position(1,0),Position(2,0),Position(2,1),Position(2,2)]
        case "R":
            return [Position(0,0),Position(1,0),Position(2,0),Position(0,1),Position(0,2)]
        case "o":
            return [Position(0,0),Position(1,0),Position(0,1),Position(1,1)]
        case "v":
            return [Position(0,0),Position(0,1),Position(0,2),Position(0,3)]
        case "L":
            return [Position(0,0),Position(0,1),Position(0,2),Position(1,2),Position(2,2)]
        case "V":
            return [Position(0,0),Position(0,1),Position(0,2),Position(0,3),Position(0,4)]
        default:
            return []
        }
    }
    static func == (lhs: Block, rhs: Block) -> Bool {
        return lhs === rhs
    }
    var hashValue: Int {
        return x.hashValue ^ y.hashValue
    }
}

