//
//  SVGPathIconView.swift
//  MyPT
//
//  A handful of icons in this session's Figma specs only ever came as raw
//  SVG `d` path data, not asset-catalog exports. Rather than hand-translate
//  each Bezier segment into UIBezierPath calls (error-prone, no way to
//  diff against the source), this parses the `d` string directly - the
//  exact same strings can be pasted in verbatim, same as Android's own
//  `android:pathData` (which IS SVG path syntax natively). Supports only
//  the commands these icons actually use - absolute M/L/H/V/C/Z - not a
//  general SVG parser.
//

import UIKit

extension UIBezierPath {

    convenience init(svgPathData d: String) {
        self.init()
        let scanner = Scanner(string: d)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: ", ")
        let letters = CharacterSet(charactersIn: "MLHVCZmlhvcz")

        var current = CGPoint.zero
        var command: Character = " "

        func nextDouble() -> CGFloat {
            CGFloat(scanner.scanDouble() ?? 0)
        }

        while !scanner.isAtEnd {
            if let letter = scanner.scanCharacters(from: letters) {
                command = letter.last!
            }
            switch command {
            case "M":
                current = CGPoint(x: nextDouble(), y: nextDouble())
                move(to: current)
                command = "L" // subsequent bare pairs after M are implicit linetos
            case "L":
                current = CGPoint(x: nextDouble(), y: nextDouble())
                addLine(to: current)
            case "H":
                current = CGPoint(x: nextDouble(), y: current.y)
                addLine(to: current)
            case "V":
                current = CGPoint(x: current.x, y: nextDouble())
                addLine(to: current)
            case "C":
                let c1 = CGPoint(x: nextDouble(), y: nextDouble())
                let c2 = CGPoint(x: nextDouble(), y: nextDouble())
                current = CGPoint(x: nextDouble(), y: nextDouble())
                addCurve(to: current, controlPoint1: c1, controlPoint2: c2)
            case "Z", "z":
                close()
            default:
                return
            }
        }
    }
}

/// Renders one or more SVG path strings (all sharing one `viewBox`) as a
/// stroked, non-filled icon - the shape every icon in this batch is (open
/// strokes, no fills). Sized entirely by Auto Layout constraints on this
/// view; the path is rescaled to fit in `layoutSubviews`.
final class SVGPathIconView: UIView {

    private let viewBoxSize: CGSize
    private let paths: [(data: String, lineWidth: CGFloat)]
    private let shapeLayers: [CAShapeLayer]

    init(viewBoxSize: CGSize, paths: [(data: String, lineWidth: CGFloat)], strokeColor: UIColor) {
        self.viewBoxSize = viewBoxSize
        self.paths = paths
        self.shapeLayers = paths.map { _ in
            let layer = CAShapeLayer()
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = strokeColor.cgColor
            layer.lineCap = .round
            layer.lineJoin = .round
            return layer
        }
        super.init(frame: .zero)
        backgroundColor = .clear
        shapeLayers.forEach { layer.addSublayer($0) }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setStrokeColor(_ color: UIColor) {
        shapeLayers.forEach { $0.strokeColor = color.cgColor }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0 else { return }
        let scaleX = bounds.width / viewBoxSize.width
        let scaleY = bounds.height / viewBoxSize.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)

        for (index, entry) in paths.enumerated() {
            let bezier = UIBezierPath(svgPathData: entry.data)
            bezier.apply(transform)
            let shapeLayer = shapeLayers[index]
            shapeLayer.frame = bounds
            shapeLayer.path = bezier.cgPath
            shapeLayer.lineWidth = entry.lineWidth * ((scaleX + scaleY) / 2)
        }
    }
}

// MARK: - Notification-screen icon glyphs (exact `d` strings from the design spec)

enum NotifIcon {

    static func timer(strokeColor: UIColor = .white) -> SVGPathIconView {
        SVGPathIconView(viewBoxSize: CGSize(width: 18, height: 18), paths: [
            ("M15.5625,9.9375C15.5625,13.56 12.6225,16.5 9,16.5C5.3775,16.5 2.4375,13.56 2.4375,9.9375C2.4375,6.315 5.3775,3.375 9,3.375C12.6225,3.375 15.5625,6.315 15.5625,9.9375Z", 1.6875),
            ("M9,6V9.75", 1.125),
            ("M6.75,1.5H11.25", 1.6875),
        ].map { (data: $0.0, lineWidth: $0.1) }, strokeColor: strokeColor)
    }

    static func close(strokeColor: UIColor = .white) -> SVGPathIconView {
        SVGPathIconView(viewBoxSize: CGSize(width: 18, height: 18), paths: [
            ("M13.5,4.5L4.5,13.5", 1.6875),
            ("M4.5,4.5L13.5,13.5", 1.6875),
        ].map { (data: $0.0, lineWidth: $0.1) }, strokeColor: strokeColor)
    }

    static func chevronRight(strokeColor: UIColor = .white) -> SVGPathIconView {
        SVGPathIconView(viewBoxSize: CGSize(width: 18, height: 18), paths: [
            ("M6.68262,14.9396L11.5726,10.0496C12.1501,9.47207 12.1501,8.52707 11.5726,7.94957L6.68262,3.05957", 1.6875),
        ], strokeColor: strokeColor)
    }

    static func bell(strokeColor: UIColor = .white) -> SVGPathIconView {
        SVGPathIconView(viewBoxSize: CGSize(width: 20, height: 20), paths: [
            ("M10,5.36621V8.14121", 1.25),
            ("M10.0166,1.66699C6.94992,1.66699 4.46658,4.15033 4.46658,7.21699V8.96699C4.46658,9.53366 4.23325,10.3837 3.94158,10.867L2.88325,12.6337C2.23325,13.7253 2.68325,14.942 3.88325,15.342C7.86658,16.667 12.1749,16.667 16.1582,15.342C17.2832,14.967 17.7666,13.6503 17.1582,12.6337L16.0999,10.867C15.8082,10.3837 15.5749,9.52533 15.5749,8.96699V7.21699C15.5666,4.16699 13.0666,1.66699 10.0166,1.66699Z", 1.25),
            ("M12.7751,15.6836C12.7751,17.2086 11.5251,18.4586 10.0001,18.4586C9.24176,18.4586 8.54176,18.1419 8.04176,17.6419C7.54176,17.1419 7.2251,16.4419 7.2251,15.6836", 1.25),
        ], strokeColor: strokeColor)
    }
}
