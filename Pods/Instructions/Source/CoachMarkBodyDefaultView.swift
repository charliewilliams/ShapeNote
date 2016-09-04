// CoachMarkBodyDefaultView.swift
//
// Copyright (c) 2015 Frédéric Maquin <fred@ephread.com>
//                    Esteban Soto <esteban.soto.dev@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

//MARK: - Main Class
/// A concrete implementation of the coach mark body view and the
/// default one provided by the library.
open class CoachMarkBodyDefaultView: UIControl, CoachMarkBodyView {
    //MARK: Public properties
    open var nextControl: UIControl? {
        get {
            return self
        }
    }

    open weak var highlightArrowDelegate: CoachMarkBodyHighlightArrowDelegate?

    override open var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.backgroundImageView.image = highlightedBackgroundImage
            } else {
                self.backgroundImageView.image = backgroundImage
            }

            self.highlightArrowDelegate?.highlightArrow(self.isHighlighted)
        }
    }

    open var nextLabel = UILabel()
    open var hintLabel = UITextView()
    open var separator = UIView()

    //MARK: - Private properties
    fileprivate let backgroundImage = UIImage(
        named: "background",
        in: Bundle(for: CoachMarkBodyDefaultView.self),
        compatibleWith: nil
    )

    fileprivate let highlightedBackgroundImage = UIImage(
        named: "background-highlighted",
        in: Bundle(for: CoachMarkBodyDefaultView.self),
        compatibleWith: nil
    )

    fileprivate let backgroundImageView: UIImageView

    //MARK: - Initialization
    override public init(frame: CGRect) {
        self.backgroundImageView = UIImageView(image: self.backgroundImage)

        super.init(frame: frame)

        self.setupInnerViewHierarchy()
    }

    convenience public init() {
        self.init(frame: CGRect.zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding.")
    }

    public init(frame: CGRect, hintText: String, nextText: String?) {
        self.backgroundImageView = UIImageView(image: self.backgroundImage)

        super.init(frame: frame)

        if let next = nextText {
            self.hintLabel.text = hintText
            self.nextLabel.text = next
            self.setupInnerViewHierarchy()
        } else {
            self.hintLabel.text = hintText
            self.setupSimpleInnerViewHierarchy()
        }
    }

    convenience public init (hintText: String, nextText: String?) {
        self.init(frame: CGRect.zero, hintText: hintText, nextText: nextText)
    }
}

//MARK: - Inner Hierarchy Setup
extension CoachMarkBodyDefaultView {
    //Configure the CoachMark view with a hint message and a next message
    fileprivate func setupInnerViewHierarchy() {
        translatesAutoresizingMaskIntoConstraints = false

        configureBackgroundView()
        configureHintLabel()
        configureNextLabel()
        configureSeparator()

        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(10)-[hintLabel]-(10)-[separator(==1)][nextLabel(==55)]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: [
                "hintLabel": hintLabel,
                "separator": separator,
                "nextLabel": nextLabel
            ]
        ))
    }

    fileprivate func configureBackgroundView() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.isUserInteractionEnabled = false

        addSubview(self.backgroundImageView)

        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[backgroundImageView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["backgroundImageView": backgroundImageView]
        ))

        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[backgroundImageView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["backgroundImageView": backgroundImageView]
        ))
    }

    fileprivate func configureHintLabel() {
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        hintLabel.isUserInteractionEnabled = false
        hintLabel.backgroundColor = UIColor.clear
        hintLabel.textColor = UIColor.darkGray
        hintLabel.font = UIFont.systemFont(ofSize: 15.0)
        hintLabel.isScrollEnabled = false
        hintLabel.textAlignment = .justified
        hintLabel.layoutManager.hyphenationFactor = 1.0
        hintLabel.isEditable = false

        addSubview(hintLabel)

        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(5)-[hintLabel]-(5)-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["hintLabel": hintLabel]
        ))
    }

    fileprivate func configureNextLabel() {
        nextLabel.textColor = UIColor.darkGray
        nextLabel.font = UIFont.systemFont(ofSize: 17.0)
        nextLabel.textAlignment = .center

        nextLabel.translatesAutoresizingMaskIntoConstraints = false
        nextLabel.isUserInteractionEnabled = false

        self.addSubview(nextLabel)

        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[nextLabel]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["nextLabel": nextLabel]
        ))
    }

    fileprivate func configureSeparator() {
        separator.backgroundColor = UIColor.gray
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.isUserInteractionEnabled = false

        self.addSubview(separator)

        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(15)-[separator]-(15)-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["separator": separator]
        ))
    }
}

//MARK: - Simple Inner Hierarchy Setup
extension CoachMarkBodyDefaultView {
    fileprivate func setupSimpleInnerViewHierarchy() {
        translatesAutoresizingMaskIntoConstraints = false

        configureBackgroundView()
        configureSimpleHintLabel()
    }

    fileprivate func configureSimpleHintLabel() {
        hintLabel.backgroundColor = UIColor.clear
        hintLabel.textColor = UIColor.darkGray
        hintLabel.font = UIFont.systemFont(ofSize: 15.0)
        hintLabel.isScrollEnabled = false
        hintLabel.textAlignment = .justified
        hintLabel.layoutManager.hyphenationFactor = 1.0
        hintLabel.isEditable = false

        hintLabel.translatesAutoresizingMaskIntoConstraints = false

        hintLabel.isUserInteractionEnabled = false

        addSubview(hintLabel)

        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(5)-[hintLabel]-(5)-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["hintLabel": hintLabel]
            ))

        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(10)-[hintLabel]-(10)-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["hintLabel": hintLabel]
            ))
    }
}
