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
		self.toolbar.frame = self.toolbarFrame
	}
	
	open func setup() {
		if self.webview == nil {
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
		
		if self.toolbar == nil {
			self.toolbar = UIToolbar(frame: self.toolbarFrame)
			self.toolbar.barTintColor = .red
			self.toolbar.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
			self.view.addSubview(self.toolbar)
			
			self.titleView = SafarishURLEntryField(in: self)
			self.toolbar.addSubview(self.titleView)
			self.titleView.url = self.url
			self.titleView.translatesAutoresizingMaskIntoConstraints = false
			self.titleView.centerXAnchor.constraint(equalTo: self.toolbar.centerXAnchor).isActive = true
			self.titleView.centerYAnchor.constraint(equalTo: self.toolbar.centerYAnchor).isActive = true
		}
		
		self.loadContent()
	}
	
	open func setTopBarHeight(_ height: CGFloat) {
		self.topBarCurrentHeight = height
		self.updateTopBarHeight()
	}
	
	open func loadContent() {
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
