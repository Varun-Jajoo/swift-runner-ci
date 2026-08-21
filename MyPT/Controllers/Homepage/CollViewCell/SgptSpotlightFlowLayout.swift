//
//  SgptSpotlightFlowLayout.swift
//  MyPT
//

import UIKit

final class SgptSpotlightFlowLayout: UICollectionViewFlowLayout {

    private static let interCardGap: CGFloat = 16
    private static let activeDistance: CGFloat = SgptCardCollectionViewCell.cardSize.width + interCardGap
    private static let focusedScale: CGFloat = 240.0 / 192.0

    private static let maxAlpha: CGFloat = 1.0
    private static let minAlpha: CGFloat = 0.5

    override func prepare() {
        guard let collectionView = collectionView else {
            super.prepare()
            return
        }
        let itemSize = SgptCardCollectionViewCell.cardSize
        let verticalInset = max((collectionView.bounds.height - itemSize.height) / 2, 0)
        let horizontalInset = max((collectionView.bounds.width - itemSize.width) / 2, 0)
        sectionInset = UIEdgeInsets(top: verticalInset, left: horizontalInset,
                                    bottom: verticalInset, right: horizontalInset)
        super.prepare()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView,
              let rectAttributes = super.layoutAttributesForElements(in: rect)?
                  .map({ $0.copy() as! UICollectionViewLayoutAttributes }) else {
            return nil
        }

        let centerX = collectionView.bounds.midX

        let cellAttributes = rectAttributes
            .filter { $0.representedElementCategory == .cell }
            .sorted { $0.indexPath < $1.indexPath }

        var renderedWidths: [CGFloat] = []
        var progresses: [CGFloat] = []
        renderedWidths.reserveCapacity(cellAttributes.count)
        progresses.reserveCapacity(cellAttributes.count)
        for attributes in cellAttributes {
            let distance = abs(attributes.center.x - centerX)
            let progress = min(distance / SgptSpotlightFlowLayout.activeDistance, 1.0)
            progresses.append(progress)

            let scale = SgptSpotlightFlowLayout.focusedScale
                - (SgptSpotlightFlowLayout.focusedScale - 1.0) * progress
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
            renderedWidths.append(scale * SgptCardCollectionViewCell.cardSize.width)

            attributes.alpha = SgptSpotlightFlowLayout.maxAlpha
                - (SgptSpotlightFlowLayout.maxAlpha - SgptSpotlightFlowLayout.minAlpha) * progress

            attributes.zIndex = Int((1 - progress) * 100)
        }

        guard cellAttributes.count > 1 else { return rectAttributes }

        var packedCenters = [CGFloat](repeating: 0, count: cellAttributes.count)
        for i in 1..<cellAttributes.count {
            packedCenters[i] = packedCenters[i - 1]
                + (renderedWidths[i - 1] + renderedWidths[i]) / 2
                + SgptSpotlightFlowLayout.interCardGap
        }

        var weightedSum: CGFloat = 0
        var weightTotal: CGFloat = 0
        for i in 0..<cellAttributes.count {
            let weight = 1 - progresses[i]
            weightedSum += packedCenters[i] * weight
            weightTotal += weight
        }
        guard weightTotal > 0.0001 else { return rectAttributes }

        let globalShift = centerX - weightedSum / weightTotal
        for (i, attributes) in cellAttributes.enumerated() {
            attributes.center = CGPoint(x: packedCenters[i] + globalShift, y: attributes.center.y)
        }

        return rectAttributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }

        let targetRect = CGRect(x: proposedContentOffset.x, y: 0,
                                width: collectionView.bounds.width, height: collectionView.bounds.height)
        guard let candidates = super.layoutAttributesForElements(in: targetRect) else {
            return proposedContentOffset
        }

        let proposedCenterX = proposedContentOffset.x + collectionView.bounds.width / 2
        var closestOffset = CGFloat.greatestFiniteMagnitude
        for attributes in candidates where attributes.representedElementCategory == .cell {
            let delta = attributes.center.x - proposedCenterX
            if abs(delta) < abs(closestOffset) {
                closestOffset = delta
            }
        }
        guard closestOffset != .greatestFiniteMagnitude else { return proposedContentOffset }

        return CGPoint(x: proposedContentOffset.x + closestOffset, y: proposedContentOffset.y)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}
