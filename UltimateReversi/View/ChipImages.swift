//
//  ChipImages.swift
//  UltimateReversi
//
//  Created by Bartosz on 18/06/2019.
//  Copyright © 2019 Bartosz Bilski. All rights reserved.
//

import UIKit

final class ChipImages {
    
    var cellImage: UIImage!
    var whiteChipWithLight: UIImage!
    var whiteCIChipWithLight: CIImage!
    var blackChipWithLight: UIImage!
    var blackCIChipWithLight: CIImage!
    private static let size = CGSize(width: 100, height: 100)
    private let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)

    private func chipWithLightColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(ChipImages.size, true, 0)
        
        var fillColor: UIColor
        
        if let patternImage = UIImage(named: Constants.cellBackgroundImage) {
            fillColor = UIColor(patternImage: patternImage)
        } else {
            fillColor = UIColor.red
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var components: [CGFloat]
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        let startColor: UIColor = ( color == UIColor.white ) ? UIColor.lightGray : UIColor.black
        if startColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) != true {
            fatalError("Can't convert color!")
        }
        components = [red, green, blue, alpha]
        
        let endColor: UIColor = ( color == UIColor.white ) ? UIColor.white : UIColor.lightGray
        if endColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) != true {
            fatalError("Can't convert color!")
        }
        components += [red, green, blue, alpha]
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let lightPoint = CGPoint(x: center.x + rect.width/10, y: center.y - rect.height/10)
        let locations: [CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 2)!
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(fillColor.cgColor)
            context.addRect(rect)
            context.drawPath(using: .fill)
            
            context.drawRadialGradient(gradient, startCenter: center, startRadius: rect.width/2, endCenter: lightPoint, endRadius: 0, options: .drawsAfterEndLocation)
            
            context.setStrokeColor(startColor.cgColor)
            context.addEllipse(in: rect)
            context.drawPath(using: .stroke)
        }
        
        let chip = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // MARK: To unwrap this safely
        return chip!
    }
    
    private func createCellImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(ChipImages.size, true, 0)
        let borderColor = UIColor.black
        var fillColor: UIColor
        if let paternImage = UIImage(named:
            Constants.cellBackgroundImage)
        {
            fillColor = UIColor(patternImage: paternImage)
        } else {
            fillColor = UIColor.green
        }
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(fillColor.cgColor)
            context.setStrokeColor(borderColor.cgColor)
            context.addRect(rect)
            context.drawPath(using: .fillStroke)
        }
        
        let cellImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return cellImage!
    }
    
    init() {
        cellImage = createCellImage()
        whiteChipWithLight = chipWithLightColor(color: .white)
        whiteCIChipWithLight = whiteChipWithLight.ciImage
        blackChipWithLight = chipWithLightColor(color: .black)
        blackCIChipWithLight = whiteChipWithLight.ciImage
    }
}
