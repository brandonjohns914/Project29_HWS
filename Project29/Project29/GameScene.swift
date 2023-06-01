//
//  GameScene.swift
//  Project29
//
//  Created by Brandon Johns on 5/31/23.
//




import UIKit
import SpriteKit
import GameplayKit

enum CollisionTypes: UInt32
{
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var buildings = [BuildingNode]()                                                    //where to place buildings
    
    weak var viewController: GameViewController?                                        //connection to GameViewController.swift
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1
    
    override func didMove(to view: SKView)
    {
        
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        createBuildings()
        createPlayers()
        physicsWorld.contactDelegate = self
        
    }//didMove
    
    
    func  createBuildings()
    {
        var currentX: CGFloat = -15
        
        while currentX < 1024
        {
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600) )
            
            currentX += size.width + 2
            
            let building = BuildingNode(color: .red, size: size)
            
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            
            building.setup()
            
            addChild(building)
            
            buildings.append(building)
        }//while
    }//createBuildings
    
    func launch(angle: Int , velocity: Int)                                                                     //spritekit uses radians
    {
        let speed = Double(velocity) / 10
        
        let radians = degree2radians(degrees: angle)
        
        if banana != nil
        {
            banana.removeFromParent()
            banana = nil
        }//banana
        
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue        // hit building or player
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue        // hit building or player  bounce off
        
        
        banana.physicsBody?.usesPreciseCollisionDetection = true                                                        //every frame what have i run into
        //small objects fast moving normally dont use
        addChild(banana)
        
        
        if currentPlayer == 1
        {
            banana.position = CGPoint(x: player1.position.x - 30, y:  player1.position.y + 40)                          //banana position
            banana.physicsBody?.angularVelocity = -20                                                                   //spinning banana
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            
            let pause = SKAction.wait(forDuration: 0.15)
            
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])                                           //raisearm pause lowerarm
            
            player1.run(sequence)
            
            
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)                                  //moves to right
            
            banana.physicsBody?.applyImpulse(impulse)
        }//player one
        else
        {
            banana.position = CGPoint(x: player2.position.x + 30, y:  player2.position.y + 40)                          //banana position
            banana.physicsBody?.angularVelocity = 20                                                                   //spinning banana
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            
            let pause = SKAction.wait(forDuration: 0.15)
            
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])                                           //raisearm pause lowerarm
            
            player2.run(sequence)
            
            
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)                             //moves to left
            
            banana.physicsBody?.applyImpulse(impulse)
        }//player two
        
    }
    
    
    func createPlayers()
    {
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue                                  //bounce off banana
        player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue                                // tell us about banana collision
        player1.physicsBody?.isDynamic = false                                                                  //no gravity
        
        let player1Building = buildings[1]
        
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        //places bottom of player at the top of the building
        
        addChild(player1)
        
        
        
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
        player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue                                  //bounce off banana
        player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue                                // tell us about banana collision
        player2.physicsBody?.isDynamic = false                                                                  //no gravity
        
        let player2Building = buildings[buildings.count - 2]
        
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        //places bottom of player at the top of the building
        
        addChild(player2)
        
    }//createPlayers
    
    func degree2radians(degrees: Int) -> Double
    {
        return (Double(degrees) * .pi / 180)
    }//degree2radians
    
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }//bodyA
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }//bodyB
        
        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }
        
        if firstNode.name == "banana" && secondNode.name == "building"
        {
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
        }//banana->building
        
        if firstNode.name == "banana" && secondNode.name == "player1"
        {
            destroy(player: player1)                                                        //banana hits player destory player
        }//banana->player1
        
        if firstNode.name == "banana" && secondNode.name == "player2"
        {
            destroy(player: player2)                                                        //banana hits player destory player
        }//banana->player2
    }//didBegan
    
    func destroy(player: SKSpriteNode)
    {
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer")
        {
            explosion.position = player.position
            addChild(explosion)
        }//expolsion
        
        player.removeFromParent()
        banana.removeFromParent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2)
        {
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController!.currentGame = newGame                                                   //new game points to view controller and view controller points to new game
            
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer                                                 // player one wins now second player starts
            
            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)                                    //end game and show new game after 2 seconds
        }//dispatch
        
    }//Destory
    
    
    func changePlayer() {
        if currentPlayer == 1
        {
            currentPlayer = 2
        }
        else
        {
            currentPlayer = 1
        }
        
        viewController?.activatePlayer(number: currentPlayer)
    }//changePlayer
    
    func bananaHit(building: SKNode, atPoint contactPoint: CGPoint)                                                             //contact point= banana hit building
    {
        guard let building = building as? BuildingNode else { return }
        
        let buildingLocation = convert(contactPoint, to: building)                                                              //where the contact point is realtive to the building
        building.hit(at: buildingLocation)                                                                                      //building destoried
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding")
        {
            explosion.position = contactPoint
            addChild(explosion)
        }//explosion
        
        banana.name = ""
        banana.removeFromParent()
        banana = nil
        
        changePlayer()
    }//bananaHit
    
    
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }
        
        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }//update
}//GameScene
