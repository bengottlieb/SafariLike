//
//  SafarishViewController+Actions.swift
//  Safarish
//
//  Created by Ben Gottlieb on 1/3/19.
//  Copyright © 2019 Stand Alone, Inc. All rights reserved.
//

import UIKit

extension SafarishViewController {
	func updateNavigationButtons() {
		self.backButtonEnabled = self.webview.canGoBack
		self.forwardButtonEnabled = self.webview.canGoForward
	}
	
	@objc func pageBack() {
		if self.webview.canGoBack {
			self.webview.goBack()
		} else {
			self.loadInitialContent()
		}
	}
	
	@objc func pageForward() {
		self.webview.goForward()
	}
	
	@objc func done() {
		self.navigationController?.popViewController(animated: true)
	}
}
