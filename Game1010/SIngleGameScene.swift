//
//  GameScene.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit
import GameplayKit

class SingleGameScene: SKScene, BoardObserver {
    var boardView: BoardView?
    var gameDelegate: GameDelegate?
    var selectedBlockView : SelectedBlockView?
    var selectedBlockViewIndex : Int?
    var selectedOffset : CGPoint?
    var timeText : SKLabelNode?
    var recordLabel : SKLabelNode?
    var recordScore : SKLabelNode?
    var timeCounter : Int = 0
    var record : Int?
    var pauseButton : SKLabelNode?
    var quitButton : SKLabelNode?
    var scoreText : SKLabelNode?
    var score : Int = 0
    var lastTouchX : Int?
    var lastTouchY : Int?
    var blockViews : [SelectedBlockView] = []
    var blockViewPositions : [CGPoint] = []
    var blockViewColor : [UIColor] = []

    func setup(delegate: GameDelegate, board: Board, startTime: Int, score: Int) {
        self.gameDelegate = delegate
        
        for i in 1...3 {
            if let view = childNode(withName: "block\(i)") as? SelectedBlockView {
                let block = createNewBlock()
                view.setup(block: block)
                blockViews.append(view)
                blockViewPositions.append(view.position)
                blockViewColor.append(view.color)
            }
        }

        self.boardView = childNode(withName: "board") as? BoardView
        let boardNameLabel = childNode(withName: "boardName") as? SKLabelNode
        boardNameLabel?.text = board.name
        self.boardView?.setup(board: board)
        self.pauseButton = childNode(withName: "pause") as? SKLabelNode
        self.quitButton = childNode(withName: "quit") as? SKLabelNode
        self.scoreText = childNode(withName: "score") as? SKLabelNode

        self.timeText = childNode(withName: "time") as? SKLabelNode
        self.recordLabel = childNode(withName: "recordLabel") as? SKLabelNode
        self.recordScore = childNode(withName: "recordScore") as? SKLabelNode
        let recordState = LevelStorage().getRecord(type: board.name)
        if recordState != nil {
            record = recordState!.score
            recordScore?.text = "\(record!)"
        }else {
            record = nil
            recordLabel?.isHidden = true
            recordScore?.isHidden = true
        }
        timeCounter = startTime
        displayTime()

        self.score = score
        displayScore()
        
        boardView?.board?.attachObserver(self)
    }
    deinit {
        boardView?.board?.detachObserver(self)
    }
    
    override func didMove(to view: SKView) {
        print("Moved to game scene")
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateTimer() {
        timeCounter = timeCounter + 1
        displayTime()
    }
    
    func timeAsString(_ seconds: Int) -> String {
        let hours = Int(seconds/3600)
        let minutes = String(format: "%02d",Int((seconds%3600)/60))
        let seconds = String(format: "%02d",Int(seconds%60))
        if hours == 0 {
            return  "\(minutes):\(seconds)"
        }else {
            return "\(hours):\(minutes):\(seconds)"
        }
    }
    
    func displayTime() {
        timeText?.text = "\(timeAsString(timeCounter))"
    }

    func displayScore() {
        if record != nil && score>record! {
            scoreText?.fontColor = .green
        }
        scoreText?.text = "Score: \(score)"
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)

        if quitButton!.contains(touchLocation) {
            gameDelegate?.backToMenu(board: boardView!.board!, seconds: timeCounter, score: score)
        }else if pauseButton!.contains(touchLocation) {
            gameDelegate?.gameCompleted(board: boardView!.board!, completed: false, seconds: timeCounter, score: score)
        }else {
            for (i,view) in blockViews.enumerated() {
                if view.contains(touchLocation) {
                    selectedBlockView = view
                    selectedBlockViewIndex = i
                    selectedBlockView?.block?.selected = true
                    selectedBlockView?.scale(to: CGSize(width: boardView!.cellSize!*5, height: boardView!.cellSize!*5))
                    selectedOffset = CGPoint(x: (view.position.x-touchLocation.x)*view.xScale,
                                             y: (view.position.y-touchLocation.y)*view.yScale)
                    selectedBlockView!.position = selectedBlockPosition(touchLocation)
                    selectedBlockView!.color = UIColor.clear

                }
            }
        }
    }
    
    func selectedBlockPosition(_ touchLocation: CGPoint) -> CGPoint {
        var offset : CGFloat = 1.0
        if selectedBlockView!.block!.height>3 {
            offset = 1.0 + CGFloat(selectedBlockView!.block!.height-3)/5
        }
        return CGPoint(x: touchLocation.x - selectedBlockView!.size.width/2 + selectedBlockView!.offset!.x,
                       y: touchLocation.y + offset*selectedBlockView!.size.height - selectedBlockView!.offset!.y)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        if let selectedBlockView = selectedBlockView {
            selectedBlockView.position = selectedBlockPosition(touchLocation)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        if let selectedBlockView = selectedBlockView {
            let blockPosition = selectedBlockPosition(touchLocation)
            let touchX = blockPosition.x + boardView!.cellSize!/2
            let touchY = blockPosition.y - boardView!.cellSize!/2
            print("Release touch at \(touchX),\(touchY)")
            print("Board at \(boardView!.position.x),\(boardView!.position.y)")
            if boardView!.contains(CGPoint(x: touchX,
                                           y: touchY)) {
                let releaseX = Int((touchX - boardView!.position.x)/boardView!.cellSize!)
                let releaseY = Int((boardView!.position.y-touchY)/boardView!.cellSize!)
                print("Releasing at \(releaseX),\(releaseY)")
                if boardView!.board!.isPlacementPossible(block: selectedBlockView.block!, x: releaseX, y: releaseY) {
                    if boardView!.board!.addBlock(block: selectedBlockView.block!, x: releaseX, y: releaseY) {
                        score = score + selectedBlockView.block!.offsets().count
                        score = score + boardView!.board!.removeCompleted()
                        displayScore()
                        selectedBlockView.clearBlock()
                    }
                }
            }
            selectedBlockView.position = blockViewPositions[selectedBlockViewIndex!]
            selectedBlockView.setScale(1.0)
            selectedBlockView.color = blockViewColor[selectedBlockViewIndex!]
            processGameState()
        }
        self.selectedOffset = nil
        self.selectedBlockView = nil
    }
    

    func processGameState() {
        var moreBlocksNeeded = true
        for view in blockViews {
            if view.block != nil {
                moreBlocksNeeded = false
                break
            }
        }
        if moreBlocksNeeded {
            for view in blockViews {
                view.setBlock(createNewBlock())
            }
        }
        var gameEnded = true
        for view in blockViews {
            if let block = view.block {
                if boardView!.board!.isPlacementPossible(block: block) {
                    gameEnded = false
                    break
                }
            }
        }
        if gameEnded {
            gameDelegate?.gameCompleted(board: boardView!.board!, completed: true, seconds: timeCounter, score: score)
        }
    }
    func createNewBlock() -> Block {
        let availableBlockTypes : [Character] = [".",".","-","-","-","i","i","i","_","_","_","I","I","I","r","r","l","l","j","j","t","t","h","h","O","O","H","H","J","T","R","o","o","o","o","o","o","v","v","L","V","V"]
        let i = Int.random(in: 0..<availableBlockTypes.count)
        let block = Block(type: availableBlockTypes[i],x: 0, y: 0)
        return block
    }
    
    func blockAdded(_ block: Block) {
        // Do nothing
    }
    
    func blockRemoved(_ block: Block) {
        // Do nothing
    }
}
