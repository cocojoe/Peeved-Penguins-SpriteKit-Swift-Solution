//
//  MSPhysicsNode.swift
//  Make School
//
//  Created by Martin Walsh on 15/03/2016.
//  Copyright © 2016 Martin Walsh. All rights reserved.
//

import SpriteKit

class MSReferenceNode: SKReferenceNode {
    
    /* Avatar node connection */
    var avatar: SKSpriteNode!
    
    override init(url: URL?) {
        super.init(url: url)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didLoad(_ node: SKNode?) {
        
        /* Set reference to avatar node */
        avatar = childNode(withName: "//avatar") as! SKSpriteNode
    }
}
