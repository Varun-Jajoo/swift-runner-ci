//
//  CenterRangeSliderDelegate.swift
//  MyPT
//
//  Created by techsaga corp on 13/01/25.
//

import CoreGraphics

public protocol CenterRangeSliderDelegate: AnyObject {

    /// Called when the RangeSeekSlider values are changed
    ///
    /// - Parameters:
    ///   - slider: RangeSeekSlider
    ///   - minValue: minimum value
    ///   - maxValue: maximum value
    func rangeSeekSlider(_ slider: CenterRangeSlider, didChange minValue: CGFloat, maxValue: CGFloat)

    /// Called when the user has started interacting with the RangeSeekSlider
    ///
    /// - Parameter slider: RangeSeekSlider
    func didStartTouches(in slider: CenterRangeSlider)

    /// Called when the user has finished interacting with the RangeSeekSlider
    ///
    /// - Parameter slider: RangeSeekSlider
    func didEndTouches(in slider: CenterRangeSlider)

    /// Called when the RangeSeekSlider values are changed. A return `String?` Value is displayed on the `minLabel`.
    ///
    /// - Parameters:
    ///   - slider: RangeSeekSlider
    ///   - minValue: minimum value
    /// - Returns: String to be replaced
    func rangeSeekSlider(_ slider: CenterRangeSlider, stringForMinValue minValue: CGFloat) -> String?

    /// Called when the RangeSeekSlider values are changed. A return `String?` Value is displayed on the `maxLabel`.
    ///
    /// - Parameters:
    ///   - slider: RangeSeekSlider
    ///   - maxValue: maximum value
    /// - Returns: String to be replaced
    func rangeSeekSlider(_ slider: CenterRangeSlider, stringForMaxValue: CGFloat) -> String?
}

// MARK: - Default implementation

public extension CenterRangeSliderDelegate {

    func rangeSeekSlider(_ slider: CenterRangeSlider, didChange minValue: CGFloat, maxValue: CGFloat) {}
    func didStartTouches(in slider: CenterRangeSlider) {}
    func didEndTouches(in slider: CenterRangeSlider) {}
    func rangeSeekSlider(_ slider: CenterRangeSlider, stringForMinValue minValue: CGFloat) -> String? { return nil }
    func rangeSeekSlider(_ slider: CenterRangeSlider, stringForMaxValue maxValue: CGFloat) -> String? { return nil }
}
