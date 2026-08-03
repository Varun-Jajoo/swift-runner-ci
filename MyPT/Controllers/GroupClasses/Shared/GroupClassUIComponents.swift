//
//  GroupClassUIComponents.swift
//  MyPT
//
//  Shared design-system primitives for the Group Classes module.
//  Every screen in the module builds on top of these; prefer extending a
//  component here over re-styling a bare UIView inside a controller.
//

import UIKit
import QuartzCore

// MARK: - Palette

/// Named colour slots for the Group Classes module.
///
/// Each case maps 1:1 onto a colorset in `Assets.xcassets/ColorS`. The `fallback`
/// exists because `UIColor(named:)` returns `nil` when a colorset is missing or a
/// snapshot/unit-test bundle is used — degrading to the right literal colour is
/// preferable to a silently black UI.
public enum GroupClassColor: String {

    case bg                 = "groupClassBg"
    case bg2                = "groupClassBg2"
    case bg3                = "groupClassBg3"
    case lime               = "groupClassLime"
    case gold               = "groupClassGold"
    case redStart           = "groupClassRedStart"
    case redEnd             = "groupClassRedEnd"
    case blue               = "groupClassBlue"
    case blueCardBg         = "groupClassBlueCardBg"
    case cardStroke         = "groupClassCardStroke"
    case premiumStart       = "groupClassPremiumStart"
    case premiumEnd         = "groupClassPremiumEnd"
    case premiumStroke      = "groupClassPremiumStroke"
    case progressGreenStart = "groupClassProgressGreenStart"
    case progressGreenEnd   = "groupClassProgressGreenEnd"
    case progressTrack      = "groupClassProgressTrack"

    private var fallback: UIColor {
        switch self {
        case .bg:                 return UIColor(hex: "#000A04")
        case .bg2:                return UIColor(hex: "#131416")
        case .bg3:                return UIColor(hex: "#101113")
        case .lime:               return UIColor(hex: "#E0FE08")
        case .gold:               return UIColor(hex: "#DB812E")
        case .redStart:           return UIColor(hex: "#EE4D37")
        case .redEnd:             return UIColor(hex: "#641300")
        case .blue:               return UIColor(hex: "#0865FE")
        case .blueCardBg:         return UIColor(hex: "#000814")
        case .cardStroke:         return UIColor(hex: "#FFCC33")
        case .premiumStart:       return UIColor(hex: "#FFFFFF")
        case .premiumEnd:         return UIColor(hex: "#EBD463")
        case .premiumStroke:      return UIColor(hex: "#FFEDA5")
        case .progressGreenStart: return UIColor(hex: "#B2CA01")
        case .progressGreenEnd:   return UIColor(hex: "#586400")
        case .progressTrack:      return UIColor.white.withAlphaComponent(0.2)
        }
    }

    public var color: UIColor {
        return UIColor(named: rawValue) ?? fallback
    }
}

// MARK: - GlassCardView

/// Translucent "glass" container: a very low alpha white fill, a low alpha white
/// hairline stroke, and a radial sheen sublayer that fakes a light source.
///
/// Set `gradientStrokeColors` to swap the flat hairline for a gradient stroke
/// (used by the highlighted / premium variants of the class cards).
public class GlassCardView: UIView {

    /// Radial (not linear) because the sheen has to fall off in every direction
    /// from a single hotspot; a linear ramp reads as a banded stripe at card size.
    private var sheenLayer: CAGradientLayer?

    public var cornerRadius: CGFloat = 16 { didSet { applyStyle() } }
    public var fillColor: UIColor = UIColor.white { didSet { applyStyle() } }
    public var fillAlpha: CGFloat = 0.06 { didSet { applyStyle() } }
    public var strokeColor: UIColor = UIColor.white { didSet { applyStyle() } }
    public var strokeAlpha: CGFloat = 0.12 { didSet { applyStyle() } }
    public var strokeWidth: CGFloat = 1.0 { didSet { applyStyle() } }

    /// Origin of the sheen hotspot. Defaults to `.topLeft` to match the module's
    /// convention of a light source above and to the left of every card.
    public var sheenOrigin: CAGradientPoint = .topLeft { didSet { rebuildSheen() } }
    public var sheenEdge: CAGradientPoint = .bottomRight { didSet { rebuildSheen() } }
    public var sheenColor: UIColor = UIColor.white { didSet { rebuildSheen() } }
    public var sheenAlpha: CGFloat = 0.10 { didSet { rebuildSheen() } }
    public var showsSheen: Bool = true { didSet { rebuildSheen() } }

