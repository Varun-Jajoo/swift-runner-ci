//
//  SgptScrollDebug.swift
//  MyPT
//
//  TEMPORARY diagnostic for the "plan cards jump at the bottom of the pricing
//  scroll" bug. Not part of the feature - delete this file and the
//  SgptScrollDebug calls in SgptPricingViewController once the cause is found.
//
//  Records a timestamped trace of everything that could move the cards, shows
//  it on screen, and copies it to the pasteboard so it can be pasted into a
//  bug report. Exists because the bug is only reproducible on a device and a
//  screen recording was not available.
//
//  Turn off with `SgptScrollDebug.isEnabled = false`.
//

import UIKit

final class SgptScrollDebug {

    static let shared = SgptScrollDebug()

    /// Master switch. Set false to compile the overlay out of the UI entirely.
    static var isEnabled = true

    /// Bumped with every fix, and printed at the top of the trace, so a capture
    /// can never be misread as coming from a build it did not come from. Two
    /// identical traces from "before" and "after" a fix cost a whole round trip
    /// to notice otherwise.
    static let buildMarker = "constraint-dump probe"

    /// Whether the pricing scroll view is wired the way the fix intends.
    /// Reported at trace start: if this says NO on a build that should have the
    /// fix, the storyboard change did not reach the device.
    static func contentGuideStatus(_ scrollView: UIScrollView) -> String {
        guard let content = scrollView.subviews.first else { return "no content view" }

        // A constraint from the content to the scroll view's own bottom is the
        // broken wiring; to the contentLayoutGuide is the fixed one.
        let bottomToScrollView = scrollView.constraints.contains { c in
            (c.firstItem === scrollView && c.firstAttribute == .bottom && c.secondItem === content)
                || (c.secondItem === scrollView && c.secondAttribute == .bottom && c.firstItem === content)
        }

        return bottomToScrollView ? "BOTTOM PINNED TO SCROLL VIEW (unfixed)" : "bottom pinned to content guide (fixed)"
    }

    private var events: [String] = []
    private let maxEvents = 400
    private var start = CACurrentMediaTime()

    private weak var overlay: DebugOverlayView?

    private init() {}

    // MARK: - Recording

    func reset() {
        events.removeAll()
        start = CACurrentMediaTime()
        log("--- trace started ---")
        log("build: " + Self.buildMarker)
    }

    /// One line in the trace. `tag` groups related events so the dump is
    /// readable at a glance.
    func log(_ message: String) {
        guard Self.isEnabled else { return }

        let t = String(format: "%7.3f", CACurrentMediaTime() - start)
        let line = "[\(t)] \(message)"

        events.append(line)
        if events.count > maxEvents {
            events.removeFirst(events.count - maxEvents)
        }

        overlay?.append(line)
    }

    /// Snapshot of everything that describes where the cards actually are.
    /// Called on both sides of anything suspected of moving them.
    func snapshot(_ label: String, carousel: UIScrollView?, cards: [UIView], main: UIScrollView?) {
        guard Self.isEnabled else { return }

        var parts: [String] = [label]

        if let main = main {
            // contentSize / inset / maxOffset are what a damped oscillation at
            // the bottom limit is actually about: if the reachable bottom moves
            // while the scroll view is pinned there, it re-clamps and springs.
            let maxY = main.contentSize.height - main.bounds.height + main.adjustedContentInset.bottom
            parts.append(String(
                format: "mainY=%.1f max=%.1f csH=%.1f bH=%.1f insB=%.1f over=%.1f",
                main.contentOffset.y,
                maxY,
                main.contentSize.height,
                main.bounds.height,
                main.adjustedContentInset.bottom,
                main.contentOffset.y - maxY
            ))
        }
        if let c = carousel {
            parts.append(String(format: "carX=%.1f", c.contentOffset.x))
            parts.append("drag=\(c.isDragging ? 1 : 0)dec=\(c.isDecelerating ? 1 : 0)")
        }
        for (i, card) in cards.enumerated() {
            parts.append(String(
                format: "c%d[cx=%.1f sx=%.3f w=%.1f]",
                i, card.center.x, card.transform.a, card.bounds.width
            ))
        }

        log(parts.joined(separator: " "))
    }

    // MARK: - contentSize culprit

    private var sizeObservation: NSKeyValueObservation?

    /// contentSize is shrinking by exactly the overscroll amount, and it is not
    /// the view controller's layout doing it. KVO fires inside the setter, so
    /// the call stack at that moment names whatever is actually resizing the
    /// content.
    func watchContentSize(_ scrollView: UIScrollView) {
        guard Self.isEnabled else { return }

        log("wiring: " + Self.contentGuideStatus(scrollView))

        sizeObservation = scrollView.observe(\.contentSize, options: [.old, .new]) { [weak self] _, change in
            guard let old = change.oldValue, let new = change.newValue, old.height != new.height else { return }

            self?.log(String(format: "contentSize %.1f -> %.1f", old.height, new.height))

            // Ask Auto Layout which constraints it is actually using for the
            // vertical axis, once, on the first shrink. Guessing at the cause
            // has now failed twice; this makes the engine name them.
            if new.height < old.height {
                self?.dumpVerticalConstraintsOnce(scrollView)
            }

            // Only this app's frames - the UIKit ones in between are noise.
            let frames = Thread.callStackSymbols
                .filter { $0.contains("MyPT") }
                .prefix(6)

            if frames.isEmpty {
                self?.log("   (no MyPT frames - set by UIKit/Auto Layout)")
            } else {
                for f in frames {
                    // Trim the address/offset columns, keep the symbol.
                    let parts = f.split(separator: " ").dropFirst(3).prefix(4).joined(separator: " ")
                    self?.log("   " + parts)
                }
            }
        }
    }

