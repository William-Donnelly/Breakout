//
//  GameOverScene.swift
//  Breakout
//
//  Created by The Real Kaiser on 3/21/18.
//  Copyright © 2018 William Donnelly. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    override init(size: CGSize){
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let elapsedTime = (Int)(GameScene.endTime - GameScene.startTime)
    let numOfBonks = GameScene.bonks
    let restartLabel = SKLabelNode()
    let gameOverLabel = SKLabelNode()
    let bonksLabel = SKLabelNode()
    let timeLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "stars")
        background.position = CGPoint(x: frame.midX,y: frame.midY)
        background.zPosition = 0
        self.addChild(background)
        
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 80
        gameOverLabel.fontColor = SKColor.red
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        restartLabel.text = "Restart"
        restartLabel.fontSize = 80
        restartLabel.fontColor = SKColor.white
        restartLabel.position = CGPoint(x: frame.midX, y: frame.midY - 150)
        restartLabel.zPosition = 1
        self.addChild(restartLabel)
        
        bonksLabel.text = "Bonks: \(numOfBonks)"
        bonksLabel.fontSize = 50
        bonksLabel.fontColor = SKColor.green
        bonksLabel.position = CGPoint(x: frame.midX, y: frame.midY + 25)
        bonksLabel.zPosition = 1
        self.addChild(bonksLabel)
        
        timeLabel.text = "Time: \(elapsedTime) Seconds"
        timeLabel.fontSize = 50
        timeLabel.fontColor = SKColor.green
        timeLabel.position = CGPoint(x: frame.midX, y: frame.midY - 25)
        timeLabel.zPosition = 1
        self.addChild(timeLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            
            if(restartLabel.contains(pointOfTouch)){
                let sceneToMoveTo = GameScene(size: frame.size)
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
        }
    }
}
