//
//  SafarishViewController.swift
//  Safarish
//
//  Created by Ben Gottlieb on 1/1/19.
//  Copyright © 2019 Stand Alone, Inc. All rights reserved.
//

import UIKit
import WebKit


open class SafarishViewController: UIViewController {
	var html: String?
	var data: Data?
	var url: URL? { didSet {
		self.titleView.url = self.url
	}}
	var titleView: SafarishURLEntryField!
	
	var toolbar: UIToolbar!
	var webview: WKWebView!
	var topBarCurrentHeight: CGFloat?
	
	var state: State = .idle
	
	public convenience init(url: URL?) {
		self.init()
		if let url = url {
			if url.isFileURL {
				self.data = try? Data(contentsOf: url)
			} else {
				self.url = url
			}
		} else {
			self.url = URL.blank
		}
		self.setup()
	}
	
	public convenience init(data: Data, from url: URL?) {
		self.init()
		self.data = data
		self.url = url
		self.setup()
	}
	
	public convenience init(html: String, from url: URL?) {
		self.init()
		self.html = html
		self.url = url
		self.setup()
	}

	
	func reload() {
		
	}
	
	func didEnterURL(_ url: URL) {
		
	}
	
}