    /// When non-nil the flat `strokeColor` hairline is replaced by a gradient
    /// stroke drawn with the shared `setGradientCellBorder(...)` helper.
    public var gradientStrokeColors: [UIColor]? { didSet { applyStyle(); setNeedsLayout() } }
    public var gradientStrokeStart: CGPoint = CGPoint(x: 0.5, y: 0.0)
    public var gradientStrokeEnd: CGPoint = CGPoint(x: 0.5, y: 1.0)

    public init(cornerRadius: CGFloat = 16) {
        super.init(frame: .zero)
        self.cornerRadius = cornerRadius
        commonInit()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        rebuildSheen()
        applyStyle()
    }

    /// One-call styling entry point for screens that configure cards in bulk.
    public func configure(cornerRadius: CGFloat? = nil,
                          fillAlpha: CGFloat? = nil,
                          strokeAlpha: CGFloat? = nil,
                          sheenAlpha: CGFloat? = nil,
                          gradientStrokeColors: [UIColor]? = nil) {
        if let cornerRadius = cornerRadius { self.cornerRadius = cornerRadius }
        if let fillAlpha = fillAlpha { self.fillAlpha = fillAlpha }
        if let strokeAlpha = strokeAlpha { self.strokeAlpha = strokeAlpha }
        if let sheenAlpha = sheenAlpha { self.sheenAlpha = sheenAlpha }
        self.gradientStrokeColors = gradientStrokeColors
    }

    private func rebuildSheen() {
        sheenLayer?.removeFromSuperlayer()
        sheenLayer = nil
        guard showsSheen else { return }

        let sheen = CAGradientLayer(start: sheenOrigin,
                                    end: sheenEdge,
                                    colors: [sheenColor.withAlphaComponent(sheenAlpha).cgColor,
                                             sheenColor.withAlphaComponent(0.0).cgColor],
                                    type: .radial)
        sheen.frame = bounds
        layer.insertSublayer(sheen, at: 0)
        sheenLayer = sheen
    }

    private func applyStyle() {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        backgroundColor = fillColor.withAlphaComponent(fillAlpha)

        if gradientStrokeColors == nil {
            layer.borderWidth = strokeWidth
            layer.borderColor = strokeColor.withAlphaComponent(strokeAlpha).cgColor
        } else {
            layer.borderWidth = 0
            layer.borderColor = UIColor.clear.cgColor
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        sheenLayer?.frame = bounds
        CATransaction.commit()

        if let colors = gradientStrokeColors, !colors.isEmpty {
            setGradientCellBorder(cornerRadius: cornerRadius,
                                  width: strokeWidth,
                                  colors: colors,
                                  startPoint: gradientStrokeStart,
                                  endPoint: gradientStrokeEnd)
        }
    }
}

// MARK: - GradientCTAButton

/// Primary call-to-action: a near-white gradient body sitting on a flat grey band
/// that peeks out along the bottom edge.
///
/// The band is a solid `#808080` layer rather than a `CALayer` drop shadow so it
/// stays crisp and identical on every device — the design calls for a hard-edged
/// "printed" offset, not a blur.
public class GradientCTAButton: UIButton {

    private let bandLayer = CALayer()
    private let bodyLayer = CAGradientLayer()

    public var cornerRadius: CGFloat = 8 { didSet { setNeedsLayout() } }
    /// Height of the grey band visible below the body.
    public var bandThickness: CGFloat = 3 { didSet { applyContentInsets(); setNeedsLayout() } }
    public var bandColor: UIColor = UIColor(hex: "#808080") { didSet { applyStyle() } }
    public var bodyStartColor: UIColor = UIColor(hex: "#FFFFFF") { didSet { applyStyle() } }
    public var bodyEndColor: UIColor = UIColor(hex: "#F0F0F0") { didSet { applyStyle() } }

    public convenience init(title: String?) {
        self.init(frame: .zero)
        configure(title: title)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        layer.insertSublayer(bandLayer, at: 0)
        layer.insertSublayer(bodyLayer, at: 1)
        bodyLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        bodyLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        bodyLayer.locations = [0, 1]

        setTitleColor(UIColor.black, for: .normal)
        titleLabel?.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
        applyContentInsets()
        applyStyle()
    }

