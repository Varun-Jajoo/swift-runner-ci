//
//  PolygonChartDraw.swift
//  MyPT
//
//  Created by techsaga corp on 14/01/25.
//

import UIKit

struct PolygonChartDraw {
    var radius: CGFloat?
    
    var fillColor       : CGColor       = UIColor.clear.cgColor
    var strokeColor     : CGColor       = UIColor.clear.cgColor
    
    var lineDashPattern : [NSNumber]?
    var lineWidth       : CGFloat       = 0
    
    var objectTextSet   : [String]?
    var objectColor     : UIColor       = UIColor.white
    var objectFont      : UIFont        = UIFont.systemFont(ofSize: 15, weight: .medium)
    
    var unitText        : String?
    var unitColor       : UIColor       = UIColor.yellow
    var unitFont        : UIFont        = UIFont.systemFont(ofSize: 12, weight: .regular)
    
    var isSkeleton      : Bool          = false
}

struct PolygonChartDrawSet {
    var drawSet: [PolygonChartDraw]?
}
