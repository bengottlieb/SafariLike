//
//  SafarishViewController+Computed.swift
//  Safarish
//
//  Created by Ben Gottlieb on 1/1/19.
//  Copyright © 2019 Stand Alone, Inc. All rights reserved.
//

import UIKit
import WebKit

extension SafarishViewController {
	var toolbarHeight: CGFloat { return 44 }
	open var topBarMaxHeight: CGFloat { return self.toolbarHeight }
	
	var toolbarFrame: CGRect {
		let height = self.topBarCurrentHeight ?? self.toolbarHeight
		return CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.safeAreaInsets.top + height)
	}
	
	var webviewFrame: CGRect {
		let topHeight = self.topBarMaxHeight + self.view.safeAreaInsets.top
		var frame = self.view.bounds
		frame.origin.y += topHeight
		frame.size.height -= topHeight
		return frame
//		return self.view.frame
	}
	var webviewClass: WKWebView.Type { return WKWebView.self }

	var isIPad: Bool { return UIDevice.current.userInterfaceIdiom == .pad }
	var isBlank: Bool {
		if self.data?.isEmpty == false { return false }
		if self.html?.isEmpty == false { return false }
		if self.url?.isEmpty == false { return false }
		return true
	}
}

extension SafarishViewController {
	public enum State { case idle, loading, loaded, reloading }
}
