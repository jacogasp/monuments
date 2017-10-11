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
    
    func yPosition() {
        let locationNodes = sceneLocationView.locationNodes as! [MNLocationAnnotationNode]
        for i in 0...locationNodes.count - 2 {
            
            let node1 = locationNodes[i]
            let pos1 = node1.childNodes.first!.worldPosition
            print("\n\(node1.annotation.title!)")

            for j in 1...locationNodes.count - 3 {
                let node2 = locationNodes[j]
                let pos2 = node2.childNodes.first!.worldPosition
                
                let xDistance = abs(pos2.x - pos1.x)
                let yDistance = abs(pos2.y - pos1.y)
                let zDistance = abs(pos2.z - pos1.z)
                
                if zDistance < 150 && yDistance < 10 {
                    print ("\t\(node2.annotation.title!) xDist: \(xDistance) yDist: \(yDistance) zDist: \(zDistance)")
                    node2.childNodes.first?.position.y += 10
                }
            }
        }
    }
    
    func stackAnnotation() {
        var worldPos1 = SCNVector3()
        var worldPos2 = SCNVector3()
        
        let locationNodes = self.sceneLocationView.locationNodes as! [MNLocationAnnotationNode]
        let sortedLocationNodes = locationNodes.sorted(by: {$0.childNodes.first!.worldPosition.y > $1.childNodes.first!.worldPosition.y})
        
        for locationNode1 in sortedLocationNodes {
            print(locationNode1.annotation.title!)
            // Dectecting collision
            var hasCollision = false
            var i = 0
            while i < sortedLocationNodes.count {
                let locationNode2 = sortedLocationNodes[i]

                worldPos1 = locationNode1.childNodes.first!.worldPosition
                worldPos2 = locationNode2.childNodes.first!.worldPosition

                let pos1 = locationNode1.childNodes.first!.position
                let pos2 = locationNode2.childNodes.first!.position

                let absolutePos1 = SCNVector3(x: worldPos1.x + pos1.x, y: worldPos1.y + pos1.y, z: worldPos1.z + pos1.z)
                let absolutePos2 = SCNVector3(x: worldPos2.x + pos2.x, y: worldPos2.y + pos2.y, z: worldPos2.z + pos2.z)

                print("---- worldPos1: \(worldPos1.description), pos1: \(pos1.description) absPos1: \(absolutePos1.description)")
                print("---- worldPos2: \(worldPos2.description), pos2: \(pos2.description) absPos2: \(absolutePos2.description)")
                
                if SCNVector3EqualToVector3(worldPos1, worldPos2) {
                    print("---- Match \(locationNode2.annotation.title!) -> skip", terminator: "")
                    if hasCollision {
                        hasCollision = false
                        i = 0
                        print("continue\n")
                        continue
                    }
                    print("skip\n")
                    break
                }

                var intersect: Bool {
                    let sphere1 = locationNode1.boundingSphere
                    let sphere2 = locationNode2.boundingSphere

                    let distance = absolutePos1.distance(to: absolutePos2)
                    if distance < sphere1.radius + sphere2.radius {
                        return true
                    } else {
                        return false
                    }
                }

                 if intersect {
                    locationNode1.childNodes.first?.position.y += 30
                    hasCollision = true
                     print("---- \(locationNode1.annotation.title!) collides with \(locationNode2.annotation.title!)")
                }
                i += 1
            }
        }
    }
}

extension SCNVector3 {
    var description: String {
        return "(x: \(x), y:\(y), z: \(z))"
    }
}
