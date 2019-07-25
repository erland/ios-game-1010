//
//  GameViewController.swift
//  Game1010
//
//  Created by Erland Isaksson on 2019-07-16.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, GameDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "SelectGameScene") as? SelectGameScene {
                scene.setup(delegate: self)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func selectedNewGame(type: String) {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "SingleGameScene") as? SingleGameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                let board = Board(name: type)
                scene.setup(delegate: self, board: board, startTime: 0, score: 0)
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
    }
    func selectedResumeGame(type: String) {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "SingleGameScene") as? SingleGameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                if let state = LevelStorage().getInProgress(type: type) {
                    let board = Board(name: type, boardString: state.current)
                    scene.setup(delegate: self, board: board, startTime: state.seconds, score: state.score)
                    // Present the scene
                    view.presentScene(scene)
                }
            }
            
            view.ignoresSiblingOrder = true
        }
    }

    func gameCompleted(board: Board, completed: Bool, seconds: Int, score: Int) {
        let boardString = board.asString()
        if completed {
            LevelStorage().registerRecord(type: board.name, current: boardString, score: score, seconds: seconds)
            LevelStorage().removeBoardInProgress(type: board.name)
            if let view = self.view as! SKView? {
                // Load the SKScene from 'GameScene.sks'
                if let scene = SKScene(fileNamed: "SingleGameOverScene") as? SingleGameOverScene {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFit
                    
                    scene.setup(delegate: self, board: board, seconds: seconds, score: score)
                    
                    // Present the scene
                    view.presentScene(scene)
                }
                
                view.ignoresSiblingOrder = true
            }
        }else {
            LevelStorage().registerRecord(type: board.name, current: boardString, score: score, seconds: seconds)
            LevelStorage().storeBoardInProgress(board: board, score: score, seconds: seconds)
            viewDidLoad()
        }
    }
    
    func restartGame() {
        viewDidLoad()
    }
    
    func backToMenu(board: Board, seconds: Int, score: Int) {
        LevelStorage().removeBoardInProgress(type: board.name)
        viewDidLoad()
    }
    

}