    public func configure(title: String?,
                          font: UIFont? = nil,
                          titleColor: UIColor = .black,
                          bandThickness: CGFloat? = nil,
                          cornerRadius: CGFloat? = nil) {
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        if let font = font { titleLabel?.font = font }
        if let bandThickness = bandThickness { self.bandThickness = bandThickness }
        if let cornerRadius = cornerRadius { self.cornerRadius = cornerRadius }
    }

    private func applyContentInsets() {
        // Keeps the title optically centred inside the body rather than inside
        // the full control bounds (which include the band).
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: bandThickness, right: 0)
    }

    private func applyStyle() {
        bandLayer.backgroundColor = bandColor.cgColor
        bodyLayer.colors = [bodyStartColor.cgColor, bodyEndColor.cgColor]
        setNeedsLayout()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let bodyHeight = max(bounds.height - bandThickness, 0)
        bandLayer.frame = CGRect(x: 0, y: bandThickness, width: bounds.width, height: bodyHeight)
        bandLayer.cornerRadius = cornerRadius
        bodyLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bodyHeight)
        bodyLayer.cornerRadius = cornerRadius

        CATransaction.commit()
    }

    public override var isHighlighted: Bool {
        didSet {
            // Collapsing the band on touch reads as the button being pressed into
            // the surface, which is what the flat offset is standing in for.
            bodyLayer.opacity = isHighlighted ? 0.85 : 1.0
        }
    }
}

// MARK: - SpotProgressBarView

/// Availability state of a class, driving the fill colour of `SpotProgressBarView`.
public enum SpotAvailabilityState {
    case green
    case gold
    case red

    /// Left-to-right gradient stops for the filled portion of the bar.
    public var fillColors: [UIColor] {
        switch self {
        case .green: return [GroupClassColor.progressGreenStart.color,
                             GroupClassColor.progressGreenEnd.color]
        case .gold:  return [GroupClassColor.premiumEnd.color,
                             GroupClassColor.gold.color]
        case .red:   return [GroupClassColor.redStart.color,
                             GroupClassColor.redEnd.color]
        }
    }
}

/// Thin "spots left" progress bar. Track is white at 20% alpha; the fill colour is
/// driven by `SpotAvailabilityState` (green / gold / red).
public class SpotProgressBarView: UIView {

    private let trackLayer = CALayer()
    private let fillLayer = CAGradientLayer()

    public private(set) var progress: CGFloat = 0

    public var state: SpotAvailabilityState = .green {
        didSet { applyState() }
    }

    public var barHeight: CGFloat = 4 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    public var trackColor: UIColor = GroupClassColor.progressTrack.color {
        didSet { trackLayer.backgroundColor = trackColor.cgColor }
    }

    public init(barHeight: CGFloat = 4) {
        super.init(frame: .zero)
        self.barHeight = barHeight
        commonInit()
    }

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
        isUserInteractionEnabled = false

        trackLayer.backgroundColor = trackColor.cgColor
        layer.addSublayer(trackLayer)

        fillLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        fillLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        fillLayer.locations = [0, 1]
        layer.addSublayer(fillLayer)

        applyState()
    }

    /// - Parameter progress: clamped to `0...1`.
    public func setProgress(_ progress: CGFloat,
                            state: SpotAvailabilityState? = nil,
                            animated: Bool = false) {
        self.progress = min(max(progress, 0), 1)
        if let state = state { self.state = state }
        layoutFillLayer(animated: animated)
    }

    /// Escape hatch for one-off fills that do not map to an availability state.
    public func setFillColors(_ colors: [UIColor]) {
        fillLayer.colors = colors.map { $0.cgColor }
    }

    private func applyState() {
        setFillColors(state.fillColors)
    }

    private func layoutFillLayer(animated: Bool) {
        let radius = bounds.height / 2
        let target = CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height)

        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        if animated { CATransaction.setAnimationDuration(0.25) }
        fillLayer.frame = target
        fillLayer.cornerRadius = radius
        CATransaction.commit()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        trackLayer.frame = bounds
        trackLayer.cornerRadius = bounds.height / 2
        CATransaction.commit()
        layoutFillLayer(animated: false)
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: barHeight)
    }
}

// MARK: - PillChipView

/// Small glass pill used for metadata tags (level, duration, location, …).
public class PillChipView: UIView {

    public let titleLabel = UILabel()

