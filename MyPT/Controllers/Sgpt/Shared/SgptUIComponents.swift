//
//  SgptUIComponents.swift
//  MyPT
//
//  Small Group PT (SGPT) module's own reusable pieces - the ones with no
//  equivalent in GroupClassUIComponents.swift. Everything else the module
//  needs (GlassCardView, GlassCircularIconButton, PillChipView,
//  GradientCTAButton, GradientFadeView) is reused directly from there; see
//  SgptSessionDetailViewController for how those are configured to match
//  this module's own drawables.
//

import UIKit
import QuartzCore

// MARK: - SgptDiamondView

/// A tiny rotated-square "bullet" used to flank "Valid for N days" on the
/// pricing cards. Built as a real diamond path (not a rotated UIView) - a
/// rotated view's *layout* bounds stay axis-aligned even though it draws
/// rotated, so at this size (~4pt) it clips against tight-packed neighbours;
/// this was a confirmed bug on the Android build (`ic_diamond_bullet_4.xml`
/// exists there for the exact same reason) and is avoided here from the
/// start rather than hit and fixed later.
public class SgptDiamondView: UIView {

    public var diamondColor: UIColor = UIColor.white.withAlphaComponent(0.55) {
        didSet { shapeLayer.fillColor = diamondColor.cgColor }
    }

    private let shapeLayer = CAShapeLayer()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        shapeLayer.fillColor = diamondColor.cgColor
        layer.addSublayer(shapeLayer)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.midX, y: bounds.minY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.midY))
        path.close()
        shapeLayer.path = path.cgPath
    }

    public override var intrinsicContentSize: CGSize { CGSize(width: 4, height: 4) }
}

// MARK: - SgptGlassBorderView

/// A card background with a "glass" rim - bright along the top edge, fading
/// out by the bottom - built as a gradient-filled outer shape with a 1pt
/// inset solid-fill layer on top, so only a 1pt ring of the gradient shows.
/// (Android's `bg_pricing_card_side.xml`/`bg_pricing_countdown_box.xml` use
/// the identical two-layer trick, for the identical reason: neither platform
/// has a native gradient-stroke primitive on a plain rounded rect.) A flat
/// low-alpha stroke was tried first on Android and looked like nothing was
/// there at normal viewing size/compression - this needs real contrast
/// (bright end well above 50% white) to actually read, not a subtle hint.
public class SgptGlassBorderView: UIView {

    private let gradientLayer = CAGradientLayer()
    private let fillView = UIView()

    public var cornerRadius: CGFloat = 12 { didSet { setNeedsLayout() } }
    public var fillColor: UIColor = UIColor(hex: "#15111E") { didSet { fillView.backgroundColor = fillColor } }
    public var ringInset: CGFloat = 1 { didSet { setNeedsLayout() } }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        // Without this, the gradient (added straight to self.layer, sized
        // to full bounds) has sharp square corners and is never actually
        // confined to the card's own rounded shape - layer.cornerRadius
        // alone doesn't clip anything, only masksToBounds does. The ring
        // effect depends entirely on fillView covering everything except a
        // thin border, so an unclipped square gradient bled square corners
        // out past the rounded silhouette at all four corners.
        layer.masksToBounds = true
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.10).cgColor,
            UIColor.white.withAlphaComponent(0.65).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        layer.addSublayer(gradientLayer)

        fillView.backgroundColor = fillColor
        fillView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(fillView)

        NSLayoutConstraint.activate([
            fillView.topAnchor.constraint(equalTo: topAnchor, constant: ringInset),
            fillView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ringInset),
            fillView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ringInset),
            fillView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ringInset)
        ])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        layer.cornerRadius = cornerRadius
        fillView.layer.cornerRadius = max(cornerRadius - ringInset, 0)
        fillView.layer.masksToBounds = true
        CATransaction.commit()
    }

    /// Android's pricing cards are all ONE view swapping between
    /// `bg_pricing_card_center`/`_side` as the carousel's centered card
    /// changes on scroll - same view, different drawable. This is the iOS
    /// equivalent of that swap: the "center" look is a flat fill + a plain
    /// solid border with no ring at all (hide the gradient, since Android's
    /// center drawable has none), the "side" look is this view's normal
    /// glass ring.
    public func setPricingCardStyle(isCenter: Bool, centerFillColor: UIColor, sideFillColor: UIColor, centerBorderColor: UIColor) {
        // Radius is baked into Android's two drawables too (32dp center,
        // 29dp side) - swapping the "drawable" means swapping this as well.
        cornerRadius = isCenter ? 32 : 29
        gradientLayer.isHidden = isCenter
        fillColor = isCenter ? centerFillColor : sideFillColor
        layer.borderWidth = isCenter ? 2 : 0
        layer.borderColor = isCenter ? centerBorderColor.cgColor : nil
    }
}

