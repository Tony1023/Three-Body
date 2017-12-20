//
//  ViewController.swift
//  Three-Body
//
//  Created by Tony Lyu on 07/12/2017.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit
class RandomSimulatorViewController: SimulatorViewController
{
    override func stellarBodies_willSetHelper() {}
    override func stellarBodies_didSetHelper() {}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        simulationIsOn = true
    }
    
    @IBAction func newCase(_ sender: UIButton) {
        simulationIsOn = false
        stellarBodies = []
        let numberOfStars = arc4random() % 3 + 3
        for _ in 0..<numberOfStars {
            stellarBodies.append(StellarBody(random: true))
        }
        StellarBody.centralize(super.stellarBodies)
        simulationIsOn = true
    }
}
