//
//  TMLabelBarButton.swift
//  Tabman
//
//  Created by Merrick Sapsford on 06/06/2018.
//  Copyright © 2018 UI At Six. All rights reserved.
//

import UIKit

/// `TMBarButton` that consists of a single label - that's it!
///
/// Probably the most commonly seen example of a bar button.
public final class TMLabelBarButton: TMBarButton {
    
    // MARK: Defaults
    
    private struct Defaults {
        static let contentInset = UIEdgeInsets(top: 12.0, left: 8.0, bottom: 12.0, right: 8.0)
        static let font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        static let text = "Item"
    }
    
    // MARK: Properties
    
    public override var intrinsicContentSize: CGSize {
        if let fontIntrinsicContentSize = self.fontIntrinsicContentSize {
            return fontIntrinsicContentSize
        }
        return super.intrinsicContentSize
    }
    private var fontIntrinsicContentSize: CGSize?
    
    private let label = UILabel()
    
    public override var contentInset: UIEdgeInsets {
        set {
            super.contentInset = newValue
            calculateFontIntrinsicContentSize(for: text)
        } get {
            return super.contentInset
        }
    }
    
    /// Text to display in the button.
    public var text: String? {
        set {
            label.text = newValue
        } get {
            return label.text
        }
    }
    
    /// Color of the text when unselected / normal.
    public var color: UIColor = .black {
        didSet {
            if !isSelected {
                label.textColor = color
            }
        }
    }
    /// Color of the text when selected.
    public var selectedColor: UIColor = UIView.defaultTintColor {
        didSet {
            if isSelected  {
                label.textColor = selectedColor
            }
        }
    }
    /// Font of the text when unselected / normal.
    public var font: UIFont = Defaults.font {
        didSet {
            calculateFontIntrinsicContentSize(for: text)
            if !isSelected || selectedFont == nil {
                label.font = font
            }
        }
    }
    /// Font of the text when selected.
    public var selectedFont: UIFont? {
        didSet {
            calculateFontIntrinsicContentSize(for: text)
            guard let selectedFont = self.selectedFont, isSelected else {
                return
            }
            label.font = selectedFont
        }
    }
    
    // MARK: Lifecycle
    
    public override func layout(in view: UIView) {
        super.layout(in: view)
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            view.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            view.topAnchor.constraint(equalTo: label.topAnchor),
            view.trailingAnchor.constraint(equalTo: label.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: label.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        label.textAlignment = .center
        
        label.text = Defaults.text
        label.font = self.font
        self.contentInset = Defaults.contentInset
        
        calculateFontIntrinsicContentSize(for: label.text)
    }
    
    public override func populate(for item: TMBarItem) {
        super.populate(for: item)
        
        label.text = item.title
        calculateFontIntrinsicContentSize(for: item.title)
    }
    
    public override func update(for selectionState: TMBarButton.SelectionState) {
        
        let transitionColor = color.interpolate(with: selectedColor,
                                                percent: selectionState.rawValue)
        label.textColor = transitionColor
        
        // Because we can't animate nicely between fonts 😩
        // Cross dissolve on 'end' states between font properties.
        if let selectedFont = self.selectedFont {
            if selectionState == .selected && label.font != selectedFont {
                UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    self.label.font = self.selectedFont
                }, completion: nil)
            } else if selectionState != .selected && label.font == selectedFont {
                UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    self.label.font = self.font
                }, completion: nil)
            }
        }
    }
}

private extension TMLabelBarButton {
    
    /// Calculates an intrinsic content size based on font properties.
    ///
    /// Make the intrinsic size a calculated size based off a
    /// string value and font that requires the biggest size from `.font` and `.selectedFont`.
    ///
    /// - Parameter string: Value used for calculation.
    private func calculateFontIntrinsicContentSize(for string: String?) {
        guard let value = string else {
            return
        }
        let string = value as NSString
        let font = self.font
        let selectedFont = self.selectedFont ?? self.font
        
        let fontRect = string.boundingRect(with: .zero, options: .usesFontLeading, attributes: [.font: font], context: nil)
        let selectedFontRect = string.boundingRect(with: .zero, options: .usesFontLeading, attributes: [.font: selectedFont], context: nil)
        
        var largestWidth = max(selectedFontRect.size.width, fontRect.size.width)
        var largestHeight = max(selectedFontRect.size.height, fontRect.size.height)
        
        largestWidth += contentInset.left + contentInset.right
        largestHeight += contentInset.top + contentInset.bottom
        
        self.fontIntrinsicContentSize = CGSize(width: largestWidth, height: largestHeight)
        invalidateIntrinsicContentSize()
    }
}