//
//  SafarishNavigationTitleView.swift
//  Safarish
//
//  Created by Ben Gottlieb on 7/28/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import UIKit

class SafarishNavigationTitleView: UIView {
	var urlField: SafarishURLEntryField!
	var parent: SafarishViewController!
	var leftToolbar: UIToolbar!
	var rightToolbar: UIToolbar!
	
	var viewWidth: CGFloat = 740 { didSet {
		self.mainWidthConstraint.constant = self.viewWidth - 28
	}}
	
	var leftBarButtonItems: [UIBarButtonItem] = [] { didSet {
		self.leftToolbar.items = self.leftBarButtonItems
		self.updateToolbarWidths()
	}}

	var rightBarButtonItems: [UIBarButtonItem] = [] { didSet {
		self.rightToolbar.items = self.rightBarButtonItems
		self.updateToolbarWidths()
	}}

	convenience init(in parent: SafarishViewController) {
		self.init(frame: CGRect(x: 0, y: 0, width: 740, height: 44))
		self.translatesAutoresizingMaskIntoConstraints = false

		self.parent = parent
		self.urlField = SafarishURLEntryField(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
		
		self.leftToolbar = UIToolbar(frame: .zero)
		self.rightToolbar = UIToolbar(frame: .zero)
		
		self.addSubview(self.leftToolbar)
		self.addSubview(self.urlField)
		self.addSubview(self.rightToolbar)
		self.urlField.translatesAutoresizingMaskIntoConstraints = false
		self.leftToolbar.translatesAutoresizingMaskIntoConstraints = false
		self.rightToolbar.translatesAutoresizingMaskIntoConstraints = false
		self.urlField.safarishViewController = parent
		
		self.urlField.addConstraints([
			//NSLayoutConstraint(item: self.urlField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 400),
			NSLayoutConstraint(item: self.urlField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44)
		])
		
		self.mainWidthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.bounds.width)
		self.leftToolbarWidthConstraint = NSLayoutConstraint(item: self.leftToolbar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 10)
		self.rightToolbarWidthConstraint = NSLayoutConstraint(item: self.rightToolbar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 10)

		self.addConstraints([
			self.mainWidthConstraint,
			NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.bounds.height),
			//NSLayoutConstraint(item: self.urlField, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.urlField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0),
			
			NSLayoutConstraint(item: self.leftToolbar, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.leftToolbar, attribute: .right, relatedBy: .equal, toItem: self.urlField, attribute: .left, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.rightToolbar, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.rightToolbar, attribute: .left, relatedBy: .equal, toItem: self.urlField, attribute: .right, multiplier: 1, constant: 0),
			
			NSLayoutConstraint(item: self.leftToolbar, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.rightToolbar, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.leftToolbar, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: self.rightToolbar, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),

		])
		
		self.leftToolbar.addConstraint(self.leftToolbarWidthConstraint)
		self.rightToolbar.addConstraint(self.rightToolbarWidthConstraint)
		
		self.updateToolbarWidths()
	}
	
	func updateToolbarWidths() {
		let maxWidth = max(self.leftToolbar.items?.reduce(0) { $0 + $1.width } ?? 0, self.rightToolbar.items?.reduce(0) { $0 + $1.width } ?? 0)
		self.leftToolbarWidthConstraint.constant = maxWidth
		self.rightToolbarWidthConstraint.constant = maxWidth
		self.setNeedsLayout()
	}
	
	var mainWidthConstraint: NSLayoutConstraint!
	var leftToolbarWidthConstraint: NSLayoutConstraint!
	var rightToolbarWidthConstraint: NSLayoutConstraint!
	
}
