//
//  BoardView.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class BoardView : SKSpriteNode, BoardObserver {
    
    var board: Board?
    var cellSize: CGFloat?
    var scale: CGFloat?
    
    func setup(board: Board) {
        removeAllChildren()
        self.cellSize = size.width/CGFloat(board.width)
        print("\(size.width) with \(board.width) gives cellSize=\(cellSize!)")
        self.board = board
        self.scale = cellSize!/50.0
        let texture = BoardView.createBoardTexture(x: board.width, y: board.height, cellSize: cellSize!)
        let gridTexture = BoardView.createBoardGridTexture(x: board.width, y: board.height, frameSize: cellSize!/10, cellSize: cellSize!)
        
        
        self.texture = texture
        self.color = UIColor.black
        let gridSprite = SKSpriteNode(texture: gridTexture)
        gridSprite.anchorPoint = CGPoint(x: 0.0,y: 1.0)
        gridSprite.position = CGPoint(x: -cellSize!/10-1, y: cellSize!/10+1)
        gridSprite.zPosition = 1
        addChild(gridSprite)
        
        board.attachObserver(self)
    }
    
    private class func createBoardTexture(x: Int, y: Int, cellSize: CGFloat) -> SKTexture? {
        let boardWidth = CGFloat(x)*cellSize
        let boardHeight = CGFloat(y)*cellSize

        let shape = SKShapeNode.init(rectOf: CGSize(width: boardWidth, height: boardHeight))
        shape.fillColor = UIColor.darkGray
        let view = SKView(frame: CGRect(x: 0, y: 0, width: boardWidth, height: boardHeight))
        return view.texture(from: shape)
    }
    
    private class func createBoardGridTexture(x: Int, y: Int, frameSize: CGFloat, cellSize: CGFloat) -> SKTexture? {
        let boardWidth = CGFloat(x)*cellSize
        let boardHeight = CGFloat(y)*cellSize
        let border = SKShapeNode.init(rectOf: CGSize(width: boardWidth+frameSize,
                                                     height: boardHeight+frameSize))
        border.strokeColor = UIColor.white
        border.lineWidth = frameSize
        for row in 1..<(y) {
            let line = BoardView.createLine(anchor: CGPoint(x: -boardWidth/2, y: -boardHeight/2),
                                            from: CGPoint(x: 0.0, y: CGFloat(row)*cellSize),
                                            to: CGPoint(x: boardWidth, y: CGFloat(row)*cellSize))
            line.strokeColor = .white
            border.addChild(line)
        }
        for column in 1..<(x) {
            let line = BoardView.createLine(anchor: CGPoint(x: -boardWidth/2, y: -boardHeight/2),
                                            from: CGPoint(x: CGFloat(column)*cellSize, y: 0),
                                            to: CGPoint(x: CGFloat(column)*cellSize, y: boardHeight))
            line.strokeColor = .white
            border.addChild(line)
        }
        
        let view = SKView(frame: CGRect(x: 0, y: 0, width: boardWidth+frameSize, height: boardHeight+frameSize))
        return view.texture(from: border)
    }
    
    private class func createLine(anchor: CGPoint, from:CGPoint, to: CGPoint) -> SKShapeNode {
        let lineShape = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: anchor.x+from.x, y: anchor.y+from.y))
        path.addLine(to: CGPoint(x: anchor.x+to.x, y: anchor.y+to.y))
        lineShape.path = path
        return lineShape
    }
    
    func blockAdded(_ block: Block) {
        let view = BlockView(block: block, cellSize: cellSize!)
        view.anchorPoint = CGPoint(x: 1.0/(CGFloat(block.width)*2.0), y: 1.0/(CGFloat(block.height)*2.0))
        view.name = "block"
        view.zPosition = 10
        addChild(view)
    }
    
    func blockRemoved(_ block: Block) {
        if let view = viewForBlock(block) {
            view.removeFromParent()
        }
    }
    
    func viewForBlock(_ block: Block) -> BlockView? {
        var result: BlockView?
        enumerateChildNodes(withName: "block") {
            (node, stop) in
            if node is BlockView {
                let view  = node as! BlockView
                if view.block === block {
                    result = view
                }
            }
        }
        return result
    }
}

