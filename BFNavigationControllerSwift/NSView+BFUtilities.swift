//
//  NSView+BFUtilities.swift
//
//  Created by Heiko Dreyer on 04/27/12.
//  Copyright (c) 2012 boxedfolder.com. All rights reserved.
//  Swift Port by https://github.com/spiderr
//

import Cocoa

extension NSView {
    ///---------------------------------------------------------------------------------------
    /// @name Flattening View Hierarchy
    ///---------------------------------------------------------------------------------------

    /**
     *  Flatten self + subviews, return proper NSImage.
     */
    func flattenWithSubviews() -> NSImage? {
        let bounds: NSRect = self.bounds
        let size: NSSize = bounds.size
        var fBounds: NSRect = bounds
        var offset = NSPoint.zero

        // Don't draw anything if zero size
        if NSEqualSizes(NSSize.zero, size) {
            return nil
        }

        let hScrollView: NSScrollView? = enclosingScrollView

        // Check if there is an enclosing scrollview
        if let hSV = hScrollView {
            let botLeft = NSPoint.init(x: hSV.bounds.minX, y: hSV.isFlipped ? hSV.bounds.maxY : hSV.bounds.minY)
            offset = hSV.convert(botLeft, to: hSV.window?.contentView)
        }

        fBounds.origin.x -= offset.x
        fBounds.origin.y -= offset.y
        fBounds.size.width += offset.x
        fBounds.size.height += offset.x

        let fSize: NSSize = fBounds.size
        var bitmapRep: NSBitmapImageRep? = bitmapImageRepForCachingDisplay(in: fBounds)
        bitmapRep?.size = fSize
        if let bitmapRep = bitmapRep {
            cacheDisplay(in: fBounds, to: bitmapRep)
        }

        let image = NSImage(size: size)
        image.lockFocus()
        bitmapRep?.draw(at: fBounds.origin)
        image.unlockFocus()
        bitmapRep = nil

        return image
    }
}
