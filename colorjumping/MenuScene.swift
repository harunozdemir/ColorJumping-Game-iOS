//
//  MenuScene.swift
//  colorjumping
//
//  Created by pc on 29.06.2017.
//  Copyright © 2017 harunozdemir. All rights reserved.
//

import UIKit
import SpriteKit

class MenuScene: SKScene {
    
    var newGameButtonNode:SKSpriteNode!
    var exitButtonNode:SKSpriteNode!
    var starScoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        nodeInit()
        
        
        starScoreLabelNode.text = String(format:"x %d",GameState.sharedInstance.stars)
        bestScoreLabelNode.text = String(format:"Best: %d",GameState.sharedInstance.highScore)
        
        
        
        
    }
    
    func nodeInit() {
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
        
        exitButtonNode = self.childNode(withName: "exitButton") as! SKSpriteNode
        
        starScoreLabelNode = self.childNode(withName: "starScoreLabel") as! SKLabelNode!
        
        bestScoreLabelNode = self.childNode(withName: "bestScoreLabel") as! SKLabelNode
     
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameButton" {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: CGSize(width: 1536, height: 2048))
                gameScene.scaleMode = .aspectFill
                self.view?.presentScene(gameScene,transition: transition)
                
            } else if nodesArray.first?.name == "exitButton" {
                exit(0)
            }
        }
    }
    
  

}
