//
//  InitialStatePickerVC.swift
//  Three-Body
//
//  Created by Tony Lyu on 15/12/2017.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit

class InitialStatePickerVC: UIViewController
{
    private let initialStates = StableStateGenerator()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC = segue.destination
        if let navigationC = destinationVC as? UINavigationController {
            if navigationC.visibleViewController != nil {
                destinationVC = navigationC.visibleViewController!
            }
        }
        if let simulatorVC = destinationVC as? SimulatorViewController,
            let identifier = segue.identifier,
            let initialState = initialStates.stableStates[identifier] {
            for state in initialState {
                simulatorVC.stellarBodies.append(StellarBody(position: state.InitialPosition, velocity: state.InitalVelocity))
            }
            StellarBody.centralize(simulatorVC.stellarBodies)
        }
    }
}