// MARK: - SgptSeatsProgressView

/// The "Group seats available" beaded progress rail: a fixed row of
/// decorative dots behind a growing filled capsule with a glowing puck at
/// its leading edge.
///
/// Android's asset (`bg_seats_dot`/`bg_seats_track`/`bg_seats_fill_capsule`/
/// `bg_seats_fill_puck`) always shows 15 dots regardless of seat count - the
/// dots are purely decorative, not "one per seat" - confirmed by reading the
/// raw exported SVG. `setProgress` sizes the fill/puck; the dot count never
/// changes. (The module's shared `SpotProgressBarView` is a plain single bar
/// with no dots/puck, so it can't reproduce this asset - hence a dedicated
/// view here instead of reusing it.)
public class SgptSeatsProgressView: UIView {

    /// Matches Android's fixed 15-dot asset exactly - not derived from
    /// `maxSize`.
    public static let dotCount = 15

    private let trackLayer = CALayer()
    private var dotViews: [UIView] = []
    private let fillCapsule = UIView()
    private let puckContainer = UIView()
    private let puckGlowLayer = CAGradientLayer()
    private let puckCore = UIView()

    private var fillWidthConstraint: NSLayoutConstraint?
    private var puckLeadingConstraint: NSLayoutConstraint?

    /// Android's `seatsFillPuck` is a 26dp container so the glow has room to
    /// bloom instead of being clipped to the 14dp solid core.
    private static let puckContainerSide: CGFloat = 26
    private static let puckCoreSide: CGFloat = 14
    private static let barHeight: CGFloat = 14

    public private(set) var progress: CGFloat = 0

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear

        // Track: #715091, full-pill radius.
        trackLayer.backgroundColor = UIColor(hex: "#715091").cgColor
        layer.addSublayer(trackLayer)

        // 15 fixed decorative dots, #D8B8F5.
        for _ in 0..<SgptSeatsProgressView.dotCount {
            let dot = UIView()
            dot.backgroundColor = UIColor(hex: "#D8B8F5")
            dot.translatesAutoresizingMaskIntoConstraints = false
            addSubview(dot)
            dotViews.append(dot)
        }

        // Fill capsule: solid #B172EB + an inset stroke ring approximating
        // Android's `inset 0 0 8.286px #d288f9` glow (no native inset-shadow
        // primitive on either platform, so both fake it with a bright inset
        // ring).
        fillCapsule.translatesAutoresizingMaskIntoConstraints = false
        fillCapsule.backgroundColor = UIColor(hex: "#B172EB")
        fillCapsule.layer.borderWidth = 2
        fillCapsule.layer.borderColor = UIColor(hex: "#D288F9").withAlphaComponent(0.65).cgColor
        addSubview(fillCapsule)

        // Puck: radial white glow behind a solid white core with a ring.
        puckContainer.translatesAutoresizingMaskIntoConstraints = false
        puckContainer.backgroundColor = .clear
        addSubview(puckContainer)

        puckGlowLayer.type = .radial
        puckGlowLayer.colors = [UIColor.white.withAlphaComponent(0.7).cgColor,
                                UIColor.white.withAlphaComponent(0.0).cgColor]
        puckGlowLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        // A radial gradient's radius is the unit-space distance from start
        // to end point. (1.0, 1.0) measures to the CORNER (~0.707), so the
        // glow's true radius overshot the container's own half-width and
        // got hard-clipped at the view's edge instead of fading out inside
        // it - a visible harsh ring instead of a soft bloom. (1.0, 0.5)
        // measures to the edge midpoint (0.5, exactly half the width for
        // this square container), so it fades to transparent right at the
        // edge with no clipping.
        puckGlowLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        puckContainer.layer.addSublayer(puckGlowLayer)

