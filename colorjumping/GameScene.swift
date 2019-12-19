//
//  GameScene.swift
//  colorjumping
//
//  Created by pc on 28.06.2017.
//  Copyright © 2017 harunozdemir. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    struct PhysicsCategory {
        static let Player: UInt32 = 1
        static let Obstacle: UInt32 = 2
        static let Edge: UInt32 = 4
    }
    
    let colors = [SKColor.yellow, SKColor.red, SKColor.blue, SKColor.purple,SKColor.brown,SKColor.cyan,SKColor.darkGray,SKColor.magenta]
    
    var changedBackgroundColor:UIColor = SKColor.white
    
    let player = SKShapeNode(circleOfRadius: 40)
    var playerMove:Bool! = true
    
    var obstacles: [SKNode] = []
    var isObstacles: [Bool] = []
    let obstacleSpacing: CGFloat = 800
    let cameraNode = SKCameraNode()
    let scoreLabel = SKLabelNode()
    var score = 0
    var touchCount: Int = 0
    var isTouch:Bool = false
    var scaleFactor: CGFloat!
    
    var lblStars: SKLabelNode!
    var obstacleMove:Bool! = true
    var playerVelocitydX:Bool! = true
    var changeBackgroundColorDuration:CGFloat = 1.0
    var obstacleRotationDuration:CGFloat = 8.0
    var obstacleMovingVelocity:CGFloat = 20.0
    var changeOk:Bool! = true
    
    var bonusButton = SKSpriteNode()
    var isBonusClicked:Bool! = false
    var playerVelocitydy:CGFloat = 2000
    var bonusTimerLabel = SKLabelNode(fontNamed: "ArialMT")
    var bonusTimerValue: Int = 5 {
        didSet {
            bonusTimerLabel.text = "Time left: \(bonusTimerValue)"
        }
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        scaleFactor = self.size.width / 320.0
        
        
    }
    
    
    override func didMove(to view: SKView) {
        setupPlayerAndObstacles()
        
        //change background color
        isBackgroundColorChange()
        
        
        
        let ledge = SKNode()
        ledge.position = CGPoint(x: size.width/2, y: 160)
        let ledgeBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 10))
        ledgeBody.isDynamic = false
        ledgeBody.categoryBitMask = PhysicsCategory.Edge
        ledge.physicsBody = ledgeBody
        addChild(ledge)
        
        
        
        physicsWorld.gravity.dy = 0
        physicsWorld.contactDelegate = self
        
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        
        //score Label
        scoreLabel.position = CGPoint(x: -350, y: -900)
        scoreLabel.fontColor = .white
        scoreLabel.fontSize = 150
        scoreLabel.text = String(score)
        cameraNode.addChild(scoreLabel)
        
        //star
        let star = SKSpriteNode(imageNamed: "Star")
        star.size.width = 100
        star.size.height = 100
        star.position = CGPoint(x: -500, y: 950)
        cameraNode.addChild(star)
        
        
        //star count label
        lblStars = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblStars.fontSize = 50
        lblStars.fontColor = SKColor.white
        lblStars.position = CGPoint(x: -430,y: 930)
        lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
        cameraNode.addChild(lblStars)
        
        //bonus button
        bonusButton = SKSpriteNode(imageNamed: "bonusButton")
        bonusButton.name = "bonus"
        bonusButton.size.width = 500
        bonusButton.size.height = 200
        bonusButton.position = CGPoint(x: 0, y: 350)
        cameraNode.addChild(bonusButton)
        
        //bonus label
        bonusTimerLabel.fontColor = SKColor.black
        bonusTimerLabel.fontSize = 40
        bonusTimerLabel.position =  CGPoint(x: 0, y: 350)
        cameraNode.addChild(bonusTimerLabel)
        
        
        
        bonusButton.isHidden = true
        bonusTimerLabel.isHidden = true
        
        
    }
    
    func setupPlayerAndObstacles() {
        addPlayer()
        addObstacle()
        addObstacle()
        addObstacle()
        addStars()
        
        
    }
    
    func addPlayer() {
        
        player.fillColor = .blue
        player.strokeColor = player.fillColor
        player.position = CGPoint(x: size.width/2, y: 200)
        
        addChild(player)
        
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        player.physicsBody?.mass = 1.5
        
        player.physicsBody?.collisionBitMask = 4
        
        // 1
        player.physicsBody?.usesPreciseCollisionDetection = true
        // 2
        player.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
        // 3
        player.physicsBody?.collisionBitMask = 0
        // 4
        player.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Star | CollisionCategoryBitmask.Platform
        
    }
    
    func addObstacle() {
        let choice = Int(arc4random_uniform(2))
        switch choice {
        case 0:
            addCircleObstacle()
        case 1:
            addSquareObstacle()
        default:
            print("something went wrong")
        }
        
    }
    
    
    
    func addStars() {
        // Load the level
        /*let levelPlist = Bundle.main.path(forResource: "Level01", ofType: "plist")
         let levelData = NSDictionary(contentsOfFile: levelPlist!)!
         
         // Add the stars
         let stars = levelData["Stars"] as! NSDictionary
         let starPatterns = stars["Patterns"] as! NSDictionary
         let starPositions = stars["Positions"] as! [NSDictionary]
         
         for starPosition in starPositions {
         let patternX = (starPosition["x"] as AnyObject).floatValue
         let patternY = (starPosition["y"] as AnyObject).floatValue
         let pattern = starPosition["pattern"] as! NSString
         
         // Look up the pattern
         let starPattern = starPatterns[pattern] as! [NSDictionary]
         for starPoint in starPattern {
         let x = (starPoint["x"] as AnyObject).floatValue
         let y = (starPoint["y"] as AnyObject).floatValue
         let type = StarType(rawValue: (starPoint["type"]! as AnyObject).intValue)
         let positionX = CGFloat(x! + patternX!)
         let positionY = CGFloat(y! + patternY!)
         let starNode = createStarAtPosition(CGPoint(x: positionX, y: positionY), ofType: type!)
         addChild(starNode)
         }
         } */
        
        
        for _ in 0 ..< 70{
            let positionX = randomNumber(inRange:0...Int(self.size.width))
            let positionY = randomNumber(inRange:0...Int(obstacleSpacing * CGFloat(obstacles.count)))
            
            let type = StarType(rawValue: randomNumber(inRange: 0...1))
            let starNode = createStarAtPosition(CGPoint(x: positionX, y: positionY), ofType:type!)
            addChild(starNode)
        }
        
        
    }
    
    func createStarAtPosition(_ position: CGPoint, ofType type: StarType) -> StarNode {
        // 1
        let node = StarNode()
        let thePosition = CGPoint(x: position.x * scaleFactor, y: position.y)
        node.position = thePosition
        node.name = "NODE_STAR"
        
        // 2
        node.starType = type
        var sprite: SKSpriteNode
        if type == .special {
            sprite = SKSpriteNode(imageNamed: "StarSpecial")
        } else {
            sprite = SKSpriteNode(imageNamed: "Star")
        }
        node.addChild(sprite)
        
        // 3
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        
        // 4
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Star
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.contactTestBitMask = 0
        
        return node
    }
    
    
    
    func addCircleObstacle() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: -200))
        path.addLine(to: CGPoint(x: 0, y: -160))
        path.addArc(withCenter: CGPoint.zero,
                    radius: 160,
                    startAngle: CGFloat(3.0 * .pi/2),
                    endAngle: CGFloat(0),
                    clockwise: true)
        path.addLine(to: CGPoint(x: 200, y: 0))
        path.addArc(withCenter: CGPoint.zero,
                    radius: 200,
                    startAngle: CGFloat(0.0),
                    endAngle: CGFloat(3.0 * .pi/2),
                    clockwise: false)
        
        let obstacle = obstacleByDuplicatingPath(path, clockwise: true)
        
        obstacle.physicsBody?.velocity.dx = 10
        
        obstacles.append(obstacle)
        isObstacles.append(true)
        obstacle.position = CGPoint(x: size.width/2, y: obstacleSpacing * CGFloat(obstacles.count))
        
        addChild(obstacle)
        
        let rotateAction = SKAction.rotate(byAngle: 2.0 * CGFloat(Double.pi), duration: TimeInterval(obstacleRotationDuration))
        obstacle.run(SKAction.repeatForever(rotateAction))
        
    }
    
    func obstacleByDuplicatingPath(_ path: UIBezierPath, clockwise: Bool) -> SKNode {
        let container = SKNode()
        
        var rotationFactor = CGFloat(Double.pi/2)
        if !clockwise {
            rotationFactor *= -1
        }
        
        for i in 0...3 {
            let section = SKShapeNode(path: path.cgPath)
            //section.fillColor = colors[i]
            //section.strokeColor = colors[i]
            section.fillColor = .white
            section.strokeColor = .white
            section.zRotation = rotationFactor * CGFloat(i);
            
            let sectionBody = SKPhysicsBody(polygonFrom: path.cgPath)
            sectionBody.categoryBitMask = PhysicsCategory.Obstacle
            sectionBody.collisionBitMask = 0
            sectionBody.contactTestBitMask = PhysicsCategory.Player
            sectionBody.affectedByGravity = false
            section.physicsBody = sectionBody
            
            container.addChild(section)
        }
        return container
    }
    
    
    func addSquareObstacle() {
        let path = UIBezierPath(roundedRect: CGRect.init(x: -200, y: -200,
                                                         width: 400, height: 40),
                                cornerRadius: 20)
        
        let obstacle = obstacleByDuplicatingPath(path, clockwise: false)
        obstacles.append(obstacle)
        isObstacles.append(true)
        obstacle.position = CGPoint(x: size.width/2, y: obstacleSpacing * CGFloat(obstacles.count))
        addChild(obstacle)
        
        let rotateAction = SKAction.rotate(byAngle: -2.0 * CGFloat(Double.pi), duration: TimeInterval(obstacleRotationDuration))
        obstacle.run(SKAction.repeatForever(rotateAction))
    }
    
    
    
    func dieAndRestart() {
        /*touchCount = 0
         isTouch = false
         print("boom")
         player.physicsBody?.velocity.dy = 0
         player.removeFromParent()
         
         for node in obstacles {
         node.removeFromParent()
         }
         
         obstacles.removeAll()
         
         setupPlayerAndObstacles()
         cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
         score = 0
         scoreLabel.text = String(score) */
        
        GameState.sharedInstance.score = score
        GameState.sharedInstance.saveState()
        
        
      
      if let gameOverScene = GameOverScene(fileNamed: "GameOverScene") {
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        gameOverScene.scaleMode = .aspectFill
        self.view?.presentScene(gameOverScene,transition: transition)
      }
    
        
    }
    
    func isBackgroundColorChange() {
        let sequence = SKAction.sequence([SKAction.run(changeBackgroundColor), SKAction.wait(forDuration: TimeInterval(changeBackgroundColorDuration))])
        
        run(SKAction.repeatForever(sequence), withKey: "backgroundColorChangeAction")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "bonus" {
                isBonusClicked = true
                
                
                let random = randomNumber(inRange: 0...1)
                
                
                if random == 0 {
                    print("bonus1")
                    changeOk = true
                    //isTouch = true
                    touchCount += 1
                    player.physicsBody?.velocity.dy = playerVelocitydy
                    score += 10
                    
                    
                    
                } else if random == 1{
                    //sleep 5 second
                    print("bonus2")
                  
                    removeAction(forKey: "backgroundColorChangeAction")
                    //isBackgroundColorChange()

                    
                    bonusTimerLabel.isHidden = false
                    let wait = SKAction.wait(forDuration: 1) //change countdown speed here
                    let block = SKAction.run({
                        [unowned self] in
                        
                        if self.bonusTimerValue > 0{
                            self.bonusTimerValue -= 1
                        }else{
                            self.isBonusClicked = false
                            self.bonusTimerValue = 5
                            self.removeAction(forKey: "countdown")
                            self.bonusTimerLabel.isHidden = true
                    
                            self.isBackgroundColorChange()
                        }
                    })
                    let sequence = SKAction.sequence([wait,block])
                    
                    run(SKAction.repeatForever(sequence), withKey: "countdown")
                    
                    
                    /*DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                        
                       
                        
                        
                    }) */
                    
                } else if random == 2{
                    
                } else{
                    
                }
                
                
                
                
             
               
                bonusButton.isHidden = true
                
            } else{
                isBonusClicked = false
                
                if player.physicsBody?.velocity.dy == 0.0 {
                    changeOk = true
                    //isTouch = true
                    touchCount += 1
                    player.physicsBody?.velocity.dy = playerVelocitydy
                    
                    if touchCount%5 == 0 {
                        if changeOk {
                            changeBackgroundColorDuration -= 0.05
                            obstacleRotationDuration -= 0.15
                            obstacleMovingVelocity += 1
                            
                            //removeAction(forKey: "backgroundColorChangeAction")
                            //isBackgroundColorChange()
                            
                            changeOk = false
                        }
                        
                        
                    }
                    
                    if touchCount%10 == 0 {
                        
                        bonusButton.isHidden = false
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                            self.visibleBonusButton()
                        
                        })
                        
                        playerVelocitydy += 10.0
                        
                      
                        
                    }
                }
                
                
                
            }
        }
        
    }
    
    
    
    func visibleBonusButton() {
        bonusButton.isHidden = true
    
    }
    
    override func update(_ currentTime: TimeInterval) {
        //print("position: \(player.position.y)")
        
        enumerateChildNodes(withName: "NODE_STAR", using: {
            (node, stop) in
            let star = node as! StarNode
            star.checkNodeRemoval(self.player)
        })
        
        
        
        let playerPositionInCamera = cameraNode.convert(player.position, from: self)
        if playerPositionInCamera.y > 0 {
            cameraNode.position.y = player.position.y
        }
        
        if playerPositionInCamera.y < -size.height/2 {
            dieAndRestart()
        }
        
        if player.position.y > obstacleSpacing * CGFloat(obstacles.count-2) {
            print("score")
            score += 1
            scoreLabel.text = String(score)
            addObstacle()
            addStars()
            player.fillColor = colors[randomNumber(inRange: 0...colors.count-1)]
            isTouch = false
            player.position.y = obstacleSpacing*CGFloat(touchCount)
            player.physicsBody?.velocity.dy = 0
            
            
            
        }
        
        for i in 0 ..< obstacles.count{
            
            if i%2 == 0 {
                moveByXObstacle(velocitydX: obstacleMovingVelocity, lowerLimitSize: self.size.width/2 - 100, upperLimitSize: self.size.width/2 + 100, obstacleIndex: i)
                
            }
            
        }
        
        if touchCount%2 == 0 {
            player.position.x = size.width/2
        }
        
        
        
        
    }
    
    func moveByXObstacle(velocitydX: CGFloat,lowerLimitSize: CGFloat,upperLimitSize: CGFloat,obstacleIndex: Int) {
        
        if isObstacles[obstacleIndex] {
            let moveAction = SKAction.moveBy(x: CGFloat(-velocitydX), y: CGFloat(0), duration: TimeInterval(1.0))
            obstacles[obstacleIndex].run(moveAction)
            
            
            
            if obstacles[obstacleIndex].position.x <= lowerLimitSize {
                isObstacles[obstacleIndex] = !isObstacles[obstacleIndex]
            }
            
            
        }
        else{
            let moveAction = SKAction.moveBy(x: CGFloat(velocitydX), y: CGFloat(0), duration: 1.0)
            obstacles[obstacleIndex].run(moveAction)
            
            
            
            if obstacles[obstacleIndex].position.x >= (upperLimitSize) {
                isObstacles[obstacleIndex] = !isObstacles[obstacleIndex]
                
            }
        }
        
        /*if playerVelocitydX {
         player.position.x = obstacles[obstacleIndex].position.x
         } else{
         player.position.x = size.width/2
         } */
        
        
        
        
        if touchCount%2 == 1 {
            
            if touchCount < obstacles.count {
                player.position.x = obstacles[touchCount-1].position.x
                
                //print("player: \(player.position.x) \nobstacle: \(obstacles[obstacleIndex].position.x)")
            }
            
            
        }
        
        
        
        
        
    }
    
    func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
    
    func changeBackgroundColor() {
        if !isTouch {
            changedBackgroundColor = colors[randomNumber(inRange: 0...colors.count-1)]
            backgroundColor = changedBackgroundColor
        }
        
        
    }
    
    func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
      let length = (range.upperBound - range.lowerBound + 1)
      
      let value = arc4random() % UInt32(length) + UInt32(range.lowerBound)
      return T(value)
    }
    
}


extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if let _ = contact.bodyA.node as? SKShapeNode, let _ = contact.bodyB.node as? SKShapeNode {
            
            if player.fillColor != changedBackgroundColor {
                if !isBonusClicked {
                    dieAndRestart()
                }
                
            }
            
        }
        
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        
        
        var updateHUD = false
        
        // 2
        let whichNode = (nodeA != player) ? nodeA: nodeB
        
        if ((whichNode as? GameObjectNode) != nil) {
            let other = whichNode as! GameObjectNode
            
            // 3
            updateHUD = other.collisionWithPlayer(player)
            
            // Update the HUD if necessary
            if updateHUD  {
                lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
                
            }
            
        }
        
        
    }
}

