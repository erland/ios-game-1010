//
//  GameDelegate.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

protocol GameDelegate {
    func gameCompleted(board: Board, completed: Bool, seconds: Int, score: Int)
    func restartGame()
    func backToMenu(board: Board, seconds: Int, score: Int)
    func selectedNewGame(type: String)
    func selectedResumeGame(type: String)
    //func selectedCompletedLevels()
    //func selectedInProgressLevels()
    //func selectedLevel(board: Board, startTime: Int, moves: Int, offset: Int)
}
