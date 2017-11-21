//
//  SCNVecto3+Extensions.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 23/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import SceneKit
import Foundation

extension SCNVector3 {
    ///Calculates distance between vectors
    ///Doesn't include the y axis, matches functionality of CLLocation 'distance' function.
    func distance(to anotherVector: SCNVector3) -> Float {
        return sqrt(pow(anotherVector.x - x, 2) + pow(anotherVector.z - z, 2))
    }
}

// Dot product
//public func * (left: SCNVector3, right: SCNVector3) -> Float {
//    return (left.x * right.x + left.y * right.y + left.z * right.z)
//}

// Cross product
//public func × (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
//    let x = left.y*right.z - left.z*right.y
//    let y = left.z*right.x - left.x*right.z
//    let z = left.x*right.y - left.y*right.x
//    
//    return SCNVector3(x: x, y: y, z: z)
//}

// Equality and equivalence
public func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
    return SCNVector3EqualToVector3(lhs, rhs)
}


// Scalar multiplication
public func *(left: SCNVector3, right: Float) -> SCNVector3 {
    let x = left.x * right
    let y = left.y * right
    let z = left.z * right
    
    return SCNVector3(x: x, y: y, z: z)
}

public func *(left: Float, right: SCNVector3) -> SCNVector3 {
    let x = right.x * left
    let y = right.y * left
    let z = right.z * left
    
    return SCNVector3(x: x, y: y, z: z)
}

public func *(left: SCNVector3, right: Int) -> SCNVector3 {
    return left * Float(right)
}

public func *(left: Int, right: SCNVector3) -> SCNVector3 {
    return Float(left) * right
}

public func *=( left: inout SCNVector3, right: Float) {
    left = left * right
}

public func *=( left: inout SCNVector3, right: Int) {
    left = left * right
}

// Scalar Division
public func /(left: SCNVector3, right: Float) -> SCNVector3 {
    let x = left.x / right
    let y = left.y / right
    let z = left.z / right
    
    return SCNVector3(x: x, y: y, z: z)
}

public func /(left: SCNVector3, right: Int) -> SCNVector3 {
    return left / Float(right)
}

public func /=( left: inout SCNVector3, right: Float) {
    left = left / right
}

public func /=( left: inout SCNVector3, right: Int) {
    left = left / right
}

// Vector subtraction
public func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    let x = left.x - right.x
    let y = left.y - right.y
    let z = left.z - right.z
    
    return SCNVector3(x: x, y: y, z: z)
}

public func -=( left: inout SCNVector3, right: SCNVector3) {
    left = left - right
}

// Vector addition
public func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    let x = left.x + right.x
    let y = left.y + right.y
    let z = left.z + right.z
    
    return SCNVector3(x: x, y: y, z: z)
}

public func +=( left: inout SCNVector3, right: SCNVector3) {
    left = left + right
}
