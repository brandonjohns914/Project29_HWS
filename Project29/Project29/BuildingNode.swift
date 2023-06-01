//
//  BuildingNode.swift
//  Project29
//
//  Created by Brandon Johns on 5/31/23.
//

import UIKit
import SpriteKit

class BuildingNode: SKSpriteNode
{
    
    var currentImage: UIImage!
    
    func setup()
    {
        name = "building"
        
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        
        configurePhysics()
        
    }//setup
    
    func drawBuilding(size: CGSize) -> UIImage
    {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image
        { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            let color: UIColor
            
            
            //building colors
            switch Int.random(in: 0...2)
            {
            case 0:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            
            color.setFill()                                     //fill color
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)                //draw rect and fill
            
            
            let lightOnColor = UIColor(hue: 0.190, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
            
            
            for row in stride(from: 10, to: Int(size.height - 10), by: 40)                                          // 10 =indent 40 = up
            {
                for col in stride(from: 10, to: Int(size.width - 10), by: 40)
                {
                    if Bool.random()                                                                                //random light on or off
                    {
                        lightOnColor.setFill()
                    }//random
                    
                    else
                    {
                        lightOffColor.setFill()
                    }//else
                    
                    ctx.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))                                   //draws light
                    
                }// for col
            }// for row
            
            
        }//image
        
        return image
        
    }//drawBuilding
    
    
    func configurePhysics()
    {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        
        physicsBody?.isDynamic = false //does not move
        physicsBody?.categoryBitMask = CollisionTypes.building.rawValue
        physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
    }//configurePhysis
    
    
    func hit(at point: CGPoint) {
        let convertedPoint = CGPoint(x: point.x + size.width / 2.0, y: abs(point.y - (size.height / 2.0)))                                      //where banana hit
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            currentImage.draw(at: .zero)
            
            ctx.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))                     //hole in building
            ctx.cgContext.setBlendMode(.clear)                                                                                                  //clears it
            ctx.cgContext.drawPath(using: .fill)
        }
        
        texture = SKTexture(image: image)
        currentImage = image                                                                                                                    //updates
        
        configurePhysics()
    }//hit
    
}//BuildingNode
