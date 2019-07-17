//
//  SelectDifficultyScene.swift
//  Sudoku
//
//  Created by Erland Isaksson on 2019-06-22.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class SelectGameScene: SKScene {
    var gameDelegate: GameDelegate?
    var buttonNew: SKLabelNode?
    var buttonResume: SKLabelNode?

    func setup(delegate: GameDelegate) {
        self.gameDelegate = delegate
        
        self.buttonNew = childNode(withName:"new") as? SKLabelNode
        self.buttonResume = childNode(withName:"resume") as? SKLabelNode
        
        showHideInProgress(type: "1010!", button: self.buttonResume!)
    }
    
    override func didMove(to view: SKView) {
        
    }
    func showHideInProgress(type: String, button: SKLabelNode) {
        if LevelStorage().getInProgress(type: type) != nil {
            button.isHidden = false
        }else {
            button.isHidden = true
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        if buttonNew!.contains(touchLocation) {
            gameDelegate?.selectedNewGame(type: "1010!")
        }else if buttonResume!.contains(touchLocation) {
            gameDelegate?.selectedResumeGame(type: "1010!")
        }
    }
}
