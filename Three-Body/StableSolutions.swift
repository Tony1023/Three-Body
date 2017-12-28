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
        stellarStates.append((ThreeVector(35,0,0), ThreeVector(0,-0.1,0)))
        stellarStates.append((ThreeVector(-35,0,0), ThreeVector(0,0.1,0)))
        states["Naive"] = stellarStates
        stellarStates = []
        stellarStates.append((ThreeVector(0,-40,0), ThreeVector(-0.2,0,0)))
        stellarStates.append((ThreeVector(-40*cos(Double.pi/6),20,0), ThreeVector(0.1,0.2*cos(Double.pi/6),0)))
        stellarStates.append((ThreeVector(40*cos(Double.pi/6),20,0), ThreeVector(0.1,-0.2*cos(Double.pi/6),0)))
        states["Standard"] = stellarStates
        stellarStates = []
        stellarStates.append((ThreeVector(5,-70,0), ThreeVector(0.1,-0.25,0)))
        stellarStates.append((ThreeVector(-5,-70,0), ThreeVector(0.1,0.25,0)))
        stellarStates.append((ThreeVector(0,80,0), ThreeVector(-0.1,0,0)))
        states["Sun-Earth-Moon System"] = stellarStates
        stellarStates = []
        stellarStates.append((ThreeVector(50,0,0), ThreeVector(0,-0.11,0)))
        stellarStates.append((ThreeVector(-50,0,0), ThreeVector(0,0.11,0)))
        stellarStates.append((ThreeVector(0,0,0), ThreeVector(0,0,0.4)))
        states["Axis Oscillation"] = stellarStates
        /*
        stellarStates = []
        stellarStates.append((ThreeVector(30,30,0), ThreeVector(0,0.1,0)))
        stellarStates.append((ThreeVector(-30,30,0), ThreeVector(0,-0.1,0)))
        stellarStates.append((ThreeVector(0,-60,0), ThreeVector(0.1,0,0)))
        states["8 Solution"] = stellarStates */
    }
    
    private var states: Dictionary<String, [InitialState]>
    
    var stableStates: Dictionary<String, [InitialState]> { return states }
}

let initialStates = StableStateGenerator()
