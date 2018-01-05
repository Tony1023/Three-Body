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
    override var stellarBodies: [StellarBody] {
        willSet {
            simulationIsOn = false
        }
    }
    
    private var escapeCheckerTimer: Timer?
    
    private var currentCountdownTimer: Timer?
    
    private var countdown: Int?
    
    private var escaped = false {
        didSet {
            if escaped && !oldValue { beginRestartCountdown(from: 5) }
        }
    }
    
    private func beginRestartCountdown(from time: Int) {
        print("Function called at countdown = \(time)")
        if time <= 0 {
            startNew()
            simulationIsOn = true
        } else {
            navigationItem.title = "Escaped. Restarting in \(time)..."
            countdown = time
            if simulationIsOn {
                currentCountdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
                    self?.beginRestartCountdown(from: time - 1)
                }
            }
        }
    }
    
    private var helper_simulationIsOn = true
    
    override var simulationIsOn: Bool {
        set {
            if newValue == helper_simulationIsOn { return }
            helper_simulationIsOn = newValue
            super.simulationIsOn = newValue
            if newValue {
                escapeCheckerTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                    if self == nil { return }
                    if StellarBody.escaped(of: self!.stellarBodies) {
                        self!.escaped = true
                    }
                }
                if let time = countdown { beginRestartCountdown(from: time) }
            } else {
                escapeCheckerTimer?.invalidate()
                currentCountdownTimer?.invalidate()
            }
        }
        get {
            return helper_simulationIsOn
        }
    }
    
    func startNew() {
        print("Starting new case")
        stellarBodies = []
        let numberOfNewStars = 3
        for _ in 0..<numberOfNewStars {
            stellarBodies.append(StellarBody(random: true))
        }
        StellarBody.centralize(super.stellarBodies)
        escaped = false
        navigationItem.title = nil
        countdown = nil
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
