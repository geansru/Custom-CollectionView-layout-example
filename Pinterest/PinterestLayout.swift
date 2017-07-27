//
//  PinterestLayout.swift
//  Pinterest
//
//  Created by Dmitriy Roytman on 27.07.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

final class PinterestLayout: UICollectionViewLayout {
  var delegate: PinterestLayoutDelegate?
  var numberOfColumns = 2
  var cellPadding: CGFloat = 6.0
  private var cache: [PinterestLayoutAttributes] = []
  private var contentHeight: CGFloat = 0
  private var contentWidth: CGFloat {
    let insets = collectionView!.contentInset
    return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
  }
  
  override func prepareLayout() {
    guard cache.isEmpty else { return }
    guard let delegate = delegate else { return }
    let columnWidth = contentWidth / CGFloat(numberOfColumns)
    var xOffset: [CGFloat] = []
    (0..<numberOfColumns).forEach { xOffset.append(columnWidth * CGFloat($0)) }
    var column = 0
    var yOffset = [CGFloat](count: numberOfColumns, repeatedValue: 0)
    
    let numberOfItems = collectionView!.numberOfItemsInSection(0)
    for item in 0..<numberOfItems {
      let indexPath = NSIndexPath(forItem: item, inSection: 0)
      let width = columnWidth - cellPadding * 2
      let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath, withWidth: width)
      let annotationHeight = delegate.collectionView(collectionView!, heightForAnnotationAtIndexPath: indexPath, withWidth: width)
      let height = cellPadding * 2 + photoHeight + annotationHeight
      let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
      let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
      
      let attributes = PinterestLayoutAttributes(forCellWithIndexPath: indexPath)
      attributes.photoHeight = photoHeight
      attributes.frame = insetFrame
      cache.append(attributes)
      
      contentHeight = max(contentHeight, CGRectGetMaxY(frame))
      yOffset[column] += height
      column = column >= (numberOfColumns - 1) ? 0 : column + 1
    }
  }
  
  override func collectionViewContentSize() -> CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return cache.filter { $0.frame.intersects(rect) }
  }
  
  override class func layoutAttributesClass() -> AnyClass {
    return PinterestLayoutAttributes.self
  }
}

protocol PinterestLayoutDelegate {
  func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
  func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
}

class PinterestLayoutAttributes: UICollectionViewLayoutAttributes {
  var photoHeight: CGFloat = 0.0
  override func copyWithZone(zone: NSZone) -> AnyObject {
    let copy = super.copyWithZone(zone) as! PinterestLayoutAttributes
    copy.photoHeight = photoHeight
    return copy
  }
  
  override func isEqual(object: AnyObject?) -> Bool {
    guard let attributes = object as? PinterestLayoutAttributes
      where attributes.photoHeight == photoHeight
      else { return false }
    return super.isEqual(object)
  }
}
