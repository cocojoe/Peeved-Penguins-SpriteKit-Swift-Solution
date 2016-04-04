//
//  GameScene.swift
//  PeevedPenguinBuild
//
//  Created by Martin Walsh on 21/03/2016.
//  Copyright (c) 2016 Martin Walsh. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /* Game object connections */
    var catapultArm: SKSpriteNode!
    var catapult: SKSpriteNode!
    var cantileverNode: SKSpriteNode!
    var touchNode: SKSpriteNode!
    
    /* Level loader holder */
    var levelNode: SKNode!
    
    /* Camera helpers */
    var cameraTarget: SKNode?
    
    /* UI Connections */
    var buttonRestart: MSButtonNode!
    
    /* Physics helpers */
    var touchJoint: SKPhysicsJointSpring?
    var penguinJoint: SKPhysicsJointPin?
    
    override func didMoveToView(view: SKView) {
        /* Set reference to game object connections node */
        catapultArm = childNodeWithName("catapultArm") as! SKSpriteNode
        catapult = childNodeWithName("catapult") as! SKSpriteNode
        cantileverNode = childNodeWithName("cantileverNode") as! SKSpriteNode
        touchNode = childNodeWithName("touchNode") as! SKSpriteNode
        
        /* Set reference to the level loader node */
        levelNode = childNodeWithName("//levelNode")
        
        /* Set UI connections */
        buttonRestart = childNodeWithName("//buttonRestart") as! MSButtonNode
        
        /* Setup restart button selection handler */
        buttonRestart.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFit
            
            /* Show debug */
            skView.showsPhysics = true
            skView.showsDrawCount = true
            skView.showsFPS = false
            
            /* Restart game scene */
            skView.presentScene(scene)
        }
        
        /* Load Level 1 */
        let newLevel = SKReferenceNode(fileNamed: "Level1") as SKReferenceNode!
        levelNode.addChild(newLevel)
        
        /* Create catapult arm physics body of type alpha */
        let catapultArmBody = SKPhysicsBody (texture: catapultArm!.texture!, size: catapultArm.size)
        
        /* Set mass, needs to be heavy enough to hit the penguin with solid force */
        catapultArmBody.mass = 0.5
        
        /* No need for gravity otherwise the arm will fall over */
        catapultArmBody.affectedByGravity = false
        
        /* Improves physics collision handling of fast moving objects */
        catapultArmBody.usesPreciseCollisionDetection = true
        
        /* Assign the physics body to the catapult arm */
        catapultArm.physicsBody = catapultArmBody
        
        /* Pin joint catapult and catapult arm */
        let catapultPinJoint = SKPhysicsJointPin.jointWithBodyA(catapult.physicsBody!, bodyB: catapultArm.physicsBody!, anchor: CGPoint(x:210 ,y:104))
        physicsWorld.addJoint(catapultPinJoint)
        
        /* Spring joint catapult arm and cantilever node */
        let catapultSpringJoint = SKPhysicsJointSpring.jointWithBodyA(catapultArm.physicsBody!, bodyB: cantileverNode.physicsBody!, anchorA: catapultArm.position + CGPoint(x:15, y:30), anchorB: cantileverNode.position)
        physicsWorld.addJoint(catapultSpringJoint)
        
        /* Make this joint a bit more springy */
        catapultSpringJoint.frequency = 1.5
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        size.height = 320
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        /* There will only be one touch as multi touch is not enabled by default */
        for touch in touches {
            
            /* Grab scene position of touch */
            let location    = touch.locationInNode(self)
            
            /* Get node reference if we're touching a node */
            let touchedNode = nodeAtPoint(location)
            
            /* Is it the catapult arm? */
            if touchedNode.name == "catapultArm" {
                
                /* Reset touch node position */
                touchNode.position = location
                
                /* Spring joint touch node and catapult arm */
                touchJoint = SKPhysicsJointSpring.jointWithBodyA(touchNode.physicsBody!, bodyB: catapultArm.physicsBody!, anchorA: location, anchorB: location)
                physicsWorld.addJoint(touchJoint!)
                
                /* Add a new penguin to the scene */
                let penguin = MSReferenceNode(fileNamed: "Penguin") as MSReferenceNode!
                addChild(penguin)
                
                /* Position penguin in the catapult bucket area */
                penguin.avatar.position = catapultArm.position + CGPoint(x: 32, y: 50)
                
                /* Improves physics collision handling of fast moving objects */
                penguin.avatar.physicsBody?.usesPreciseCollisionDetection = true
                
                /* Setup pin joint between penguin and catapult arm */
                penguinJoint = SKPhysicsJointPin.jointWithBodyA(catapultArm.physicsBody!, bodyB: penguin.avatar.physicsBody!, anchor: penguin.avatar.position)
                physicsWorld.addJoint(penguinJoint!)
                
                /* Remove any camera actions */
                camera?.removeAllActions()
                
                /* Set camera to follow penguin */
                cameraTarget = penguin.avatar
                
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch moved */
        
        /* There will only be one touch as multi touch is not enabled by default */
        for touch in touches {
            
            /* Grab scene position of touch and update touchNode position */
            let location       = touch.locationInNode(self)
            touchNode.position = location
            
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch ended */
        
        /* Let it fly!, remove joints used in catapult launch */
        if let touchJoint = touchJoint { physicsWorld.removeJoint(touchJoint) }
        if let penguinJoint = penguinJoint { physicsWorld.removeJoint(penguinJoint) }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        /* Check we have a valid camera target to follow */
        if let cameraTarget = cameraTarget {
            
            /* Set camera postion to follow target horizontally, keep vertical locked */
            camera?.position = CGPoint(x:cameraTarget.position.x, y:camera!.position.y)
            
            /* Clamp camera horizontal scrolling to our visible scene area only */
            camera?.position.x.clamp(283, 677)
            
            /* Check penguin has come to rest */
            if cameraTarget.physicsBody?.joints.count == 0 && cameraTarget.physicsBody?.velocity.length() < 0.18 {
                
                cameraTarget.removeFromParent()
                
                /* Reset catapult arm */
                catapultArm.physicsBody?.velocity = CGVector(dx:0, dy:0)
                catapultArm.physicsBody?.angularVelocity = 0
                catapultArm.zRotation = 0
                
                /* Reset camera */
                let cameraReset = SKAction.moveTo(CGPoint(x:284, y:camera!.position.y), duration: 1.5)
                let cameraDelay = SKAction.waitForDuration(0.5)
                let cameraSequence = SKAction.sequence([cameraDelay,cameraReset])
                
                camera?.runAction(cameraSequence)
            }
            
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        /* Physics contact delegate implementation */
        
        /* Get references to the bodies involved in the collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Get references to the physics body parent SKSpriteNode */
        let nodeA = contactA.node as! SKSpriteNode
        let nodeB = contactB.node as! SKSpriteNode
        
        /* Was the collision more than a gentle nudge? */
        if contactA.categoryBitMask == 2 || contactB.categoryBitMask == 2 {
            
            /* More than a gentle nudge? */
            if contact.collisionImpulse > 2.0 {
                
                /* Kill Seal(s) */
                if contactA.categoryBitMask == 2 { dieSeal(nodeA) }
                if contactB.categoryBitMask == 2 { dieSeal(nodeB) }
            }
        }
    }
    
    func dieSeal(node: SKNode) {
        /* Seal death*/
        
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "SealExplosion")!
        
        /* Convert node location (currently inside Level 1, to scene space) */
        particles.position = convertPoint(node.position, fromNode: node)
        
        /* Restrict total particles to reduce runtime of particle */
        particles.numParticlesToEmit = 25
        
        /* Add particles to scene */
        addChild(particles)
        
        /* Create our hero death action */
        let sealDeath = SKAction.runBlock({
            /* Remove seal node from scene */
            node.removeFromParent()
        })
        
        self.runAction(sealDeath)
        
    }
    
}
