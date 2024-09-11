//
//  DotOfTimeLineHistorialTransitoShape.swift
//  Urbano
//
//  Created by Mick VE on 14/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class DotOfTimeLineHistorialTransitoShape: UIView {
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        //self.backgroundColor = nil
        // Drawing code
        //6
        /*ctx.setLineWidth(30)
        
        let x:CGFloat = center.x
        let y:CGFloat = center.y
        let radius: CGFloat = 10.0
        let endAngle: CGFloat = CGFloat(2 * Double.pi)
        
        ctx.addArc(center: CGPoint(x: x,y: y), radius: radius, startAngle: 0, endAngle: endAngle, clockwise: true)
 */
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        //ctx.clear(CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        ctx.beginPath()
        
        var color = UIColor(red: CGFloat(111/255.0), green: CGFloat(112/255.0), blue: CGFloat(115/255.0), alpha: CGFloat(0.3))
        var rectangle = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        ctx.setFillColor(color.cgColor)
        ctx.addEllipse(in: rectangle)
        ctx.fillPath()
        
        var size = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        var position = CGPoint(x: size.x / 2.0, y: size.y / 2.0)
        color = UIColor(red: CGFloat(111/255.0), green: CGFloat(112/255.0), blue: CGFloat(115/255.0), alpha: CGFloat(1))
        rectangle = CGRect(x: position.x, y: position.y, width: size.x, height: size.y)
        ctx.setFillColor(color.cgColor)
        ctx.addEllipse(in: rectangle)
        ctx.fillPath()
        
        size = CGPoint(x: size.x / 2.0, y: size.y / 2.0)
        position = CGPoint(x: self.frame.size.width / 2.0 - size.x / 2.0, y: self.frame.size.height / 2.0 - size.y / 2.0)
        color = UIColor(red: CGFloat(255/255.0), green: CGFloat(255/255.0), blue: CGFloat(255/255.0), alpha: CGFloat(1))
        rectangle = CGRect(x: position.x, y: position.y, width: size.x, height: size.y)
        ctx.setFillColor(color.cgColor)
        ctx.addEllipse(in: rectangle)
        ctx.fillPath()
    }

}
