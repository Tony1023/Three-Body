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
    @IBOutlet weak var stellarView: StellarView! { didSet { stellarView.coordinateDelegate = self } }
    
    @IBOutlet weak var simulationSwitch: UIButton!
    
    @IBOutlet weak var axesView: AxesView!
    
    private weak var displayTimer: Timer?
    
    private weak var escapeCheckerTimer: Timer?
    
    @IBOutlet weak var resetButton: UIBarButtonItem!
    
    private var simulationRate = SimulationRates.x1.rawValue
    
    private enum SimulationRates: Double {
        case x001 = 0.0005
        case x01 = 0.00005
        case x1 = 0.0000075
        case x5 = 0.000001
        case full = 0.0
    }
    
    private let simulationRater: Dictionary<String, SimulationRates> = [
        "×0.01": .x001,
        "×0.1": .x01,
        "×1": .x1,
        "×5": .x5,
        "Max": .full
    ]
    
    private var rotationMatrix = Matrix3x3() {
        didSet {
            if !simulationIsOn && !stellarBodies.isEmpty {
                // When the simulation is paused/not started AND there are some stellar bodies to display
                stellarView.setNeedsDisplay()
            }
            axesView.draw(with: axesEndpoints)
        }
    }
    
    var stellarBodies = [StellarBody] () {
        willSet { simulationIsOn = false }
        didSet { stellarView?.setNeedsDisplay() }
    }
    
    var simulationIsOn: Bool { // Setting it from false to true fires dispatches a queue and fires the timer
        set {
            if onDisplay == newValue { return }
            onDisplay = newValue
            if newValue {
                startSimulation()
                displayTimer = Timer.scheduledTimer(withTimeInterval: 0.0166, repeats: true) { [weak self] _ in
                    self?.stellarView?.setNeedsDisplay()
                }
                simulationSwitch.setTitle("Pause", for: .normal)
            } else {
                displayTimer?.invalidate()
                displayTimer = nil
                simulationSwitch.setTitle("Resume", for: .normal)
                repeat { /* Wait for the other queue to end */ } while !executionEnded
            }
        }
        get {
            return onDisplay
        }
    }
    
    private var onDisplay = false // To let another queue know whether to keep executing
    
    private var executionEnded = true // To flag whether the other queue has ended
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        axesView.draw(with: axesEndpoints)
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
        var coordinates = [CGPoint](repeating: CGPoint(), count: positions.count)
        for body in 0..<positions.count {
            var x = 0.0, y = 0.0
            for i in 0..<3 {
                x += rotationMatrix.elements[i][0] * positions[body][i]
                y += rotationMatrix.elements[i][1] * positions[body][i]
            }
            coordinates[body] = CGPoint(x: x, y: y)
        }
        return coordinates
    }
    
    private var axesEndpoints: [(CGPoint, Int)] {
        var coordinates = [(point: CGPoint, depth: Double, axis: Int)] (repeating: (CGPoint.zero, 0.0, 0), count: 3)
        let positions = Matrix3x3().elements
        for axis in 0..<3 {
            var x = 0.0, y = 0.0, z = 0.0
            for i in 0..<3 {
                x += rotationMatrix.elements[i][0] * positions[axis][i]
                y += rotationMatrix.elements[i][1] * positions[axis][i]
                z += rotationMatrix.elements[i][2] * positions[axis][i]
            }
            coordinates[axis] = (CGPoint(x: x, y: y), z, axis)
        }
        // Insertion sort?
        if coordinates[0].depth > coordinates[1].depth {
            swap(&coordinates[0], &coordinates[1])
        }
        if coordinates[1].depth > coordinates[2].depth {
            swap(&coordinates[1], &coordinates[2])
            if coordinates[0].depth > coordinates[1].depth {
                swap(&coordinates[0], &coordinates[1])
            }
        }
        var endpoints = [(CGPoint, Int)]()
        for item in coordinates {
            endpoints.append((item.point, item.axis))
        }
        return endpoints
    }
    
    private func startSimulation() {
        executionEnded = false
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
                for i in 0..<self!.stellarBodies.count {
                    self!.stellarBodies[i].move()
                }
                Thread.sleep(forTimeInterval: self!.simulationRate)
            }
            self!.executionEnded = true
        }
    }
    
    @IBAction func addStellar(_ sender: UIButton, forEvent event: UIEvent) {
        stellarBodies.append(StellarBody(random: true))
    }
    
    @IBAction func restart(_ sender: UIBarButtonItem) {
        stellarBodies = []
        if let initialStates = initialStates.stableStates[navigationItem.title ?? ""] {
            for state in initialStates {
                stellarBodies.append(StellarBody(position: state.InitialPosition, velocity: state.InitalVelocity))
            }
        }
        simulationSwitch.setTitle("Start", for: .normal)
        resetButton.isEnabled = false
    }
    
    @IBAction func simulationSwitch(_ sender: UIButton) {
        if simulationIsOn {
            simulationIsOn = false
        } else if !stellarBodies.isEmpty {
            simulationIsOn = true
            if !resetButton.isEnabled { resetButton.isEnabled = true }
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
            stellarView.scale *= pinch.scale
            pinch.scale = 1
        default:
            break
        }
    }
    
    @IBAction func rotate(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .changed, .ended:
            let translation = pan.translation(in: stellarView)
            var rotator = Matrix3x3()
            rotator *= RotationalMatrices.horizontal(by: Double(translation.x) / 100)
            rotator *= RotationalMatrices.vertical(by: Double(-translation.y) / 100)
            rotationMatrix *= rotator
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
        if !simulationIsOn { stellarView.setNeedsDisplay() }
    }

    @IBAction func resetAxes(_ sender: UITapGestureRecognizer) {
        rotationMatrix = Matrix3x3()
    }
}

