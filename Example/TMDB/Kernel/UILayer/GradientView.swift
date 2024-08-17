//
//  GradientView.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 08.11.21.
//

import UIKit

open class GradientView: UIView {
    
    open override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    private var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    /// The direction of the gradient.
    public enum Direction: Int {
        /// The gradient is vertical.
        case vertical

        /// The gradient is horizontal
        case horizontal
    }
    
    /// The start point of the gradient when drawn in the layer’s coordinate space. Animatable.
    /// The start point corresponds to the first stop of the gradient. The point is defined in the unit coordinate space and is then mapped to the layer’s bounds rectangle when drawn.
    open var startPoint: CGPoint? {
        didSet {
            updateGradient()
        }
    }
    
    /// The end point of the gradient when drawn in the layer’s coordinate space. Animatable.
    ///
    /// The end point corresponds to the last stop of the gradient. The point is defined in the unit coordinate space and is then mapped to the layer’s bounds rectangle when drawn.
    open var endPoint: CGPoint? {
        didSet {
            updateGradient()
        }
    }
    
    
    /// An array of UIColor objects defining the color of each gradient stop. Animatable.
    ///
    /// Defaults to nil.
    open var colors: [UIColor]? {
        didSet {
            updateGradient()
        }
    }
    
    /// An optional array of CGFloat objects defining the location of each gradient stop. Animatable.
    ///
    /// The gradient stops are specified as values between 0 and 1. The values must be monotonically increasing. If nil, the stops are spread uniformly across the range. Defaults to nil.
    /// When rendered, the colors are mapped to the output color space before being interpolated.
    open var locations: [CGFloat]? {
        didSet {
            updateGradient()
        }
    }
    
    /// The direction of the gradient. The default is `.vertical`.
    open var gradientDirection: Direction = .vertical {
        didSet {
            updateGradient()
        }
    }
    
    open func updateGradient() {
        gradientLayer.colors = colors?.map({ $0.cgColor })
        gradientLayer.locations = locations?.map({ NSNumber(value: Float($0)) })
        gradientLayer.type = .axial
        switch gradientDirection {
        case .horizontal:
            gradientLayer.startPoint = startPoint ?? CGPoint(x: 0, y: 0.0)
            gradientLayer.endPoint = endPoint ?? CGPoint(x: 1.0, y: 0.0)
        case .vertical:
            gradientLayer.startPoint = startPoint ?? CGPoint(x: 0, y: 0.0)
            gradientLayer.endPoint = endPoint ?? CGPoint(x: 0.0, y: 1.0)
        }
    }
}
