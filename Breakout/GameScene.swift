//
//  GameScene.swift
//  Breakout
//
//  Created by The Real Kaiser on 3/20/18.
//  Copyright © 2018 William Donnelly. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    static var bonks = 0
    static var startTime = 0.0
    static var endTime = 0.0
    var bonksPerFive = 0
    var bonksPerFiveStart = 0.0
    var bonksPerFiveEnd = 0.0
    var gameAudioPlayer = AVAudioPlayer()
    var ball = SKShapeNode()
    var userBlock = SKSpriteNode()
    var deadZone = SKShapeNode()
    var boxToBreak = SKShapeNode()
    
    struct PhysicsCategories{
        static let None : UInt32 = 0
        static let Ball : UInt32 = 0x1  //1
        static let Blocker : UInt32 = 0x10 //2
        static let Death : UInt32 = 0x100 //4
        static let blockToBreak : UInt32 = 0x1000 //8
    }
    
    override func didMove(to view: SKView) {
        GameScene.bonks = 0
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        
        createBackground()
        makePaddle()
        moveBall()
        makeRectangles()
        makeDeadZone()
        
        startMusic()
        
        let moveBumper = SKAction.moveTo(y: frame.midY - 250, duration: 1)
        userBlock.run(moveBumper)
        
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: 3, dy: 3))
        
        GameScene.startTime = CACurrentMediaTime()
        bonksPerFiveStart = CACurrentMediaTime()
    }
    
    func startMusic(){
        do{
            try gameAudioPlayer = AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Breakout Theme V1", ofType: "mp3")!))
            gameAudioPlayer.prepareToPlay()
            
            let audioSession = AVAudioSession.sharedInstance()
            
            do{
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            }
            catch{
                
            }
        }
        catch{
            print(error)
        }
        gameAudioPlayer.numberOfLoops = 10000
        gameAudioPlayer.play()
    }
    
    func createBackground(){
        let stars = SKTexture.init(imageNamed: "stars")
        
        for i in 0...2{
            
            let background = SKSpriteNode(texture: stars)
            background.position = CGPoint(x: frame.midX, y: 300 + (-background.size.height * CGFloat(i)))
            background.zPosition = -1
            addChild(background)
            
            let moveUp = SKAction.moveBy(x: 0, y: background.size.height, duration: 5)
            let moveReset = SKAction.moveBy(x: 0, y: -background.size.height, duration: 0)
            
            let moveSequence = SKAction.sequence([moveUp, moveReset])
            let moveLoop = SKAction.repeatForever(moveSequence)
            background.run(moveLoop)
        }
    }
    
    func makeRectangles(){
        let w = (CGFloat)(35.0)
        let h = (CGFloat)(30.0)
        var xPos = (CGFloat)(0.0)
        var yLevel = (CGFloat)(1.0)
        
        for i in 0...39{
            
            if(i % 8 == 0){
                yLevel += 1
                
            }
            let place = (CGFloat)(40 * (i % 8))
            xPos = frame.minX + 65 + (place)
            
            boxToBreak = SKShapeNode(rectOf: CGSize(width: w, height: h))
            
            boxToBreak.position = CGPoint(x: xPos, y: frame.maxY - (33*yLevel))
            boxToBreak.fillColor = UIColor.blue
            boxToBreak.strokeColor = UIColor.black
            boxToBreak.zPosition = 1
            
            boxToBreak.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: w, height: h))
            boxToBreak.physicsBody?.isDynamic = false
            boxToBreak.physicsBody?.affectedByGravity = false
            
            boxToBreak.physicsBody?.categoryBitMask = PhysicsCategories.blockToBreak
            boxToBreak.physicsBody?.collisionBitMask = PhysicsCategories.None
            boxToBreak.physicsBody?.contactTestBitMask = PhysicsCategories.Ball
            
            addChild(boxToBreak)
        }
    }
    
    func moveBall(){
        ball = SKShapeNode(circleOfRadius: 10)
        ball.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        ball.strokeColor = UIColor.blue
        ball.fillColor = UIColor.green
        ball.name = "ball"
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        ball.physicsBody?.isDynamic = false
        //ball.physicsBody?.usesPreciseCollisionDetection = true
        ball.physicsBody?.friction = 0
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        
        ball.physicsBody?.contactTestBitMask = (ball.physicsBody?.collisionBitMask)!
        ball.physicsBody?.categoryBitMask = PhysicsCategories.Ball
    
        addChild(ball)
    }
    
    func makePaddle(){
        userBlock = SKSpriteNode(imageNamed: "Bumper")
        userBlock.position = CGPoint(x: frame.midX, y: frame.midY - 500)
        
        userBlock.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 150, height: 40))
        userBlock.physicsBody?.affectedByGravity = false
        userBlock.physicsBody?.isDynamic = false
        userBlock.zPosition = 1

        addChild(userBlock)
    }
    
    func makeDeadZone(){
        deadZone = SKShapeNode(rectOf: CGSize(width: frame.maxX*2, height: 50))
        
        deadZone.strokeColor = UIColor(white: 1, alpha: 0)
        deadZone.position = CGPoint(x: frame.midX, y: frame.minY)
        deadZone.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.maxX*2, height: 50))
        deadZone.physicsBody?.affectedByGravity = false
        deadZone.physicsBody?.isDynamic = false
        
        deadZone.physicsBody?.categoryBitMask = PhysicsCategories.Death
        deadZone.physicsBody?.collisionBitMask = PhysicsCategories.None
        deadZone.physicsBody?.contactTestBitMask = PhysicsCategories.Ball
        
        addChild(deadZone)
    }
    
    func randomBlocks(){
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if(firstBody.categoryBitMask == PhysicsCategories.Ball && secondBody.categoryBitMask == PhysicsCategories.Death){
            runEndGameLose()
        }
        else if(firstBody.categoryBitMask == PhysicsCategories.Ball && secondBody.categoryBitMask == PhysicsCategories.blockToBreak){
            bonksPerFive += 1
            
            secondBody.node?.removeFromParent()
            
            let fadeAction = SKAction.fadeOut(withDuration: 0.5)
            secondBody.node?.run(fadeAction)
            
        }
        else{
            bonksPerFive += 1
            
            if(bonksPerFive >= 3){
                bonksPerFiveEnd = CACurrentMediaTime()
                let time = bonksPerFiveEnd - bonksPerFiveStart
                if(time > 2.7){
                    let toMoveX = (Int)(arc4random_uniform(3) + 1)
                    let toMoveY = (Int)(arc4random_uniform(3) + 1)
                    //-print(toMoveX)
                    //print(toMoveY)
                    ball.physicsBody?.applyImpulse(CGVector(dx: toMoveX, dy: toMoveY))
                }
                bonksPerFiveStart = CACurrentMediaTime()
                bonksPerFive = 0
            }
            GameScene.bonks += 1
            let file = arc4random_uniform(3)
            var fileToPlay = ""
            if(file == 1){
                fileToPlay = "C1 Low"
            }
            else if(file == 2){
                fileToPlay = "C2 Mid"
            }
            else{
                fileToPlay = "C3 High"
            }
            let ballSound = SKAction.playSoundFileNamed(fileToPlay, waitForCompletion: false)
            self.run(ballSound)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            userBlock.position.x += amountDragged
        }
        
        if(userBlock.position.x > frame.maxX - userBlock.frame.width/2) {
            userBlock.position.x = frame.maxX - userBlock.frame.width/2
        }
        if(userBlock.position.x < frame.minX + userBlock.frame.width/2){
            userBlock.position.x = frame.minX + userBlock.frame.width/2
        }
    }
    
    
    
    func runEndGameLose(){
        GameScene.endTime = CACurrentMediaTime()
        
        self.removeAllActions()
        
        let deathSound = SKAction.playSoundFileNamed("RobloxDeath", waitForCompletion: true)
        self.run(deathSound)
        
        ball.physicsBody?.isDynamic = false
        
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 0)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
    }
    
    func changeScene(){

        let sceneToMoveTo = GameOverScene(size: frame.size)
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
    }
}
