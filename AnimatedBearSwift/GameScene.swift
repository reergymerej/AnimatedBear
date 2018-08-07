//
//  GameScene.swift
//  AnimatedBearSwift
//
//  Created by Jeremy Greer on 8/6/18.
//  Copyright © 2018 Grizzle. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var bear = SKSpriteNode()
    private var bearWalkingFrames: [SKTexture] = []
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .blue
        self.buildBear()
    }
    
    func buildBear() {
        let bearAnimatedAtlas = SKTextureAtlas(named: "BearImages")
        var walkFrames : [SKTexture] = []
        let numImages = bearAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let bearTextureName = "bear\(i)"
            walkFrames.append(bearAnimatedAtlas.textureNamed(bearTextureName))
        }
        self.bearWalkingFrames = walkFrames
        
        let firstFrameTexture = self.bearWalkingFrames[0]
        self.bear = SKSpriteNode(texture: firstFrameTexture)
        self.bear.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        let size = bear.size
        let scale = CGFloat(0.3)
        bear.scale(to: CGSize(width: size.width * scale, height: size.height * scale))
        self.addChild(self.bear)
    }
    
    func animateBear() {
        self.bear.run(SKAction.repeatForever(
            SKAction.animate(
                with: self.bearWalkingFrames,
                timePerFrame: 0.1,
                resize: false,
                restore: true)),
                      withKey: "walkingInPlaceBear"
        )
    }
    
    func moveBear(location: CGPoint) {
        var multiplierForDirection: CGFloat
        let bearSpeed = self.frame.size.width / 3.0
        
        let moveDifference = CGPoint(x: location.x - bear.position.x,
                                     y: location.y - bear.position.y)
        let distanceToMove = sqrt(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y)
        
        let moveDuration = distanceToMove / bearSpeed
        
        if moveDifference.x < 0 {
            multiplierForDirection = 1.0
        } else {
            multiplierForDirection = -1.0
        }
        
        self.bear.xScale = abs(bear.xScale) * multiplierForDirection
        
        if bear.action(forKey: "walkingInPlaceBear") == nil {
            animateBear()
        }
        
        let moveAction = SKAction.move(to: location, duration: (TimeInterval(moveDuration)))
        
        let doneAction = SKAction.run({ [weak self] in
            self?.bearMoveEnded()
        })
        
        let moveActionWithDone = SKAction.sequence([moveAction, doneAction])
        bear.run(moveActionWithDone, withKey: "bearMoving")
    }
    
    func bearMoveEnded() {
        self.bear.removeAllActions()
    }

    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        self.moveBear(location: location)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
