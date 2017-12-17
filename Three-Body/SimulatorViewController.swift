//
//  ViewController.swift
//  Three-Body
//
//  Created by Tony Lyu on 07/12/2017.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit

class SimulatorViewController: UIViewController, StellarCoordinateDelegate
{
    @IBOutlet weak var stellarView: StellarView!
    
    private weak var displayTimer: Timer?
    
    private var simulationRate: Double = SimulationRates.x1.rawValue
    
    private enum SimulationRates: Double {
        case x01 = 0.00005
        case x1 = 0.0000075
        case x5 = 0.000001
        case full = 0.0
    }
    
    private let simulationRater: Dictionary<String, SimulationRates> = [
        "×0.1": .x01,
        "×1": .x1,
        "×5": .x5,
        "Max": .full
    ]
    
    private var rotationMatrix = Matrix3x3([[1.0,0.0,0.0], [0.0,1.0,0.0], [0.0,0.0,1.0]]) {
        didSet {
            if !(displayTimer?.isValid ?? false), !stellarBodies.isEmpty {
                stellarView?.setNeedsDisplay()
            }
        }
    }
    
    var stellarBodies = [StellarBody] ()
    
    var simulationIsOn: Bool {
        set {
            if onDisplay == newValue { return }
            onDisplay = newValue
            if newValue {
                startSimulation()
                displayTimer = Timer.scheduledTimer(withTimeInterval: 0.0166, repeats: true) { [weak self] _ in
                    self?.stellarView?.setNeedsDisplay()
                }
            } else {
                displayTimer?.invalidate()
                displayTimer = nil
            }
        }
        get {
            return onDisplay
        }
    }
    
    private var onDisplay = false // To let another queue know whether to keep executing
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stellarView?.coordinateDelegate = self
        if !stellarBodies.isEmpty { simulationIsOn = true }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        simulationIsOn = false
    }
    
    private var positions: [ThreeVector]? {
        if stellarBodies.isEmpty { return nil }
        var positions = [ThreeVector](repeating: ThreeVector(), count: stellarBodies.count)
        for i in 0..<stellarBodies.count {
            positions[i] = stellarBodies[i].currentPosition
        }
        return positions
    }
    
    var coordinatesToDraw: [CGPoint]? {
        guard let positions = positions else { return nil }
        var coordinates = [CGPoint](repeating: CGPoint(x: 0, y: 0), count: positions.count)
        for body in 0..<positions.count {
            var x = 0.0, y = 0.0
            for i in 0..<3 {
                let components = positions[body].components
                x += rotationMatrix.elements[i][0] * components[i]
                y += rotationMatrix.elements[i][1] * components[i]
            }
            coordinates[body] = (CGPoint(x: x, y: y))
        }
        return coordinates
    }
    
    private func startSimulation() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            if self == nil { return }
            while self!.onDisplay {
                for i in 0..<self!.stellarBodies.count {
                    for j in 0..<self!.stellarBodies.count {
                        if i != j {
                            self!.stellarBodies[i].gravitate(towards: self!.stellarBodies[j])
                        }
                    }
                }
                for i in 0..<self!.stellarBodies.count { self!.stellarBodies[i].move() }
                Thread.sleep(forTimeInterval: self!.simulationRate)
            }
        }
    }
    
    @IBAction func addStellar(_ sender: UIButton, forEvent event: UIEvent) {
        simulationIsOn = false
        stellarBodies.append(StellarBody(random: true))
        simulationIsOn = true
    }
    
    @IBAction func simulationSwitch(_ sender: UIButton) {
        if simulationIsOn {
            simulationIsOn = false
            sender.setTitle("Resume", for: .normal)
        } else {
            simulationIsOn = true
            sender.setTitle("Pause", for: .normal)
        }
    }
    
    @IBAction func rateSwitch(_ sender: UISegmentedControl) {
        if let mode = sender.titleForSegment(at: sender.selectedSegmentIndex) {
            if let rate = simulationRater[mode]?.rawValue {
                simulationRate = rate
            }
        }
    }
    
    @IBAction func changeScale(_ pinch: UIPinchGestureRecognizer) {
        switch pinch.state {
        case .changed, .ended:
            stellarView?.scale *= pinch.scale
            pinch.scale = 1
        default:
            break
        }
    }
    
    @IBAction func rotate(_ pan: UIPanGestureRecognizer) {
        func rotate(with matrix: Matrix3x3) { rotationMatrix *= matrix }
        switch pan.state {
        case .changed, .ended:
            let translation = pan.translation(in: stellarView)
            rotate(with: RotationalMatrices.horizontal(by: Double(translation.x) / 100))
            rotate(with: RotationalMatrices.vertical(by: Double(-translation.y) / 100))
            pan.setTranslation(CGPoint.zero, in: stellarView)
        default:
            break
        }
    }
    
    @IBAction func rotate2(_ rotator: UIRotationGestureRecognizer) {
        func rotate(with matrix: Matrix3x3) { rotationMatrix *= matrix }
        switch rotator.state {
        case .changed, .ended:
            let rotation = rotator.rotation
            rotate(with: RotationalMatrices.perpendicular(by: -Double(rotation)))
            rotator.rotation = 0.0
        default:
            break
        }
    }
    
    @IBAction func centralize(_ sender: UITapGestureRecognizer) {
        StellarBody.centralize(stellarBodies)
    }

}

