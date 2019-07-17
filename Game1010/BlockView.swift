//
//  CarView.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class BlockView : SKSpriteNode, BlockObserver {
    var cellSize: CGFloat
    var block : Block

    init(block: Block, cellSize: CGFloat) {
        self.cellSize = cellSize
        print("Creating block \(block.type) with cellSize=\(cellSize)")
        self.block = block
        let texture = SKTexture(imageNamed: "block")
        super.init(texture: texture, color: UIColor.black, size: CGSize(width: cellSize-1, height: cellSize-1))
        block.attachObserver(observer: self)
        anchorPoint = CGPoint(x: 0, y: 1)
        blockUpdated(block)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func blockUpdated(_ block: Block) {
        let positionX = CGFloat(block.x)*cellSize+(CGFloat(block.width)*cellSize)/2.0
        let positionY = -CGFloat(block.y)*cellSize-(CGFloat(block.height)*cellSize)/2.0
        self.position = CGPoint(x: positionX, y: positionY)
        if block.selected {
            alpha = 0.5
        }else {
            alpha = 1.0
        }
    }
}

