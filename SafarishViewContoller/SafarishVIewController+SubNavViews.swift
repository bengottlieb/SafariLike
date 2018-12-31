//
//  SafarishVIewController+SubNavViews.swift
//  Internal-iOS
//
//  Created by Ben Gottlieb on 5/10/18.
//  Copyright © 2018 Stand Alone, Inc. All rights reserved.
//

import UIKit

extension SafarishViewController {
	var navigationSubviewOffset: CGFloat {
		let navBarHeight = self.navigationController?.navigationBar.bounds.height ?? 0
		return (self.currentScrollStart) + navBarHeight + self.statusBarHeight
	}
	
	func addNavigationSubview(_ view: UIView, collapsable: Bool = true) {
		let previous = self.navigationSubviewInfo.last?.view
		let height = view.bounds.height

		self.navigationSubviewInfo.append(NavigationSubviewInfo(view: view, collapsable: collapsable))
		if self.navigationSubviewHost == nil {
			self.navigationSubviewHost = UIView(frame: .zero)
			self.navigationSubviewHost?.translatesAutoresizingMaskIntoConstraints = false
			self.view.addSubview(self.navigationSubviewHost)
			self.navigationSubviewHost.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
			self.navigationSubviewHost.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
			self.navigationSubviewHost.heightAnchor.constraint(equalToConstant: self.navigationSubviewHeight).isActive = true
			self.navigationSubviewHost.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.navigationSubviewOffset).isActive = true
			self.navigationSubviewHost.addSubview(view)
		}
		
		self.navigationSubviewHost.frame = CGRect(x: 0, y: self.navigationSubviewOffset, width: self.view.bounds.width, height: self.navigationSubviewHeight)
		view.translatesAutoresizingMaskIntoConstraints = false
		
		view.topAnchor.constraint(equalTo: previous?.bottomAnchor ?? self.navigationSubviewHost.topAnchor).isActive = true
		view.leadingAnchor.constraint(equalTo: self.navigationSubviewHost.leadingAnchor).isActive = true
		view.trailingAnchor.constraint(equalTo: self.navigationSubviewHost.trailingAnchor).isActive = true
		view.heightAnchor.constraint(equalToConstant: height).isActive = true

	}
	
	var navigationSubviewHeight: CGFloat {
		return self.navigationSubviewInfo.reduce(0) { $0 + $1.view.bounds.height }
	}
	
	struct NavigationSubviewInfo {
		let view: UIView
		let collapsable: Bool
	}
	
	func updateNavigationSubviewsWith(offset: CGFloat, remainingPercentage: CGFloat) {
		self.navigationSubviewHost?.transform = CGAffineTransform(translationX: 0, y: offset)
		self.navigationSubviewHost?.alpha = remainingPercentage * remainingPercentage

	}
}

/*
let height = self.navigationSubview?.bounds.height ?? 0
oldValue?.removeFromSuperview()
let navBarHeight = self.navigationController?.navigationBar.bounds.height ?? 0
self.titleView?.drawBottomDivider = view == nil
if let view = self.navigationSubview {
self.webView?.scrollView.contentInset = UIEdgeInsets(top: self.initialContentInset, left: 0, bottom: 0, right: 0)

view.translatesAutoresizingMaskIntoConstraints = false
self.view.addSubview(view)
self.subviewTopConstraint = NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: (self.currentScrollStart) + navBarHeight + self.statusBarHeight)
view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
self.view.addConstraint(self.subviewTopConstraint!)
}
*/
