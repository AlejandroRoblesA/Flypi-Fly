//
//  GameScene.swift
//  Flypi Fly
//
//  Created by Alejandro Robles on 3/18/20.
//  Copyright © 2020 Alejandro Robles. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var fly        = SKSpriteNode()
    var background = SKSpriteNode()
    var topTube    = SKSpriteNode()
    var downTube   = SKSpriteNode()
    
    var flyTexture  = SKTexture()
    var scoredLabel = SKLabelNode()
    
    var scored = 0
    var timer  = Timer()
    var gameOver = false
    
    enum kindNode: UInt32{
        case fly          = 1
        case tubeAndFloor = 2
        case tubeSpace    = 4
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        restartGame()
        
        
        
        
    }
    
    func drawBackground(){
        let backgroundTexture = SKTexture(imageNamed: "fondo")
        
        let backgroundMovement         = SKAction.move(by: CGVector(dx: -backgroundTexture.size().width, dy: 0), duration: 3.5)
        let backgroundMovementOrigin   = SKAction.move(by: CGVector(dx: backgroundTexture.size().width, dy: 0), duration: 0)
        let backgroundMovementInfinite = SKAction.repeatForever(SKAction.sequence([backgroundMovement, backgroundMovementOrigin]))
        
        
        var i: CGFloat = 0
        
        while i<2 {
            background = SKSpriteNode(texture: backgroundTexture)
            
            background.position = CGPoint(x: backgroundTexture.size().width*i, y: self.frame.midY)
            
            background.size.height = self.frame.height
            background.zPosition = -1
            background.run(backgroundMovementInfinite)
            self.addChild(background)
            i += 1
        }
    }
    
    func drawScored(){
        scoredLabel.fontName = "Guevara"
        scoredLabel.fontSize = 80
        scoredLabel.text = "0"
        scoredLabel.color = .red
        scoredLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY+500)
        scoredLabel.zPosition = 3
        self.addChild(scoredLabel)
    }
    
    func createFloor(){
        let floor = SKNode()
        floor.position = CGPoint(x: -self.frame.midX, y: -self.frame.height/2)
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.categoryBitMask = kindNode.tubeAndFloor.rawValue
        floor.physicsBody?.collisionBitMask = kindNode.fly.rawValue
        floor.physicsBody?.contactTestBitMask = kindNode.fly.rawValue
        self.addChild(floor)
    }
    
    func drawFly(){
        flyTexture = SKTexture(imageNamed: "fly1")
        let flyTextureTwo = SKTexture(imageNamed: "fly2")
        let animation = SKAction.animate(with: [flyTexture, flyTextureTwo], timePerFrame: 0.001)
        
        let infiniteAnimation = SKAction.repeatForever(animation)
        
        fly = SKSpriteNode(texture: flyTexture)
        fly.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        fly.physicsBody = SKPhysicsBody(circleOfRadius: flyTexture.size().height/2)
        fly.physicsBody?.isDynamic = false
        
        fly.physicsBody?.categoryBitMask = kindNode.fly.rawValue
        fly.physicsBody?.collisionBitMask = kindNode.tubeAndFloor.rawValue
        fly.physicsBody?.contactTestBitMask = kindNode.tubeAndFloor.rawValue | kindNode.tubeSpace.rawValue
        
        fly.run(infiniteAnimation)
        fly.zPosition = 1
        self.addChild(fly)
    }
    
    @objc func drawTubes(){
        
        let moveTubeRightLeft = SKAction.move(by: CGVector(dx: -3*self.frame.width, dy: 0), duration: TimeInterval(self.frame.width/80))
        
        let removeTubes = SKAction.removeFromParent()
        
        let moveAndRemoveTubes = SKAction.sequence([moveTubeRightLeft, removeTubes])
        
        let gap = fly.size.height*3
        let tubeMovementUpDown = CGFloat(arc4random()%UInt32(self.frame.height/2))
        let compensacionTube = tubeMovementUpDown-self.frame.height/4
        
        let upTubeTexture = SKTexture(imageNamed: "Tubo1")
        topTube = SKSpriteNode(texture: upTubeTexture)
        topTube.position = CGPoint(x: self.frame.midX+self.frame.width, y: self.frame.midY + upTubeTexture.size().height/2+gap+compensacionTube)
        topTube.zPosition = 0
        topTube.physicsBody = SKPhysicsBody(rectangleOf: upTubeTexture.size())
        topTube.physicsBody?.isDynamic = false
        topTube.physicsBody?.categoryBitMask = kindNode.tubeAndFloor.rawValue
        topTube.physicsBody?.collisionBitMask = kindNode.fly.rawValue
        topTube.physicsBody?.contactTestBitMask = kindNode.fly.rawValue
        topTube.run(moveAndRemoveTubes)
        self.addChild(topTube)
        
        let downTubeTexture = SKTexture(imageNamed: "Tubo2")
        downTube = SKSpriteNode(texture: downTubeTexture)
        downTube.position = CGPoint(x: self.frame.midX+self.frame.width, y: self.frame.midY - downTubeTexture.size().height/2-gap+compensacionTube)
        downTube.zPosition = 0
        downTube.physicsBody = SKPhysicsBody(rectangleOf: downTubeTexture.size())
        downTube.physicsBody?.isDynamic = false
        downTube.physicsBody?.categoryBitMask = kindNode.tubeAndFloor.rawValue
        downTube.physicsBody?.collisionBitMask = kindNode.fly.rawValue
        downTube.physicsBody?.contactTestBitMask = kindNode.fly.rawValue
        downTube.run(moveAndRemoveTubes)
        self.addChild(downTube)
        
        let space = SKSpriteNode()
        space.position = CGPoint(x: self.frame.midX+self.frame.width, y: self.frame.midY + compensacionTube)
        
        space.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upTubeTexture.size().width, height: fly.size.height*3))
        space.physicsBody?.isDynamic = false
        space.zPosition = 1
        
        space.physicsBody?.categoryBitMask = kindNode.tubeSpace.rawValue
        space.physicsBody?.collisionBitMask = 0
        space.physicsBody?.contactTestBitMask = kindNode.fly.rawValue
        space.run(moveAndRemoveTubes)
        self.addChild(space)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (gameOver == false){
            fly.physicsBody?.isDynamic = true
            fly.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            fly.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
        }
        else{
            gameOver = false
            scored = 0
            self.speed = 1
            self.removeAllChildren()
            restartGame()
        }
        
        
    }
    
    func restartGame(){
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.drawTubes), userInfo: nil, repeats: true)
        
        drawScored()
        
        drawBackground()
        createFloor()
        drawFly()
        drawTubes()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if (bodyA.categoryBitMask == kindNode.fly.rawValue && bodyB.categoryBitMask == kindNode.tubeSpace.rawValue) || (bodyB.categoryBitMask == kindNode.fly.rawValue && bodyA.categoryBitMask == kindNode.tubeSpace.rawValue) {
            scored += 100
            scoredLabel.text = String(scored)
        }
        else{
            gameOver = true
            self.speed  = 0
            timer.invalidate()
            scoredLabel.text = "GAME OVER"
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
