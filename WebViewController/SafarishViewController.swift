//
//  SafarishViewController.swift
//  Safarish
//
//  Created by Ben Gottlieb on 12/18/16.
//  Copyright © 2016 Stand Alone, Inc. All rights reserved.
//

import UIKit
import WebKit

open class SafarishViewController: UIViewController {
	var titleBar: TitleBarView!
	var webView: WKWebView!
	var url: URL?
	var data: Data?
	
	public convenience init(url: URL) {
		self.init()
		if url.isFileURL {
			self.data = try? Data(contentsOf: url)
		} else {
			self.url = url
		}
	}
	
	public convenience init(data: Data, from url: URL?) {
		self.init()
		self.data = data
		self.url = url
	}
	
	var webViewConfiguration = WKWebViewConfiguration()
	var navigationBarWasHidden: Bool?
	
	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let nav = self.navigationController {
			if self.navigationBarWasHidden == nil {
				self.navigationBarWasHidden = nav.isNavigationBarHidden
			}
			self.navigationController?.setNavigationBarHidden(true, animated: true)
		}
	}
	
	open override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if self.titleBar == nil {
			self.webView = WKWebView(frame: self.view.bounds, configuration: self.webViewConfiguration)
			self.view.addSubview(self.webView)
			self.webView.translatesAutoresizingMaskIntoConstraints = false
			self.view.addConstraints([
				NSLayoutConstraint(item: self.webView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: self.webView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: self.webView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: self.webView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0),
				])
			self.webView.scrollView.contentInset = UIEdgeInsets(top: TitleBarView.maxHeight, left: 0, bottom: 0, right: 0)
			
			if UIDevice.current.userInterfaceIdiom == .pad {
				self.titleBar = IPadTitleBarView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: TitleBarView.maxHeight), parent: self)
			} else {
				self.titleBar = TitleBarView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: TitleBarView.maxHeight), parent: self)
			}
			self.view.addSubview(self.titleBar)
			self.view.addConstraints([
				NSLayoutConstraint(item: self.titleBar, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: self.titleBar, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: self.titleBar, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0),
				])
			
			self.webView.scrollView.delegate = self.titleBar
			self.webView.navigationDelegate = self
		}
	}
	
	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if let data = self.data {
			self.titleBar.set(url: self.url)
			self.webView.load(data, mimeType: "application/x-webarchive", characterEncodingName: "", baseURL: self.url ?? URL(string: "about:blank")!)
		} else if let url = self.url {
			self.webView.load(URLRequest(url: url))
			self.titleBar.set(url: url)
		}
	}

	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if self.navigationBarWasHidden == true {
			self.navigationController?.setNavigationBarHidden(false, animated: animated)
		}
	}
	
	func didEnterURL(_ url: URL?) {
		guard let url = url else { return }
		self.url = url
		self.webView.load(URLRequest(url: url))
	}
	
	func dismiss(animated: Bool = true) {
		if let nav = self.navigationController, nav.viewControllers.count > 1 {
			nav.popViewController(animated: animated)
		} else {
			self.dismiss(animated: animated, completion: nil)
		}
	}
}

extension SafarishViewController: WKNavigationDelegate {
	public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
		if (error as NSError).domain == "NSURLErrorDomain", (error as NSError).code == -1003 {		//couldn't find host, switch to google
			guard let current = self.url, let url = URL(string: "https://www.google.com/#q=\(current.absoluteString)") else { return }
			self.webView.load(URLRequest(url: url))
			return
		}
		print("Provisional load failed: \(error)")
	}
	
	public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		print("Navigation failed: \(error)")
	}
	
	public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		
		completionHandler(.useCredential, challenge.proposedCredential)
	}
}

