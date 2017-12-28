//
//  CelestialBody.swift
//  Three-Body
//
//  Created by Tony Lyu on 07/12/2017.
//  Copyright © 2017 Tony. All rights reserved.
//

import Foundation

class StellarBody
{
    fileprivate var position = ThreeVector(0.0, 0.0, 0.0)
    fileprivate var velocity = ThreeVector(0.0, 0.0, 0.0)
    fileprivate var acceleration = ThreeVector(0.0, 0.0, 0.0)
    
    static let velocityToDisplacementScale = 0.02
    static let accelerationToVelocityScale = 0.04
    
    init(position: ThreeVector?, velocity: ThreeVector?) {
        if position != nil {
            self.position = position!
        }
        if velocity != nil {
            self.velocity = velocity!
        }
    }
    
    init(random: Bool) {
        if random {
            // Using spherical coordinates to generate vectors
            let p_Rho = Double.getNonNegativeRandom(below: 100)
            let p_Phi = Double.getNonNegativeRandom(below: Double.pi)
            let p_Theta = Double.getNonNegativeRandom(below: Double.pi * 2)
            position = ThreeVector(rho: p_Rho, phi: p_Phi, theta: p_Theta)
            let v_Rho = Double.getNonNegativeRandom(below: 0.1)
            let v_Phi = Double.getNonNegativeRandom(below: Double.pi)
            let v_Theta = Double.getNonNegativeRandom(below: Double.pi * 2)
            velocity = ThreeVector(rho: v_Rho, phi: v_Phi, theta: v_Theta)
        }
    }
    
    var currentPosition: ThreeVector { return position }
    
    func gravitate(towards body: StellarBody) {
        var newAcceleration = (body.position - position)
        let magnitude = newAcceleration.magnitude
        if magnitude > 1 { // if too close then reduce the acceleration
            newAcceleration /= (magnitude * magnitude * magnitude)
        }
        acceleration += newAcceleration
    }
    
    func move() {
        acceleration *= StellarBody.accelerationToVelocityScale
        velocity += acceleration
        acceleration.setToZero()
        position += (velocity * StellarBody.velocityToDisplacementScale)
    }
}

extension StellarBody {
    static func centralize(_ bodies: [StellarBody]) {
        let number = bodies.count
        var positionSum = ThreeVector()
        var velocitySum = ThreeVector()
        for i in 0..<number {
            positionSum += bodies[i].position
            velocitySum += bodies[i].velocity
        }
        positionSum /= Double(number)
        velocitySum /= Double(number)
        for i in 0..<number {
            bodies[i].position -= positionSum
            bodies[i].velocity -= velocitySum
        }
    }
    
    private func didEscape(from bodies: [StellarBody]) -> Bool {
        let kineticEnergy = velocity.magnituedSquared / 2.0
        var gravitationalPotentialEnergy = 0.0
        for body in bodies {
            if body.position == position { continue }
            gravitationalPotentialEnergy += 1.0 / (body.position - position).magnitude
        }
        return (kineticEnergy >= gravitationalPotentialEnergy)
    }
    
    static func escaped(of bodies: [StellarBody]) -> Bool {
        var escaped = false
        for body in bodies {
            escaped = body.didEscape(from: bodies) || escaped
        }
        return escaped
    }
    
}

struct ThreeVector
{
    var x: Double
    var y: Double
    var z: Double
    
    init() { x = 0.0; y = 0.0; z = 0.0 }
    
    init(_ x: Double, _ y: Double, _ z: Double) { self.x = x; self.y = y; self.z = z }
    
    init(rho: Double, phi: Double, theta: Double) {
        x = rho * sin(phi) * cos(theta)
        y = rho * sin(phi) * sin(theta)
        z = rho * cos(phi)
    }
    
    subscript (index: Int) -> Double {
        switch index {
        case 0:
            return x
        case 1:
            return y
        case 2:
            return z
        default:
            return Double.nan
        }
    }
    
    static func - (left: ThreeVector, right: ThreeVector) -> ThreeVector {
        return ThreeVector(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    
    static func -= (left: inout ThreeVector, right: ThreeVector) {
        left.x -= right.x; left.y -= right.y; left.z -= right.z
    }
    
    static func += (left: inout ThreeVector, right: ThreeVector) {
        left.x += right.x; left.y += right.y; left.z += right.z
    }
    
    static func * (vector: ThreeVector, scale: Double) -> ThreeVector {
        return ThreeVector(vector.x * scale, vector.y * scale, vector.z * scale)
    }
    
    static func *= (vector: inout ThreeVector, scale: Double) {
        vector.x *= scale; vector.y *= scale; vector.z *= scale
    }
    
    static func /= (vector: inout ThreeVector, scale: Double) {
        vector.x /= scale; vector.y /= scale; vector.z /= scale
    }
    
    static func == (left: ThreeVector, right: ThreeVector) -> Bool {
        return (left.x == right.x && left.y == right.y && left.z == right.z)
    }
    
    mutating func setToZero() { x = 0.0; y = 0.0; z = 0.0 }
    
    var magnituedSquared: Double { return (x*x + y*y + z*z) }
    var magnitude: Double { return sqrt(magnituedSquared) }
    var elements: [Double] { return [x,y,z] }
    
}

struct Matrix3x3
{
    init() {}
    
    init(_ matrix: [[Double]]) {
        elements = matrix
    }
    
    var elements = [[1.0,0.0,0.0], [0.0,1.0,0.0], [0.0,0.0,1.0]]
    
    static func * (left: Matrix3x3, right: Matrix3x3) -> Matrix3x3 {
        var result = [[0.0,0.0,0.0], [0.0,0.0,0.0], [0.0,0.0,0.0]]
        for i in 0..<3 {
            for j in 0..<3 {
                for k in 0..<3 {
                    result[i][j] += left.elements[i][k] * right.elements[k][j]
                }
            }
        }
        return Matrix3x3(result)
    }
    
    static func *= (left: inout Matrix3x3, right: Matrix3x3) {
        left = left * right
    }
}

struct RotationalMatrices
{
    static func vertical(by angle: Double) -> Matrix3x3 {
        return Matrix3x3([[1.0, 0.0, 0.0],
                          [0, cos(angle), sin(angle)],
                          [0, -sin(angle), cos(angle)]])
    }
    static func horizontal(by angle: Double) -> Matrix3x3 {
        return Matrix3x3([[cos(angle), 0.0, -sin(angle)],
                          [0.0, 1.0, 0.0],
                          [sin(angle), 0, cos(angle)]])
    }
    static func perpendicular(by angle: Double) -> Matrix3x3 {
        return Matrix3x3([[cos(angle), -sin(angle), 0],
                          [sin(angle), cos(angle), 0],
                          [0, 0, 1]])
    }
}

extension Double {
    static func getNonNegativeRandom(below maxValue: Double) -> Double {
        let random = Double(arc4random()) / 0xFFFFFFFF
        return random * maxValue
    }
}
