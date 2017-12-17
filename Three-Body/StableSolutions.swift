//
//  StableSolutions.swift
//  Well, not really stable
//  Three-Body
//
//  Created by Tony Lyu on 08/12/2017.
//  Copyright © 2017 Tony. All rights reserved.
//

import Foundation

typealias InitialState = (InitialPosition: ThreeVector, InitalVelocity: ThreeVector)

struct StableStateGenerator
{
    init() {
        states = Dictionary<String, [InitialState]>()
        var stellarStates = [InitialState]()
        stellarStates.append((ThreeVector(50,0,0), ThreeVector(0,-0.1,0)))
        stellarStates.append((ThreeVector(-50,0,0), ThreeVector(0,0.1,0)))
        states["Naive"] = stellarStates
        stellarStates = []
        stellarStates.append((ThreeVector(0,-40,0), ThreeVector(-0.2,0,0)))
        stellarStates.append((ThreeVector(-40*cos(Double.pi/6),20,0), ThreeVector(0.1,0.2*cos(Double.pi/6),0)))
        stellarStates.append((ThreeVector(40*cos(Double.pi/6),20,0), ThreeVector(0.1,-0.2*cos(Double.pi/6),0)))
        states["Standard"] = stellarStates
        stellarStates = []
    }
    
    private var states: Dictionary<String, [InitialState]>
    
    var stableStates: Dictionary<String, [InitialState]> { return states }
}
