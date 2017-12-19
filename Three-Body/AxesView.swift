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
    private var endpoints: [(point: CGPoint, axis: Int)]?
    
    private lazy var origin: CGPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    
    private lazy var axisLength: CGFloat = self.bounds.midX * 0.8
    
    private let color = [UIColor.blue, UIColor.yellow, UIColor.red]
    
    //private let indexToAxis = ["x", "y", "z"]
    
    func draw(with endpoints: [(CGPoint, Int)]) {
        self.endpoints = endpoints
        for i in 0..<3 {
            self.endpoints![i].point *= axisLength
            self.endpoints![i].point += origin
        }
        setNeedsDisplay()
    }
    
    private func pathForAxis(with endpoint: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: origin)
        path.addLine(to: endpoint)
        path.lineWidth = 3
        return path
    }
    
    private func solidAtEndpoint(with endpoint: CGPoint) -> UIBezierPath{
        let path = UIBezierPath(arcCenter: endpoint, radius: 1.5, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        path.lineWidth = 3.5
        return path
    }
    
    override func draw(_ rect: CGRect) {
        if let endpoints = endpoints {
            for endpoint in endpoints {
                color[endpoint.axis].set()
                pathForAxis(with: endpoint.point).stroke()
                solidAtEndpoint(with: endpoint.point).stroke()
            }
        }
    }
}
