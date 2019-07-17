//
//  SelectedBlockView.swift
//  Game1010
//
//  Created by Erland Isaksson on 2019-07-16.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class SelectedBlockView : SKSpriteNode {
    var cellSize: CGFloat?
    var block : Block?
    var offset : CGPoint?
    
    func setup(block: Block) {
        self.cellSize = size.width/5
        print("Creating block \(block.type) with cellSize=\(cellSize!)")
        setBlock(block)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setBlock(_ block: Block) {
        self.block = block
        removeAllChildren()
        for offset in block.offsets() {
            let view = SKSpriteNode(imageNamed: "block")
            view.size = CGSize(width: cellSize!, height: cellSize!)
            view.anchorPoint = CGPoint(x: 0, y: 1)
            let positionX = CGFloat(offset.x)*cellSize!
            let positionY = -CGFloat(offset.y)*cellSize!
            view.position = CGPoint(x: positionX, y: positionY)
            addChild(view)
        }
        offset = CGPoint(x: CGFloat(5)/CGFloat(block.width) * cellSize!,y:CGFloat(5)/CGFloat(block.height) * cellSize!)
        alpha = 0.5
    }
    
    func clearBlock() {
        self.block = nil
        resetView()
    }
    
    func resetView() {
        alpha = 0.0
    }
}

