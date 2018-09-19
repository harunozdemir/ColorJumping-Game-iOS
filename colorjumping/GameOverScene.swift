//
//  GameOverScene.swift
//  colorjumping
//
//  Created by pc on 30.06.2017.
//  Copyright © 2017 harunozdemir. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    var scoreLabelNode:SKLabelNode!
    
    var newGameButtonNode:SKSpriteNode!
    var backtoMainMenuButtonNode:SKSpriteNode!
    var starScoreLabelNode:SKLabelNode!
   
    
    
    override func didMove(to view: SKView) {
        
        nodeInit()
        
        scoreLabelNode.text = "\(GameState.sharedInstance.score)"
        starScoreLabelNode.text = String(format: "x %d", GameState.sharedInstance.stars)

    }
    
    func nodeInit() {
        scoreLabelNode = self.childNode(withName: "scoreLabel") as! SKLabelNode
        starScoreLabelNode = self.childNode(withName: "starScoreLabel") as! SKLabelNode
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
        backtoMainMenuButtonNode = self.childNode(withName: "backtoMainMenuButton") as! SKSpriteNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
             let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            
            if nodesArray.first?.name == "newGameButton" {
               
                let gameScene = GameScene(size: CGSize(width: 1536, height: 2048))
                gameScene.scaleMode = .aspectFill
                self.view?.presentScene(gameScene,transition: transition)
                
            } else {
            
                let menuScene = MenuScene(fileNamed: "MenuScene")!
                menuScene.scaleMode = .aspectFill
                self.view?.presentScene(menuScene,transition: transition)
                
            }
            
        }
        
    }

}
