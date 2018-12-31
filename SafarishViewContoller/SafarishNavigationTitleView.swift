//
//  SafarishNavigationTitleView.swift
//  Safarish
//
//  Created by Ben Gottlieb on 7/28/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
	static var defaultSafarishItemWidth: CGFloat = 40
}


protocol SafarishNavigationTitleView {
	var isEnabled: Bool { get set }
	var isEditing: Bool { get set }

	var areNavigationControlsHidden: Bool { get set }
	var estimatedProgress: CGFloat? { get set }
	var viewWidth: CGFloat { get set }
	var shrinkPercentage: CGFloat { get set }
	var rightBarButtonItems: [UIBarButtonItem] { get set }
	var leftBarButtonItems: [UIBarButtonItem] { get set }
	var currentURL: URL? { get set }
	var drawBottomDivider: Bool { get set }
}

class SafarishNavigationURLView: UIView, SafarishNavigationTitleView {
	var estimatedProgress: CGFloat? { didSet { self.setNeedsDisplay() }}
	
	var urlField: SafarishURLEntryField!
	var parent: SafarishViewController!
	var leftToolbar: UIToolbar!
	var rightToolbar: UIToolbar!
	var enabledAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black] { didSet { self.urlField.enabledAttributes = self.enabledAttributes }}
	var disabledAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black] { didSet { self.urlField.disabledAttributes = self.disabledAttributes }}
	var shrinkPercentage: CGFloat = 0.0 { didSet { self.updateShrinkage() }}
	var drawBottomDivider = true { didSet { self.setNeedsDisplay() }}
	var areNavigationControlsHidden: Bool = false { didSet {
		self.isURLFieldHidden = self.areNavigationControlsHidden
	}}
	
	override var frame: CGRect { didSet { self.updateFrame() } }
	override var bounds: CGRect { didSet { self.updateFrame() } }

	override func didMoveToSuperview() {
		self.updateFrame()
	}
	
	func updateFrame() {
		if let sv = self.superview, self.frame.width != sv.bounds.width {
			var rect = self.frame
			rect.size.width = sv.bounds.width
			rect.origin.x = 0
			self.frame = rect
		}
	}
	
	var isURLFieldHidden: Bool {
		get { return self.urlField?.isHidden ?? true }
		set { self.urlField?.isHidden = newValue }
	}

	var isEnabled: Bool {
		get { return self.urlField?.isEnabled ?? false }
		set { self.urlField?.isEnabled = newValue }
	}
	
	var isEditing: Bool {
		get { return self.urlField?.isEditing ?? false }
		set {
			if newValue {
				self.urlField?.beginEditing(recog: nil)
			} else {
				self.urlField?.finishEditing()
			}
		}
	}
	
	var currentURL: URL? {
		get { return self.urlField?.url }
		set { self.urlField?.url = newValue }
	}
	
	var viewWidth: CGFloat = 768 { didSet {
		self.mainWidthConstraint.constant = self.viewWidth
	}}
	
	var leftBarButtonItems: [UIBarButtonItem] = [] { didSet {
		if (self.leftToolbar?.items ?? []) != self.leftBarButtonItems {
			self.leftToolbar?.items = self.leftBarButtonItems
			self.updateToolbarWidths()
		}
	}}

	var rightBarButtonItems: [UIBarButtonItem] = [] { didSet {
		if (self.rightToolbar?.items ?? []) != self.rightBarButtonItems {
			self.rightToolbar.items = self.rightBarButtonItems
			self.updateToolbarWidths()
		}
	}}

	init(in parent: SafarishViewController) {
		super.init(frame: CGRect(x: 0, y: 0, width: 740, height: 44))
	//	self.translatesAutoresizingMaskIntoConstraints = false
		self.mainWidthConstraint = self.widthAnchor.constraint(equalToConstant: self.bounds.width)
		self.mainWidthConstraint.isActive = true
		
		self.heightAnchor.constraint(equalToConstant: self.bounds.height).isActive = true
		

		self.parent = parent
		self.urlField = SafarishURLEntryField(in: parent)
		self.backgroundColor = .clear
		self.urlField?.translatesAutoresizingMaskIntoConstraints = false
		self.urlField?.safarishViewController = parent
		self.urlField.enabledAttributes = self.enabledAttributes
		self.urlField.disabledAttributes = self.disabledAttributes

		self.addSubview(self.urlField)
		if parent.isIPad {
			self.leftToolbar = UIToolbar(frame: .zero)
			self.rightToolbar = UIToolbar(frame: .zero)
			self.leftToolbar.backgroundColor = .clear
			self.rightToolbar.backgroundColor = .clear

			self.addSubview(self.leftToolbar)
			self.addSubview(self.rightToolbar)
			self.leftToolbar.translatesAutoresizingMaskIntoConstraints = false
			self.rightToolbar.translatesAutoresizingMaskIntoConstraints = false
			
			let nullImage = UIImage()
			self.leftToolbar.setShadowImage(nullImage, forToolbarPosition: .any)
			self.rightToolbar.setShadowImage(nullImage, forToolbarPosition: .any)
			self.leftToolbar.setBackgroundImage(nullImage, forToolbarPosition: .any, barMetrics: .default)
			self.rightToolbar.setBackgroundImage(nullImage, forToolbarPosition: .any, barMetrics: .default)

			self.urlField.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
			self.urlField.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 20).isActive = true
			self.urlField.heightAnchor.constraint(equalToConstant: 44).isActive = true

			self.leftToolbar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
			self.leftToolbar.trailingAnchor.constraint(equalTo: self.urlField.leadingAnchor, constant: 0).isActive = true
			self.leftToolbar.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -5).isActive = true
			self.leftToolbar.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true

			self.rightToolbar.leadingAnchor.constraint(equalTo: self.urlField.trailingAnchor, constant: 0).isActive = true
			self.rightToolbar.leadingAnchor.constraint(equalTo: self.urlField.trailingAnchor, constant: 0).priority = UILayoutPriority(750)
			self.rightToolbar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
			self.rightToolbar.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -5).isActive = true
			self.rightToolbar.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
			
			self.leftToolbarWidthConstraint = self.leftToolbar.widthAnchor.constraint(equalToConstant: 100)
			self.leftToolbarWidthConstraint.isActive = true

			self.rightToolbarWidthConstraint = self.rightToolbar.widthAnchor.constraint(equalToConstant: 100)
			self.rightToolbarWidthConstraint.isActive = true
		} else {
			self.urlField.heightAnchor.constraint(equalToConstant: 44).isActive = true
			self.urlField.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
			self.urlField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
			self.urlField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18).isActive = true
		}

		self.updateToolbarWidths()
		self.isURLFieldHidden = self.areNavigationControlsHidden
	}
	
	required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func draw(_ rect: CGRect) {
		if self.drawBottomDivider {
			let lineWidth = 1.0 / UIScreen.main.scale
			let bezier = UIBezierPath()
			let bounds = self.bounds
			UIColor.lightGray.setStroke()
			bezier.move(to: CGPoint(x: 0, y: bounds.height - lineWidth))
			bezier.addLine(to: CGPoint(x: bounds.width, y: bounds.height - lineWidth))
			bezier.lineWidth = lineWidth
			bezier.stroke()
		}
		
		if let progress = self.estimatedProgress, progress < 1.0 {
			let progressHeight: CGFloat = 3.0
			let barRect = CGRect(x: 0, y: bounds.height - progressHeight, width: bounds.width * CGFloat(progress), height: progressHeight)
			self.tintColor.setFill()
			UIRectFill(barRect)
		}
	}
	
	func updateShrinkage() {
		let newAlpha = (1.0 - self.shrinkPercentage) * (1.0 - self.shrinkPercentage)

		self.urlField?.shrinkPercentage = self.shrinkPercentage
		self.leftToolbar?.alpha = newAlpha
		self.rightToolbar?.alpha = newAlpha
		
		let toolbarTranslation: CGFloat = 20
		let toolbarScale = (1.0 - self.shrinkPercentage) / max(0.0001, 1.0 - self.shrinkPercentage)
		self.leftToolbar?.transform = CGAffineTransform(translationX: toolbarTranslation * self.shrinkPercentage, y: 0).scaledBy(x: toolbarScale, y: toolbarScale)
		self.rightToolbar?.transform = CGAffineTransform(translationX: -toolbarTranslation * self.shrinkPercentage, y: 0).scaledBy(x: toolbarScale, y: toolbarScale)

		self.leftToolbar?.isUserInteractionEnabled = self.shrinkPercentage == 0.0
		self.rightToolbar?.isUserInteractionEnabled = self.shrinkPercentage == 0.0
	}

	func updateToolbarWidths() {
		guard let leftBar = self.leftToolbar, let rightBar = self.rightToolbar else { return }
		let leftWidth = leftBar.items?.reduce(0) { $0 + $1.width + 15 } ?? 0
		let rightWidth = rightBar.items?.reduce(0) { $0 + $1.width + 15 } ?? 0
		let maxWidth = max(leftWidth, rightWidth)
		self.leftToolbarWidthConstraint.constant = maxWidth
		self.rightToolbarWidthConstraint.constant = maxWidth
		
		leftBar.setNeedsLayout()
		self.rightToolbar.setNeedsLayout()
		
		self.setNeedsLayout()
	}
	
	var mainWidthConstraint: NSLayoutConstraint!
	var leftToolbarWidthConstraint: NSLayoutConstraint!
	var rightToolbarWidthConstraint: NSLayoutConstraint!
	
}

