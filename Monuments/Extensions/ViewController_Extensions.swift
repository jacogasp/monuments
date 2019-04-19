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
	func hitTest() {
		let locationNodes = self.sceneLocationView.locationNodes as! [MNLocationAnnotationNode]
		let options = [
			SCNHitTestOption.backFaceCulling.rawValue: false,
			SCNHitTestOption.firstFoundOnly.rawValue: false,
			SCNHitTestOption.ignoreChildNodes.rawValue: false,
			SCNHitTestOption.clipToZRange.rawValue: false,
			SCNHitTestOption.ignoreHiddenNodes.rawValue: false
		]
		let rootNode = sceneLocationView.scene.rootNode
		print("\(rootNode) \(rootNode.position)")
		
		for locationNode in locationNodes {
			let results = rootNode.hitTestWithSegment(
				from: SCNVector3(x: 0, y: 0, z: 0),
				to: locationNode.worldPosition,
				options: options)
			print("\(locationNode.worldPosition) \(results)")
		}
	}
	
	func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNNode {
		let indices: [Int32] = [0, 1]
		
		let source = SCNGeometrySource(vertices: [vector1, vector2])
		let element = SCNGeometryElement(indices: indices, primitiveType: .line)
		
		let line = SCNGeometry(sources: [source], elements: [element])
		let lineNode = SCNNode(geometry: line)
		lineNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
		return lineNode
	}
	
	func test() {
		let options = [
			SCNHitTestOption.backFaceCulling.rawValue: false,
			SCNHitTestOption.firstFoundOnly.rawValue: false,
			SCNHitTestOption.ignoreChildNodes.rawValue: false,
			SCNHitTestOption.clipToZRange.rawValue: false,
			SCNHitTestOption.ignoreHiddenNodes.rawValue: false,
			SCNHitTestOption.searchMode.rawValue: SCNHitTestSearchMode.all.rawValue
		] as [String: Any]
		let locationNodes = self.sceneLocationView.locationNodes as! [MNLocationAnnotationNode]
		
		for locationNode1 in locationNodes {
			var hasCollision = false
			let node1 = locationNode1.childNodes.first!
			print(locationNode1.annotation.title!, node1.worldPosition.description)
			
			var i = 0
			while i < locationNodes.count {
				let locationNode2 = locationNodes[i]
				let node2 = locationNode2.childNodes.first!
				var collisions = [SCNHitTestResult]()
				var results = [String]()
				if locationNode1.annotation.title == locationNode2.annotation.title {
					// If collision, start over because movement could cause additional collisions
					if hasCollision {
						hasCollision = false
						i = 0
						continue
					}
					break
				}
				
				let rootNode = sceneLocationView.scene.rootNode
				let node2Position = node2.worldPosition
				print("Ray from:", node2Position)
				collisions = rootNode.hitTestWithSegment(from: SCNVector3(x: 0, y: 0, z: 0), to: node2Position, options: options)
				results = (collisions.map({ $0.node.parent }) as! [MNLocationAnnotationNode]).map({ $0.annotation.title! })
				
				print("\t\(locationNode2.annotation.title!) ->", results)
				
				if results.contains(locationNode1.annotation.title!) {
					let dy = node1.worldPosition.distance(to: SCNVector3(x: 0, y: 0, z: 0)) * 0.3
					node1.transform = SCNMatrix4Mult(node1.transform, SCNMatrix4MakeTranslation(0, dy, 0))
					print("COLLISSION! New position of \(locationNode1.annotation.title!):", node1.worldPosition.description)
					hasCollision = true
				}
				i += 1
				
//				if results.filter({$0 != locationNode1.annotation.title!}).count > 0 {
//					let dy = node1.worldPosition.distance(to: SCNVector3(x: 0, y: 0, z: 0)) * 0.1
//					node1.transform = SCNMatrix4Mult(node1.transform, SCNMatrix4MakeTranslation(0, dy, 0))
//					hasCollision = true
//					continue
//				} else {
//					hasCollision = false
//				}
			}
		}
	}
	
	func stackAnnotation_V2() {
		guard self.sceneLocationView.locationNodes.count > 0 else { return }
		
		let locationNodes = self.sceneLocationView.locationNodes as! [MNLocationAnnotationNode]
		
		for locationNode1 in locationNodes {
			let node1 = locationNode1.childNodes.first!
			let spherical1 = node1.worldPosition.toSphericalCoordinates()
			print(locationNode1.annotation.title!, node1.position.description,
				  node1.worldPosition.description, spherical1.description)
			
			var hasCollision = false
			var i = 0
			let count = locationNodes.count
			while i < count {
				let locationNode2 = locationNodes[i]
				//                let node2 = locationNode2.childNodes.first!
				//                let spherical2 = node2.worldPosition.toSphericalCoordinates()
				//                let deltaPhi = abs(spherical1.phi - spherical2.phi)
				//                let deltaTheta = abs(spherical1.theta - spherical2.theta)
				
				if locationNode1.annotation.title == locationNode2.annotation.title {
					// If collision, start over because movement could cause additional collisions
					if hasCollision {
						hasCollision = false
						i = 0
						continue
					}
					break
				}
				//                let distance = horizontalDistanceBetween(pointA: node2.worldPosition, pointB: node1.worldPosition)
//				 let verticalDistance = sqrt(pow(node1.worldPosition.y - node2.worldPosition.y, 2)
//					+ pow(node1.worldPosition.z - node2.worldPosition.z, 2))
				// let verticalDistance = abs((node2.worldPosition.y  - node1.worldPosition.y) / node1.worldPosition.z)
//				let d1 = (node1.presentation.boundingBox.max.y - node1.presentation.boundingBox.min.y) * node1.scale.y
//				let d2 = (node2.presentation.boundingBox.max.y - node2.presentation.boundingBox.min.y) * node2.scale.y
//				let deltaY = abs(node1.worldPosition.y - node2.worldPosition.y)

				let options = [
					SCNHitTestOption.backFaceCulling.rawValue: false,
					SCNHitTestOption.firstFoundOnly.rawValue: false,
					SCNHitTestOption.ignoreChildNodes.rawValue: false,
					SCNHitTestOption.clipToZRange.rawValue: false,
					SCNHitTestOption.ignoreHiddenNodes.rawValue: false
				]
				let rootNode = sceneLocationView.scene.rootNode
				let collision = rootNode.hitTestWithSegment(
					from: sceneLocationView.pointOfView!.worldPosition,
					to: node1.worldPosition,
					options: options)
				for hit in collision {
					if let hitnode = hit.node.parent as? MNLocationAnnotationNode {
						// print("\t\(hitnode.annotation.title!) \(hitnode.position)")
						if hitnode.annotation.title == locationNode2.annotation.title {
							let dy = node1.worldPosition.distance(to: SCNVector3(x: 0, y: 0, z: 0)) * 1
							node1.transform = SCNMatrix4Mult(node1.transform, SCNMatrix4MakeTranslation(0, dy, 0))
							hasCollision = true
							break
						}
					}
				}
				
				//                if distance < 70 && deltaY <= 0.55 * abs(d1 + d2) {
				//                    let dy = node1.worldPosition.distance(to: SCNVector3(x: 0, y: 0, z: 0)) * 0.05
				//                    node1.transform = SCNMatrix4Mult(node1.transform, SCNMatrix4MakeTranslation(0, dy, 0))
				//                    hasCollision = true
				//                }
				i += 1
			}
		}
	}
	
	func stackAnnotation() {
		guard self.sceneLocationView.locationNodes.count > 0 else { return }
        guard let userLocation = sceneLocationView.currentScenePosition else { return }
		
		var worldPos1 = SCNVector3()
		var worldPos2 = SCNVector3()
		
		let locationNodes = self.sceneLocationView.locationNodes as! [MNLocationAnnotationNode]
		let sortedLocationNodes = locationNodes.sorted(by: {
			$0.annotation.distanceFromUser > $1.annotation.distanceFromUser
		})
		//        let sortedLocationNodes = locationNodes.sorted(by: {$0.worldPosition.y > $1.worldPosition.y})
		
		for locationNode1 in sortedLocationNodes {
			// Dectecting collision
			let node1 = locationNode1.childNodes.first!
			worldPos1 = node1.worldPosition
			let d1 = horizontalDistanceBetween(pointA: worldPos1, pointB: userLocation)
			let pos1 = node1.position
			var absolutePos1: SCNVector3 {
				return SCNVector3(x: worldPos1.x + pos1.x, y: worldPos1.y + pos1.y, z: worldPos1.z + pos1.z)
			}
			
			var hasCollision = false
			var i = 0
			while i < sortedLocationNodes.count {
				let locationNode2 = sortedLocationNodes[i]
				
				let node2 = locationNode2.childNodes.first!
				worldPos2 = node2.worldPosition
				let pos2 = node2.position
				var absolutePos2: SCNVector3 {
					return SCNVector3(x: worldPos2.x + pos2.x, y: worldPos2.y + pos2.y, z: worldPos2.z + pos2.z)
				}
				
				if SCNVector3EqualToVector3(worldPos1, worldPos2) {
					// If collision, start over because movement could cause additional collisions
					if hasCollision {
						hasCollision = false
						i = 0
						continue
					}
					break
				}
				
				let angleMax: CGFloat = 0.5
				let angle = angleBetweenTwoPointsAndUser(pointA: worldPos1, pointB: worldPos2)
				let deltaY = abs(absolutePos2.y - absolutePos1.y)
				
				if deltaY < 5 && angle < angleMax {
					// let d2 = horizontalDistanceBetween(pointA: worldPos2, pointB: userLocation)
					node1.position.y += node2.scale.y * 0.65
					hasCollision = true
				}
				i += 1
			}
		}
	}
	
	/// Calculate the angle between the user position and two points on the xz plane using the cosine
	/// c^2 = a^2 + b^2 - 2ab * cos(x) -> x = arccos[(a^2 + b^2 - c^2) / 2ab]
	func angleBetweenTwoPointsAndUser(pointA: SCNVector3, pointB: SCNVector3) -> CGFloat {
        if let userLocation = sceneLocationView.currentScenePosition {
			let A = CGPoint(x: CGFloat(pointA.x), y: CGFloat(pointA.z))
			let B = CGPoint(x: CGFloat(pointB.x), y: CGFloat(pointB.z))
			let U = CGPoint(x: CGFloat(userLocation.x), y: CGFloat(userLocation.z))
			
			let a = distanceBetween(A, U)
			let b = distanceBetween(B, U)
			let c = distanceBetween(A, B)
			return acos((a * a + b * b - c * c) / (2 * a * b))
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
	
	/// Calculate the distance between points A and B along the xy axis
	func horizontalDistanceBetween(pointA: SCNVector3, pointB: SCNVector3) -> CGFloat {
		let A = CGPoint(x: CGFloat(pointA.x), y: CGFloat(pointA.z))
		let B = CGPoint(x: CGFloat(pointB.x), y: CGFloat(pointB.z))
		
		return self.distanceBetween(A, B)
	}
}

extension SCNVector3 {
	var description: String {
		return "(x: \(x), y: \(y), z: \(z))"
	}
	
	func distance(vector: SCNVector3) -> Float {
		return sqrt(pow((self.x - vector.x), 2) + pow(self.y - vector.y, 2) + pow((self.z - vector.z), 2))
	}
	
	func toSphericalCoordinates() -> SphericalPoint {
		let rho = sqrt(pow(self.x, 2) + pow(self.y, 2) + pow(self.z, 2))
		let phi = atan(self.z / self.x)
		let theta = acos(self.y / rho)
		return SphericalPoint(rho: rho, phi: phi, theta: theta)
	}
}

struct SphericalPoint {
	var rho: Float
	var phi: Float
	var theta: Float
	
	var description: String {
		return "(rho: \(self.rho), phi: \(self.phi), theta: \(self.theta))"
	}
	
	init(rho: Float, phi: Float, theta: Float) {
		self.rho = rho
		self.phi = phi
		self.theta = theta
	}
	
	func toEulerCoordinates() -> SCNVector3 {
		let x = self.rho * cos(self.phi) * sin(self.theta)
		let z = self.rho * sin(self.phi) * sin(self.theta)
		let y = self.rho * cos(self.theta)
		return SCNVector3(x: x, y: y, z: z)
	}
}
