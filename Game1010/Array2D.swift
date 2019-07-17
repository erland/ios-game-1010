//
//  Array2D.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-04-29.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//
import Foundation

class Array2D<T : NSCopying> : NSCopying {
    let columns: Int
    let rows: Int
    
    var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        
        array = Array<T?>(repeating: nil, count:rows * columns)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Array2D<T>(columns: columns, rows: rows)
        for y in 0..<rows {
            for x in 0..<columns {
                if let node = self[x,y] {
                    copy[x,y] = (node.copy() as! T)
                }
            }
        }
        return copy
    }
    
    subscript(column: Int, row: Int) -> T? {
        get {
            if column>=0 && column<columns && row>=0 && row<rows {
                return array[(row * columns) + column]
            }else {
                return nil
            }
        }
        set(newValue) {
            if column>=0 && column<columns && row>=0 && row<rows {
                array[(row * columns) + column] = newValue
            }
        }
    }
}
