//
//  InsetLabel.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 08.11.21.
//

import UIKit

open class InsetLabel: UILabel {

    open var textInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsDisplay()
        }
    }

    open override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        super.drawText(in: insetRect)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()

        let horizontalInset = textInsets.left + textInsets.right
        preferredMaxLayoutWidth = frame.width - horizontalInset
    }
    
    open override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let width = size.width + textInsets.left + textInsets.right
        let height = size.height + textInsets.top + textInsets.bottom
        return CGSize(width: width, height: height)
    }
}
