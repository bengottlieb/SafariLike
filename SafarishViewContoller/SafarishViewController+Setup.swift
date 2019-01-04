//
//  SafarishViewController+Setup.swift
//  Safarish
//
//  Created by Ben Gottlieb on 1/1/19.
//  Copyright © 2019 Stand Alone, Inc. All rights reserved.
//

import UIKit
import WebKit

extension SafarishViewController {
	open func updateTopBarHeight() {
		self.topbar.frame = self.topbarFrame
	}
	
	open func setup() {
		self.navigationItem.leftBarButtonItems = [self.doneButtonItem, self.pageBackButtonItem, self.pageForwardButtonItem]
		
		if self.webview == nil {
			self.view.backgroundColor = .white
			
			self.webview = self.webviewClass.init(frame: self.webviewFrame)
			self.webview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			self.webview.scrollView.contentInsetAdjustmentBehavior = .never
			self.webview.scrollView.layer.masksToBounds = false
			self.webview.clipsToBounds = false
			self.webview.uiDelegate = self
			self.webview.navigationDelegate = self
			self.webview.scrollView.delegate = self
			self.view.addSubview(self.webview)
		}
		
		if self.topbar == nil {
			self.topbar = SafarishNavigationBar(frame: self.topbarFrame, in: self)
			self.topbar.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
			self.view.addSubview(self.topbar)
			self.topbar.backgroundColor = self.view.backgroundColor
			
			self.titleView = SafarishURLEntryField(in: self)
			self.topbar.urlEntryField = self.titleView
			self.titleView.url = self.url
			self.topbar.updateNavigationItems()
		}
		
		self.forwardButtonEnabled = false
		
		self.loadInitialContent()
	}
	
	open func setTopBarHeight(_ height: CGFloat) {
		let minHeight = max(20, height)
		let perc = height / self.topBarMaxHeight
		self.titleView?.shrinkPercentage = 1.0 - perc
		self.topbar?.shrinkPercentage = 1.0 - perc
		self.topBarCurrentHeight = minHeight
		self.updateTopBarHeight()
	}
	
	open func loadInitialContent() {
		self.backButtonEnabled = false
		if self.webview == nil { return }
		if let data = self.data {
			self.state = .loading
			_ = self.webview?.load(data, mimeType: "application/x-webarchive", characterEncodingName: "", baseURL: self.url ?? URL.blank)
		} else if let html = self.html {
			self.state = .loading
			self.webview?.loadHTMLString(html, baseURL: URL(fileURLWithPath: "/"))
		} else if let url = self.url, url != URL.blank {
			self.state = .loading
			self.webview?.load(URLRequest(url: url))
		} else {
			
		}
	}
}
