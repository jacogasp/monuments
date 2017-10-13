//
//  Extensions.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 05/10/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import SceneKit

@available(iOS 11.0, *)
extension ViewController {
    
    func stackAnnotation() {
        
        guard self.sceneLocationView.locationNodes.count > 0 else { return }
        
        var worldPos1 = SCNVector3()
        var worldPos2 = SCNVector3()
        
        let locationNodes = self.sceneLocationView.locationNodes as! [MNLocationAnnotationNode]
        let sortedLocationNodes = locationNodes.sorted(by: {$0.annotation.distanceFromUser < $1.annotation.distanceFromUser})
        
        for locationNode1 in sortedLocationNodes {
//            print(locationNode1.annotation.title!)
            // Dectecting collision
            var hasCollision = false
            var i = 0
            while i < sortedLocationNodes.count {
                let locationNode2 = sortedLocationNodes[i]
                
                let node1 = locationNode1.childNodes.first!
                let node2 = locationNode2.childNodes.first!

                worldPos1 = node1.worldPosition
                worldPos2 = node2.worldPosition

                let pos1 = node1.position
                let pos2 = node2.position

                var absolutePos1: SCNVector3 {
                    return SCNVector3(x: worldPos1.x + pos1.x, y: worldPos1.y + pos1.y, z: worldPos1.z + pos1.z)
                }
                var absolutePos2: SCNVector3 {
                    return SCNVector3(x: worldPos2.x + pos2.x, y: worldPos2.y + pos2.y, z: worldPos2.z + pos2.z)
                }

                // print("---- worldPos1: \(worldPos1.description), pos1: \(pos1.description) absPos1: \(absolutePos1.description)")
                // print("---- worldPos2: \(worldPos2.description), pos2: \(pos2.description) absPos2: \(absolutePos2.description)")
                
                if SCNVector3EqualToVector3(worldPos1, worldPos2) {
                    // print("---- Match \(locationNode2.annotation.title!) -> ", terminator: "")
                    // If collision, start over because movement could cause additional collisions
                    if hasCollision {
                        hasCollision = false
                        i = 0
                        // print("continue\n")
                        continue
                    }
                    // print("skip\n")
                    break
                }

                let angleMax: CGFloat = 0.3
                let angle = angleBetweenTwoPointsAndUser(pointA: worldPos1, pointB: worldPos2)
                let distance = abs(absolutePos2.y - absolutePos1.y)
                
                 if distance < 5 && angle < angleMax {
                    node1.position.y += 8
                    hasCollision = true
                    // print("---- \(locationNode1.annotation.title!) COLLIDES WITH \(locationNode2.annotation.title!)")
                }
                i += 1
            }
        }
    }
    
    /// Calculates the angle between the user position and two points on the xz plane using the cosine
    /// c^2 = a^2 + b^2 - 2ab * cos(x) -> x = arccos[(a^2 + b^2 - c^2) / 2ab]
    func angleBetweenTwoPointsAndUser(pointA: SCNVector3, pointB: SCNVector3) -> CGFloat {
        if let userLocation = sceneLocationView.currentScenePosition(){
            
            let A = CGPoint(x: CGFloat(pointA.x), y: CGFloat(pointA.z))
            let B = CGPoint(x: CGFloat(pointB.x), y: CGFloat(pointB.z))
            let U = CGPoint(x: CGFloat(userLocation.x), y: CGFloat(userLocation.z))
            
            let a = distanceBetween(A, U)
            let b = distanceBetween(B, U)
            let c = distanceBetween(A, B)
            return acos((a*a + b*b - c*c) / (2*a*b))
        } else {
            return 0.0
        }
    }
    
    /// Calculate the distance between two points in 2D
    func distanceBetween(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return CGFloat(sqrt(dx * dx + dy * dy))
    }
    
}

extension SCNVector3 {
    var description: String {
        return "(x: \(x), y:\(y), z: \(z))"
    }
    
    func distance(vector: SCNVector3) -> Float {
        return sqrt( pow((self.x - vector.x),2) + pow(self.y - vector.y, 2) + pow((self.z - vector.z),2))
    }
}
