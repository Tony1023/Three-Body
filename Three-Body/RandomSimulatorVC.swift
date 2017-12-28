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
    private var escapeCheckerTimer: Timer?
    
    private var escaped = false {
        didSet {
            if escaped && !oldValue {
                navigationItem.title = "Escaped. Restarting in 3..."
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
                    self?.navigationItem.title = "Escaped. Restarting in 2..."
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
                        self?.navigationItem.title = "Escaped. Restarting in 1..."
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
                            self?.startNew()
                            self?.simulationIsOn = true
                        }
                    }
                }
            }
        }
    }
    
    override var simulationIsOn: Bool {
        set {
            if newValue == simulationIsOn { return }
            super.simulationIsOn = newValue
            if newValue && !escaped {
                escapeCheckerTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                    if self == nil { return }
                    if StellarBody.escaped(of: self!.stellarBodies) {
                        self!.escaped = true
                        self!.escapeCheckerTimer!.invalidate()
                    }
                }
            } else {
                escapeCheckerTimer?.invalidate()
            }
        }
        get {
            return super.simulationIsOn
        }
    }
    
    func startNew() {
        stellarBodies = []
        let numberOfStars = arc4random() % 3 + 3
        for _ in 0..<numberOfStars {
            stellarBodies.append(StellarBody(random: true))
        }
        StellarBody.centralize(super.stellarBodies)
        escaped = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        simulationIsOn = true
    }
    
    @IBAction func newCase(_ sender: UIBarButtonItem) {
        simulationSwitch.setTitle("Pause", for: .normal)
        startNew()
        simulationIsOn = true
    }
}
