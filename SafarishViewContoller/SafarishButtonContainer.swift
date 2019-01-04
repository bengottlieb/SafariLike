//
//  SafarishButtonContainer.swift
//  Safarish
//
//  Created by Ben Gottlieb on 1/3/19.
//  Copyright © 2019 Stand Alone, Inc. All rights reserved.
//

import UIKit

class SafarishButtonContainer: UIToolbar {
	enum Side { case left, right }
	var side: Side!
	convenience init(frame: CGRect, side: Side) {
		self.init(frame: frame)
		self.side = side
		self.backgroundColor = .clear
		self.barTintColor = .clear
		let clearImage = UIImage()
		self.setBackgroundImage(clearImage, forToolbarPosition: .any, barMetrics: .default)
		self.setShadowImage(clearImage, forToolbarPosition: .any)
	}

	var shrinkPercentage: CGFloat = 0.0 { didSet {
		self.transform = CGAffineTransform(scaleX: 1.0 - shrinkPercentage, y: 1.0 - shrinkPercentage)
		self.alpha = 1.0 - shrinkPercentage
	}}
}