    public var contentInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10) {
        didSet { applyInsets() }
    }

    public var fillColor: UIColor = UIColor.white.withAlphaComponent(0.08) {
        didSet { backgroundColor = fillColor }
    }

    public var strokeColor: UIColor = UIColor.white.withAlphaComponent(0.14) {
        didSet { layer.borderColor = strokeColor.cgColor }
    }

    public var text: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue; invalidateIntrinsicContentSize() }
    }

    private var insetConstraints: [NSLayoutConstraint] = []

    public convenience init(text: String?) {
        self.init(frame: .zero)
        self.text = text
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = fillColor
        layer.borderWidth = 1
        layer.borderColor = strokeColor.cgColor
        layer.masksToBounds = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        addSubview(titleLabel)

        insetConstraints = [
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.left),
            trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: contentInsets.right),
            bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: contentInsets.bottom)
        ]
        NSLayoutConstraint.activate(insetConstraints)
    }

    public func configure(text: String?,
                          font: UIFont? = nil,
                          textColor: UIColor = .white) {
        self.text = text
        if let font = font { titleLabel.font = font }
        titleLabel.textColor = textColor
    }

    private func applyInsets() {
        guard insetConstraints.count == 4 else { return }
        insetConstraints[0].constant = contentInsets.top
        insetConstraints[1].constant = contentInsets.left
        insetConstraints[2].constant = contentInsets.right
        insetConstraints[3].constant = contentInsets.bottom
        setNeedsLayout()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}

// MARK: - GlassCircularIconButton

/// Circular translucent icon button — the floating back / favourite / share
/// controls that sit on top of a hero image.
public class GlassCircularIconButton: UIButton {

    /// Radial rather than linear so the button reads as a dome from any angle;
    /// hero images sit behind it at arbitrary rotations across the module.
    private var sheenLayer: CAGradientLayer?

    public var diameter: CGFloat = 40 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    public var iconInset: CGFloat = 11 { didSet { applyIconInset() } }

    public var fillColor: UIColor = UIColor.white.withAlphaComponent(0.10) {
        didSet { backgroundColor = fillColor }
    }

    public var strokeColor: UIColor = UIColor.white.withAlphaComponent(0.16) {
        didSet { layer.borderColor = strokeColor.cgColor }
    }

    public var sheenColor: UIColor = UIColor.white { didSet { rebuildSheen() } }
    public var sheenAlpha: CGFloat = 0.18 { didSet { rebuildSheen() } }

    public convenience init(icon: UIImage?, diameter: CGFloat = 40) {
        self.init(frame: .zero)
        self.diameter = diameter
        configure(icon: icon)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = fillColor
        layer.borderWidth = 1
        layer.borderColor = strokeColor.cgColor
        layer.masksToBounds = true
        imageView?.contentMode = .scaleAspectFit
        applyIconInset()
        rebuildSheen()
    }

    public func configure(icon: UIImage?,
                          tintColor: UIColor = .white,
                          diameter: CGFloat? = nil) {
        if let diameter = diameter { self.diameter = diameter }
        setImage(icon?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.tintColor = tintColor
    }

    private func applyIconInset() {
        imageEdgeInsets = UIEdgeInsets(top: iconInset,
                                       left: iconInset,
                                       bottom: iconInset,
                                       right: iconInset)
    }

    private func rebuildSheen() {
        sheenLayer?.removeFromSuperlayer()
        let sheen = CAGradientLayer(start: .topLeft,
                                    end: .bottomRight,
                                    colors: [sheenColor.withAlphaComponent(sheenAlpha).cgColor,
                                             sheenColor.withAlphaComponent(0.0).cgColor],
                                    type: .radial)
        sheen.frame = bounds
        layer.insertSublayer(sheen, at: 0)
        sheenLayer = sheen
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        sheenLayer?.frame = bounds
        CATransaction.commit()
        layer.cornerRadius = bounds.height / 2
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: diameter, height: diameter)
    }
}

// MARK: - PremiumBadgeView

/// Small "Premium" badge: a white-to-gold gradient chip with a pale gold stroke.
public class PremiumBadgeView: UIView {

    public let titleLabel = UILabel()
    public let iconView = UIImageView()

    /// Diagonal top-left → bottom-right: the white stop has to land on the corner
    /// nearest the light source so the badge reads as a bevelled metal tag rather
    /// than a flat two-tone rectangle.
    private let gradientLayer = CAGradientLayer()

