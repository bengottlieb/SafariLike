//
//  SafarishIPadTitleBarView.swift
//  Safarish
//
//  Created by Ben Gottlieb on 12/27/16.
//  Copyright © 2016 Stand Alone, Inc. All rights reserved.
//

import Foundation
import UIKit

extension SafarishViewController {
	class IPadTitleBarView: TitleBarView {
		
		convenience init(frame: CGRect, parent: SafarishViewController) {
			self.init(frame: frame)
			self.safarishViewController = parent
			
            self.updateToolbars()
			self.setup(includingCancelButton: false, includingDoneButton: false)
			self.addToolbars()
		}
		
		func addToolbars() {
			self.addSubview(self.leftToolbar)
			
			self.leftToolbar.items = self.safarishViewController.ipadToolbarItems?.0
			
			self.leftToolbar.backgroundColor = UIColor.clear
			self.leftToolbar.addConstraint(NSLayoutConstraint(item: self.leftToolbar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.fieldBackgroundMargins.left))
			
			self.addConstraints([
				NSLayoutConstraint(item: self.leftToolbar, attribute: .right, relatedBy: .equal, toItem: self.fieldBackground, attribute: .left, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: self.leftToolbar, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: self.fieldBackgroundStatusSpacing),
				NSLayoutConstraint(item: self.leftToolbar, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
			])
            
			self.addSubview(self.rightToolbar)
			
			self.rightToolbar.items = self.safarishViewController.ipadToolbarItems?.1
			self.rightToolbar.backgroundColor = UIColor.clear
			self.rightToolbar.addConstraint(NSLayoutConstraint(item: self.rightToolbar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.fieldBackgroundMargins.right))
			
			self.addConstraints([
				NSLayoutConstraint(item: self.rightToolbar, attribute: .left, relatedBy: .equal, toItem: self.fieldBackground, attribute: .right, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: self.rightToolbar, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: self.fieldBackgroundStatusSpacing),
				NSLayoutConstraint(item: self.rightToolbar, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
			])
		}
		
        func updateToolbars() {
            var leftWidth: CGFloat = 20
            var rightWidth: CGFloat = 20
            let defaultItemWidth: CGFloat = 44
            
            for item in self.safarishViewController.ipadToolbarItems?.0 ?? [] {
                let width = item.width > 0 ? item.width : defaultItemWidth
                leftWidth += width
            }

            for item in self.safarishViewController.ipadToolbarItems?.1 ?? [] {
                let width = item.width > 0 ? item.width : defaultItemWidth
                rightWidth += width
            }
			
			if self.safarishViewController.forceCenteredURLBar {
				leftWidth = max(leftWidth, rightWidth)
				rightWidth = max(leftWidth, rightWidth)
			}
			
			self.fieldBackgroundMargins.left = leftWidth
			self.fieldBackgroundMargins.right = rightWidth
			self.leftToolbar.items = self.safarishViewController.ipadToolbarItems?.0
			self.rightToolbar.items = self.safarishViewController.ipadToolbarItems?.1
       }
        
        
		override var displayedHeightFraction: CGFloat { didSet {
			let leftTranslation = (1.0 - self.displayedHeightFraction * self.displayedHeightFraction * self.displayedHeightFraction * self.displayedHeightFraction) * self.fieldBackgroundMargins.left * 0.2
			let rightTranslation = (1.0 - self.displayedHeightFraction * self.displayedHeightFraction * self.displayedHeightFraction * self.displayedHeightFraction) * self.fieldBackgroundMargins.right * 0.2

			self.leftToolbar.alpha = self.displayedHeightFraction * self.displayedHeightFraction
			self.leftToolbar.transform = CGAffineTransform(translationX: leftTranslation, y: 0).scaledBy(x: self.displayedHeightFraction, y: self.displayedHeightFraction)

			self.rightToolbar.alpha = self.displayedHeightFraction * self.displayedHeightFraction
			self.rightToolbar.transform = CGAffineTransform(translationX: -rightTranslation, y: 0).scaledBy(x: self.displayedHeightFraction, y: self.displayedHeightFraction)
		}}
		
		
		var leftToolbar: UIToolbar = {
			let toolbar = UIToolbar(frame: .zero)
			toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
			toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
			toolbar.translatesAutoresizingMaskIntoConstraints = false
			return toolbar
		}()

		var rightToolbar: UIToolbar = {
			let toolbar = UIToolbar(frame: .zero)
			toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
			toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
			toolbar.translatesAutoresizingMaskIntoConstraints = false
			return toolbar
		}()
	}

}
