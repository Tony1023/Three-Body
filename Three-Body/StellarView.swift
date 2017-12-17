//
//  SimulationView.swift
//  Three-Body
//
//  Created by Tony Lyu on 09/12/2017.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit

protocol StellarCoordinateDelegate
{
    var coordinatesToDraw: [CGPoint]? { get }
}

class StellarView: UIView
{
    var coordinateDelegate: StellarCoordinateDelegate?
    
    var scale: CGFloat = 1.0
    
    private let stellarImage = UIImage(named: "moon_180px")
    
    private let stellarSize = CGSize(width: 10, height: 10)
    
    override func draw(_ rect: CGRect) {
        if let coordinates = coordinateDelegate?.coordinatesToDraw {
            var stellarSubviews = self.subviews
            if stellarSubviews.count > coordinates.count {
                for view in coordinates.count..<stellarSubviews.count {
                    stellarSubviews[view].removeFromSuperview()
                }
            }
            for body in 0..<stellarSubviews.count {
                var newPt = coordinates[body] * scale
                newPt += CGPoint(x: bounds.width/2 - 5, y: bounds.height/2 - 5)
                stellarSubviews[body].frame.origin = newPt
            }
            if stellarSubviews.count < coordinates.count {
                for body in stellarSubviews.count..<coordinates.count {
                    let stellarView = UIImageView(image: stellarImage)
                    stellarView.frame.size = stellarSize
                    var newPt = coordinates[body] * scale
                    newPt += CGPoint(x: bounds.width/2 - 5, y: bounds.height/2 - 5)
                    stellarView.frame.origin = newPt
                    stellarView.contentMode = .scaleAspectFit
                    addSubview(stellarView)
                }
            }
        }
    }
}

extension CGPoint {
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    static func += (left: inout CGPoint, right: CGPoint) {
        left.x += right.x; left.y += right.y
    }
    static func *= (left: inout CGPoint, right: CGFloat) {
        left.x *= right; left.y *= right
    }
    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }
}