    public var cornerRadius: CGFloat = 6 { didSet { setNeedsLayout() } }
    public var contentInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8) {
        didSet { applyInsets() }
    }

    public var startColor: UIColor = GroupClassColor.premiumStart.color { didSet { applyStyle() } }
    public var endColor: UIColor = GroupClassColor.premiumEnd.color { didSet { applyStyle() } }
    public var strokeColor: UIColor = GroupClassColor.premiumStroke.color { didSet { applyStyle() } }

    public var text: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue; invalidateIntrinsicContentSize() }
    }

    private var insetConstraints: [NSLayoutConstraint] = []
    private var iconWidthConstraint: NSLayoutConstraint?
    private var iconSpacingConstraint: NSLayoutConstraint?

    public convenience init(text: String? = "Premium", icon: UIImage? = nil) {
        self.init(frame: .zero)
        configure(text: text, icon: icon)
    }

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
        layer.masksToBounds = true
        layer.borderWidth = 1

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.locations = [0, 1]
        layer.insertSublayer(gradientLayer, at: 0)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.bold.size(10.0, familyName: familyFunnelSans)
        // Dark ink: the fill is a light gradient, so white text would disappear.
        titleLabel.textColor = GroupClassColor.bg.color
        titleLabel.numberOfLines = 1
        addSubview(titleLabel)

        let iconWidth = iconView.widthAnchor.constraint(equalToConstant: 0)
        iconWidthConstraint = iconWidth
        let iconSpacing = titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 0)
        iconSpacingConstraint = iconSpacing

        insetConstraints = [
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.left),
            trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: contentInsets.right),
            bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: contentInsets.bottom)
        ]

        NSLayoutConstraint.activate(insetConstraints + [
            iconWidth,
            iconSpacing,
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor)
        ])

        applyStyle()
    }

    public func configure(text: String?,
                          icon: UIImage? = nil,
                          font: UIFont? = nil,
                          textColor: UIColor? = nil) {
        self.text = text
        iconView.image = icon
        iconWidthConstraint?.constant = (icon == nil) ? 0 : 10
        iconSpacingConstraint?.constant = (icon == nil) ? 0 : 4
        if let font = font { titleLabel.font = font }
        if let textColor = textColor { titleLabel.textColor = textColor }
        setNeedsLayout()
    }

    private func applyInsets() {
        guard insetConstraints.count == 4 else { return }
        insetConstraints[0].constant = contentInsets.top
        insetConstraints[1].constant = contentInsets.left
        insetConstraints[2].constant = contentInsets.right
        insetConstraints[3].constant = contentInsets.bottom
        setNeedsLayout()
    }

    private func applyStyle() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        layer.borderColor = strokeColor.cgColor
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        CATransaction.commit()
        layer.cornerRadius = cornerRadius
    }
}

// MARK: - GroupClassCheckboxView

/// Custom checkbox for the payment-method picker (Phase 7) and anywhere else the
/// module needs a checked/unchecked toggle. Android has no single drawable for
/// this — it swaps the view's background between two selector drawables:
///   - unchecked: `ic_custom_checkbox_unchecked.xml` — 20dp square, 7dp radius,
///     transparent fill, `#B3FFFFFF` (white @ 70%) 1.8dp stroke.
///   - checked: `ic_custom_checkbox_checked.xml` — a `layer-list` of a 20dp square
///     (7.8dp radius, transparent fill, lime 1.5dp stroke) plus a 10x10dp lime
///     fill inset 5dp on every side (4dp radius).
/// Reproduced here as one stateful view instead of two static assets, since the
/// state has to toggle at runtime and Android's own approach is already a
/// selector, not a bitmap.
public class GroupClassCheckboxView: UIView {

    private let innerFill = UIView()

    public var isChecked: Bool = false {
        didSet { applyState() }
    }

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
        layer.masksToBounds = true

        innerFill.translatesAutoresizingMaskIntoConstraints = false
        innerFill.backgroundColor = GroupClassColor.lime.color
        innerFill.layer.cornerRadius = 4
        innerFill.layer.masksToBounds = true
        addSubview(innerFill)

        NSLayoutConstraint.activate([
            innerFill.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            innerFill.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            innerFill.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            innerFill.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])

        applyState()
    }

    private func applyState() {
        if isChecked {
            layer.cornerRadius = 7.8
            layer.borderWidth = 1.5
            layer.borderColor = GroupClassColor.lime.color.cgColor
            innerFill.isHidden = false
        } else {
            layer.cornerRadius = 7
            layer.borderWidth = 1.8
            layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
            innerFill.isHidden = true
        }
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 20, height: 20)
    }
}
