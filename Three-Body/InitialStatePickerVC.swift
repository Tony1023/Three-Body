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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC = segue.destination
        if let navigationC = destinationVC as? UINavigationController {
            if navigationC.visibleViewController != nil {
                destinationVC = navigationC.visibleViewController!
                destinationVC.navigationItem.backBarButtonItem?.title = "States"
            }
        }
        if let simulatorVC = destinationVC as? SimulatorViewController {
            simulatorVC.navigationItem.title = segue.identifier
            if let initialState = initialStates.stableStates[segue.identifier ?? ""] {
                for state in initialState {
                    simulatorVC.stellarBodies.append(StellarBody(position: state.InitialPosition, velocity: state.InitalVelocity))
                }
                StellarBody.centralize(simulatorVC.stellarBodies)
            }
        }
        if let randomSimulatorVC = destinationVC as? RandomSimulatorViewController {
            randomSimulatorVC.startNew()
        }
    }
}
