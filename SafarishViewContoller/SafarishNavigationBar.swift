//
//  SafarishNavigationBar.swift
//  Safarish
//
//  Created by Ben Gottlieb on 1/3/19.
//  Copyright © 2019 Stand Alone, Inc. All rights reserved.
//

import UIKit

class SafarishNavigationBar: UIToolbar {
	var leftButtonContainer: SafarishButtonContainer!
	var rightButtonContainer: SafarishButtonContainer!
	var urlEntryField: SafarishURLEntryField! { didSet { self.setNeedsLayout() }}
	var parent: SafarishViewController!
	
	convenience init(frame: CGRect, in parent: SafarishViewController) {
		self.init(frame: frame)
		self.parent = parent
	}
	
	var shrinkPercentage: CGFloat = 0.0 { didSet {
		self.leftButtonContainer.shrinkPercentage = self.shrinkPercentage
		self.rightButtonContainer.shrinkPercentage = self.shrinkPercentage
	}}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		if self.leftButtonContainer == nil {
			let top = self.safeAreaInsets.top
			let height = self.bounds.height - self.safeAreaInsets.top
			let width: CGFloat = 300
			self.leftButtonContainer = SafarishButtonContainer(frame: CGRect(x: 0, y: top, width: width, height: height), side: .left)
			self.addSubview(self.leftButtonContainer)
			self.leftButtonContainer.translatesAutoresizingMaskIntoConstraints = false
			self.leftButtonContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
			self.leftButtonContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
			self.leftButtonContainer.heightAnchor.constraint(equalToConstant: 44).isActive = true
			self.leftButtonContainer.widthAnchor.constraint(equalToConstant: 300).isActive = true

			self.rightButtonContainer = SafarishButtonContainer(frame: CGRect(x: self.bounds.width - width, y: top, width: width, height: height), side: .right)
			self.addSubview(self.rightButtonContainer)
			self.rightButtonContainer.translatesAutoresizingMaskIntoConstraints = false
			self.rightButtonContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
			self.rightButtonContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
			self.rightButtonContainer.heightAnchor.constraint(equalToConstant: 44).isActive = true
			self.rightButtonContainer.widthAnchor.constraint(equalToConstant: 300).isActive = true

			self.updateNavigationItems()
		}
		
		if self.urlEntryField != nil, self.urlEntryField.superview == nil {
			self.addSubview(self.urlEntryField)
			self.urlEntryField.translatesAutoresizingMaskIntoConstraints = false
			self.urlEntryField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
			self.urlEntryField.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: (self.bounds.height - 50) / 2).isActive = true
//			self.urlEntryField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		}
	}
	
	func updateNavigationItems() {
		self.leftButtonContainer?.items = self.parent.navigationItem.leftBarButtonItems
		self.rightButtonContainer?.items = self.parent.navigationItem.rightBarButtonItems
	}
}
