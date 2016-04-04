//
//  MainScene.swift
//  PeevedPenguinBuild
//
//  Created by Martin Walsh on 29/03/2016.
//  Copyright © 2016 Martin Walsh. All rights reserved.
//

import SpriteKit

class MainScene: SKScene {
    
    /* UI Connections */
    var buttonPlay: MSButtonNode!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        /* Set UI connections */
        buttonPlay = self.childNodeWithName("buttonPlay") as! MSButtonNode
        
        /* Setup restart button selection handler */
        buttonPlay.selectedHandler = {
            
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
            
            /* Start game scene */
            skView.presentScene(scene)
        }
        
    }

}