        puckCore.backgroundColor = .white
        puckCore.layer.borderWidth = 1
        puckCore.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        puckCore.translatesAutoresizingMaskIntoConstraints = false
        puckContainer.addSubview(puckCore)

        NSLayoutConstraint.activate([
            puckCore.centerXAnchor.constraint(equalTo: puckContainer.centerXAnchor),
            puckCore.centerYAnchor.constraint(equalTo: puckContainer.centerYAnchor),
            puckCore.widthAnchor.constraint(equalToConstant: SgptSeatsProgressView.puckCoreSide),
            puckCore.heightAnchor.constraint(equalToConstant: SgptSeatsProgressView.puckCoreSide),
            puckContainer.widthAnchor.constraint(equalToConstant: SgptSeatsProgressView.puckContainerSide),
            puckContainer.heightAnchor.constraint(equalToConstant: SgptSeatsProgressView.puckContainerSide),
            puckContainer.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        let fillWidth = fillCapsule.widthAnchor.constraint(equalToConstant: 0)
        fillWidthConstraint = fillWidth
        let puckLeading = puckContainer.leadingAnchor.constraint(equalTo: leadingAnchor)
        puckLeadingConstraint = puckLeading

        NSLayoutConstraint.activate([
            fillCapsule.leadingAnchor.constraint(equalTo: leadingAnchor),
            fillCapsule.centerYAnchor.constraint(equalTo: centerYAnchor),
            fillCapsule.heightAnchor.constraint(equalToConstant: SgptSeatsProgressView.barHeight),
            fillWidth,
            puckLeading
        ])

        heightAnchor.constraint(equalToConstant: SgptSeatsProgressView.puckContainerSide).isActive = true
    }

    /// - Parameter progress: clamped to `0...1` (`bookedCount / maxSize`).
    public func setProgress(_ progress: CGFloat) {
        self.progress = min(max(progress, 0), 1)
        setNeedsLayout()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        trackLayer.frame = CGRect(x: 0,
                                  y: (bounds.height - SgptSeatsProgressView.barHeight) / 2,
                                  width: bounds.width,
                                  height: SgptSeatsProgressView.barHeight)
        trackLayer.cornerRadius = SgptSeatsProgressView.barHeight / 2

        fillCapsule.layer.cornerRadius = SgptSeatsProgressView.barHeight / 2
        puckGlowLayer.frame = puckContainer.bounds
        puckCore.layer.cornerRadius = SgptSeatsProgressView.puckCoreSide / 2

        let fillWidth = bounds.width * progress
        fillWidthConstraint?.constant = fillWidth

        // Clamp the puck so it always stays fully on-screen at 0%/100%,
        // matching the Android translationX clamp in layoutSeatsProgress().
        let halfPuck = SgptSeatsProgressView.puckContainerSide / 2
        let rawCenter = fillWidth
        let clampedCenter = min(max(rawCenter, halfPuck), bounds.width - halfPuck)
        puckLeadingConstraint?.constant = clampedCenter - halfPuck

        CATransaction.commit()
        layoutDots()
    }

    private func layoutDots() {
        guard bounds.width > 0, !dotViews.isEmpty else { return }
        // Evenly spaced across the track, matching the asset's fixed pitch.
        // Android's bg_seats_dot is a 10dp circle (its own comment: "5px
        // radius at the asset's native 360x14 scale") - this was 4pt,
        // rendering as faint specks instead of visible beaded dots.
        let dotSide: CGFloat = 10
        let usableWidth = bounds.width - dotSide
        let spacing = dotViews.count > 1 ? usableWidth / CGFloat(dotViews.count - 1) : 0
        for (index, dot) in dotViews.enumerated() {
            dot.frame = CGRect(x: spacing * CGFloat(index),
                               y: (bounds.height - dotSide) / 2,
                               width: dotSide,
                               height: dotSide)
            dot.layer.cornerRadius = dotSide / 2
        }
    }
}
