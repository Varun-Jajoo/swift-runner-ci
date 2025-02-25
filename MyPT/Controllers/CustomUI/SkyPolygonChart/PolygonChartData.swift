//
//  PolygonChartData.swift
//  MyPT
//
//  Created by techsaga corp on 14/01/25.
//

import UIKit

struct PolygonChartData {
    var fillColor       : CGColor       = UIColor.clear.cgColor
    var strokeColor     : CGColor       = UIColor.clear.cgColor
    
    var lineDashPattern : [NSNumber]?
    var lineWidth       : CGFloat       = 0
    var isAnimate       : Bool          = false
    var values          : [Double]?
}

struct PolygonChartDataSet {
    var dataSet: [PolygonChartData]?
}