    private var dumpedConstraints = false

    /// One-shot dump of every constraint Auto Layout is using vertically for
    /// the scroll view and its content view, printed at the moment contentSize
    /// first shrinks.
    private func dumpVerticalConstraintsOnce(_ scrollView: UIScrollView) {
        guard !dumpedConstraints else { return }
        dumpedConstraints = true

        log("=== VERTICAL CONSTRAINTS AT FIRST SHRINK ===")

        func dump(_ label: String, _ view: UIView) {
            let list = view.constraintsAffectingLayout(for: .vertical)
            log("-- \(label): \(list.count) constraint(s)")
            for c in list.prefix(14) {
                // Trim UIKit's very long descriptions to the informative part.
                var text = c.description
                if let r = text.range(of: "') ") { text = String(text[r.upperBound...]) }
                log("   " + String(text.prefix(150)))
            }
        }

        dump("scrollView", scrollView)
        if let content = scrollView.subviews.first {
            dump("contentView", content)
        }
        log("=== END CONSTRAINTS ===")
    }

    // MARK: - Output

    var dump: String {
        events.joined(separator: "\n")
    }

    func copyToPasteboard() {
        UIPasteboard.general.string = dump
    }

    // MARK: - Overlay

    /// Small always-on-top panel: live tail of the trace, plus COPY / CLEAR.
    func attachOverlay(to host: UIView) {
        guard Self.isEnabled, overlay == nil else { return }

        let panel = DebugOverlayView()
        panel.onCopy = { [weak self] in
            self?.copyToPasteboard()
        }
        panel.onClear = { [weak self] in
            self?.reset()
            panel.clear()
        }
        panel.translatesAutoresizingMaskIntoConstraints = false
        host.addSubview(panel)

        // Anchored by center so the drag gesture can move it: the panel sits
        // over the content being tested, so it has to be movable out of the way.
        let centerY = panel.centerYAnchor.constraint(equalTo: host.centerYAnchor, constant: 200)
        panel.dragConstraint = centerY

        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: 6),
            panel.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: -6),
            centerY,
            panel.heightAnchor.constraint(equalToConstant: 170)
        ])

        overlay = panel
        reset()
    }
}

// MARK: - Overlay view

private final class DebugOverlayView: UIView {

    var onCopy: (() -> Void)?
    var onClear: (() -> Void)?

    private let textView = UITextView()
    private let status = UILabel()

    /// Set by attachOverlay - moved by the drag gesture.
    var dragConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.82)
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.6).cgColor

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.textColor = .systemGreen
        textView.font = .monospacedSystemFont(ofSize: 8, weight: .regular)
        textView.isEditable = false
        textView.showsVerticalScrollIndicator = true
        addSubview(textView)

        let copyBtn = makeButton("COPY TRACE", .systemGreen)
        copyBtn.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        let clearBtn = makeButton("CLEAR", .systemOrange)
        clearBtn.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)

        status.translatesAutoresizingMaskIntoConstraints = false
        status.font = .monospacedSystemFont(ofSize: 9, weight: .semibold)
        status.textColor = .white
        status.text = "SGPT scroll trace"

        // Drag the header row to reposition the whole panel.
        let drag = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        addGestureRecognizer(drag)

        let row = UIStackView(arrangedSubviews: [status, copyBtn, clearBtn])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        addSubview(row)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            row.heightAnchor.constraint(equalToConstant: 22),

            textView.topAnchor.constraint(equalTo: row.bottomAnchor, constant: 2),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }

    private func makeButton(_ title: String, _ colour: UIColor) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .monospacedSystemFont(ofSize: 9, weight: .bold)
        b.setTitleColor(.black, for: .normal)
        b.backgroundColor = colour
        b.layer.cornerRadius = 4
        b.contentEdgeInsets = UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 7)
        return b
    }

    @objc private func handleDrag(_ gesture: UIPanGestureRecognizer) {
        guard let constraint = dragConstraint, let host = superview else { return }
        let translation = gesture.translation(in: host)
        constraint.constant += translation.y
        gesture.setTranslation(.zero, in: host)
    }

    @objc private func copyTapped() {
        onCopy?()
        status.text = "COPIED - paste it in chat"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { [weak self] in
            self?.status.text = "SGPT scroll trace"
        }
    }

    @objc private func clearTapped() {
        onClear?()
    }

    func append(_ line: String) {
        textView.text = (textView.text ?? "") + line + "\n"
        let end = NSRange(location: (textView.text as NSString).length, length: 0)
        textView.scrollRangeToVisible(end)
    }

    func clear() {
        textView.text = ""
    }
}
