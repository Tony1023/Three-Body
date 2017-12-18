//
//  AxesView.swift
//  Three-Body
//
//  Created by Tony Lyu on 18/12/2017.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit

class AxesView: UIView
{
    private var endPoints: (x: CGPoint, y: CGPoint, z: CGPoint)?
    
    private lazy var origin: CGPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    
    func draw(with endPoints: (x: CGPoint, y: CGPoint, z: CGPoint)) {
        self.endPoints = endPoints
        setNeedsDisplay()
    }
    
    private func pathForXAxes() -> UIBezierPath {
        let path = UIBezierPath()
        guard let endPoints = endPoints else { return path }
        path.move(to: origin)
        path.addLine(to: endPoints.x * 20 + origin)
        return path
    }
    
    private func pathForYAxes() -> UIBezierPath {
        let path = UIBezierPath()
        guard let endPoints = endPoints else { return path }
        path.move(to: origin)
        path.addLine(to: endPoints.y * 20 + origin)
        return path
    }
    
    private func pathForZAxes() -> UIBezierPath {
        let path = UIBezierPath()
        guard let endPoints = endPoints else { return path }
        path.move(to: origin)
        path.addLine(to: endPoints.z * 20 + origin)
        return path
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.blue.set()
        pathForXAxes().stroke()
        UIColor.yellow.set()
        pathForYAxes().stroke()
        UIColor.red.set()
        pathForZAxes().stroke()
    }
}

// Try to draw them in top-down order, to show which axis comes on top
// Also a considered task for laying out stellar bodies
