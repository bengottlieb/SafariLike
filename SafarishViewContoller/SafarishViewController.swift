//
//  SafarishViewController.swift
//  Safarish
//
//  Created by Ben Gottlieb on 12/18/16.
//  Copyright © 2016 Stand Alone, Inc. All rights reserved.
//

import UIKit
import WebKit

public typealias BarButtonItemsSet = (left: [UIBarButtonItem], right: [UIBarButtonItem])

open class SafarishViewController: UIViewController {
	static let blankURL = URL(string: "about:blank")!
	deinit {
		self.clearOut()
	}
	
//	override open var toolbarItems: [UIBarButtonItem]? { didSet {
//		if let items = self.toolbarItems {
//			let midpoint = items.count / 2
//			self.barButtonItems = (left: Array(items[..<midpoint]), right: Array(items[midpoint...]))
//		}
//	}}
	open var barButtonItems: BarButtonItemsSet! { didSet {
		self.loadNavigationBarButtonItems()
	}}

	public var forceCenteredURLBar = false
	public var doneButtonTitle = NSLocalizedString("Done", comment: "Done")
    open var doneButtonItem: UIBarButtonItem!
	open var pageBackButtonItem: UIBarButtonItem!
	open var pageForwardButtonItem: UIBarButtonItem!
	open var pageBackImage = UIImage(named: "safarish-page-back", in: Bundle(for: SafarishViewController.self), compatibleWith: nil)
	open var pageForwardImage = UIImage(named: "safarish-page-forward", in: Bundle(for: SafarishViewController.self), compatibleWith: nil)
	open var searchStringTemplate = "https://www.google.com/#q=%@"
	
	public var forceHTTP = false
	
	var webView: WKWebView!
	var url: URL? { didSet { self.titleView?.urlField.url = self.url }}
	var currentURL: URL? { return self.webView?.url ?? self.url }
	var data: Data?
	var html: String?
	var titleView: SafarishNavigationTitleView!
	var isIPad: Bool { return UIDevice.current.userInterfaceIdiom == .pad }
	
	public convenience init(url: URL?) {
		self.init()
		if let url = url {
			if url.isFileURL {
				self.data = try? Data(contentsOf: url)
			} else {
				self.url = url
			}
		} else {
			self.url = SafarishViewController.blankURL
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
	
	func loadNavigationBarButtonItems() {
		if self.isIPad {
			self.titleView.leftBarButtonItems = self.barButtonItems.left
			self.titleView.rightBarButtonItems = self.barButtonItems.right
		} else {
			self.hidesBottomBarWhenPushed = false
			self.toolbarItems = (self.barButtonItems.left + self.barButtonItems.right).flatMap({
				return [$0, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)]
			})
			self.toolbarItems?.removeLast()
		}
	}
	
	func setup() {
		self.setupNavigationItem()
	}
	
	func setupNavigationItem() {
		if self.titleView == nil {
			self.titleView = SafarishNavigationTitleView(in: self)
			self.navigationItem.titleView = self.titleView
			self.titleView.urlField.url = self.url
		}

		if self.doneButtonItem == nil {
			self.doneButtonItem = UIBarButtonItem(title: self.doneButtonTitle, style: .plain, target: self, action: #selector(done))
			self.doneButtonItem.width = 50
			
			self.pageBackButtonItem = UIBarButtonItem(image: self.pageBackImage, style: .plain, target: self, action: #selector(pageBack))
			self.pageBackButtonItem.isEnabled = false
			self.pageBackButtonItem.width = 30
			self.pageForwardButtonItem = UIBarButtonItem(image: self.pageForwardImage, style: .plain, target: self, action: #selector(pageForward))
			self.pageForwardButtonItem.isEnabled = false
			self.pageForwardButtonItem.width = 30

		//	self.toolbarItems = [ self.pageBackButtonItem, self.pageForwardButtonItem ]
			self.barButtonItems = ( left: [ self.doneButtonItem, self.pageBackButtonItem, self.pageForwardButtonItem ], right: [] )
		}
		
		self.navigationItem.leftBarButtonItems = []
		self.navigationItem.rightBarButtonItems = []
		self.navigationItem.hidesBackButton = true

		self.loadNavigationBarButtonItems()
	}
	
	
	var shouldObserveEstimatedProgress: Bool = false {
		didSet {
			if self.shouldObserveEstimatedProgress == oldValue { return }
			
			if self.shouldObserveEstimatedProgress {
				self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: [], context: nil)
			} else {
				self.webView?.removeObserver(self, forKeyPath: "estimatedProgress")
			}
			
		}
	}
	
	func clearOut() {
		self.webView?.removeObserver(self, forKeyPath: "canGoBack")
		self.webView?.removeObserver(self, forKeyPath: "canGoForward")

		self.shouldObserveEstimatedProgress = false
		self.webView?.scrollView.delegate = nil
		self.webView?.navigationDelegate = nil
        self.webView = nil
	}
	
	var webViewConfiguration = WKWebViewConfiguration()
	var navigationBarWasHidden: Bool?
	
	open override func viewWillAppear(_ animated: Bool) {
        self.updateNavigationBar()
		super.viewWillAppear(animated)
	}
	
	var canGoBack: Bool {
		if let url = self.url?.normalized, url != self.webView.url?.normalized { return true }
		return self.webView.canGoBack
	}
	
	var canGoForward: Bool {
		return self.webView.canGoForward
	}
    
    func updateNavigationBar() {
//        if let nav = self.navigationController {
//            if self.navigationBarWasHidden == nil {
//                self.navigationBarWasHidden = nav.isNavigationBarHidden
//            }
//            self.navigationController?.setNavigationBarHidden(true, animated: false)
//
//			if UIDevice.current.userInterfaceIdiom == .phone { self.navigationController?.setToolbarHidden(false, animated: true) }
//        }
    }
	
	open override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.titleView.viewWidth = self.view.bounds.width
    }
	
	open func createWebView(frame: CGRect, configuration: WKWebViewConfiguration) -> WKWebView {
		return WKWebView(frame: frame, configuration: configuration)
	}
    
    func setupViews() {
		if self.webView == nil {
			self.webView = self.createWebView(frame: self.view.bounds, configuration: self.webViewConfiguration)
			self.view.addSubview(self.webView)
			self.webView.translatesAutoresizingMaskIntoConstraints = false
            self.webView.scrollView.delegate = self
            self.webView.navigationDelegate = self
			
			self.webView.addObserver(self, forKeyPath: "canGoBack", options: [], context: nil)
			self.webView.addObserver(self, forKeyPath: "canGoForward", options: [], context: nil)
			
            self.view.addConstraints([
				NSLayoutConstraint(item: self.webView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: self.webView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: self.webView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: self.webView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0),
			])
//			self.webView.scrollView.contentInset = UIEdgeInsets(top: TitleBarView.maxHeight, left: 0, bottom: 0, right: 0)
		}
	}
	
	open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "estimatedProgress", self.webView?.url != SafarishViewController.blankURL {
			self.titleView?.estimatedProgress = CGFloat(self.webView?.estimatedProgress ?? 0)
			if self.webView.estimatedProgress == 1.0 { self.loadDidFinish(for: self.webView.url) }
		} else if keyPath == "canGoBack" {
			self.pageBackButtonItem.isEnabled = self.canGoBack
		} else if keyPath == "canGoForward" {
			self.pageForwardButtonItem.isEnabled = self.canGoForward
		}
	}
	
	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        self.setupViews()
		self.loadInitialContent()
		if !self.isIPad { self.navigationController?.setToolbarHidden(false, animated: true) }
		//self.setupNavigationItem()
	}
	
	func loadInitialContent() {
		if let data = self.data {
			self.updateURLField()
			_ = self.webView?.load(data, mimeType: "application/x-webarchive", characterEncodingName: "", baseURL: self.url ?? SafarishViewController.blankURL)
		} else if let url = self.url, url != SafarishViewController.blankURL {
			self.webView.load(URLRequest(url: url))
			self.updateURLField()
		} else if let html = self.html {
			self.webView.loadHTMLString(html, baseURL: self.url)
		} else {
		}
	}

	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.titleView?.urlField.cancelEditing()
		if self.navigationBarWasHidden == false {
			self.navigationController?.setNavigationBarHidden(false, animated: animated)
		}
	}
	
	func didEnterURL(_ url: URL?) {
		guard let url = url else { return }

		if url != self.url {
			self.forceHTTP = false
		}
		
		if self.forceHTTP, url.scheme == "https", var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
			components.scheme = "http"
			self.url = components.url
		} else {
			self.url = url
		}
		
		DispatchQueue.main.async {
			self.webView.load(URLRequest(url: self.url!))
		}
	}
	
	@objc func done() {
		self.dismiss(animated: true)
	}
	
	open func dismiss(animated: Bool) {
		self.clearOut()
		if let nav = self.navigationController, nav.viewControllers.count > 1 {
			nav.popViewController(animated: animated)
		} else {
			self.dismiss(animated: animated, completion: nil)
		}
	}
	
	open func loadDidFinish(for: URL?) { }
}

extension SafarishViewController {
	func updateBarButtons() {
		self.pageBackButtonItem?.isEnabled = self.canGoBack
		self.pageForwardButtonItem?.isEnabled = self.canGoForward
	}
	
    @objc func pageBack() {
		if !self.webView.canGoBack {			// if we started off with a webarchive, we'll need to reload it here
			self.loadInitialContent()
		} else {
			self.webView.goBack()
		}
    }
    
    @objc func pageForward() {
        self.webView.goForward()
    }
	
	func updateURLField() {
		self.titleView?.urlField.url = self.url
	}
}

extension SafarishViewController: WKNavigationDelegate {
	public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
		decisionHandler(.allow)
	}
	
	public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void) {
		decisionHandler(.allow)
	}
	
	public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
		self.updateURLField()
	}
	
	public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		self.updateURLField()
		self.shouldObserveEstimatedProgress = true
	}
	
	public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
		//self.titleBar?.makeFullyVisible(animated: true)
	}
	
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		self.shouldObserveEstimatedProgress = false
		self.updateBarButtons()
    }
    
	public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
		if (error as NSError).domain == "NSURLErrorDomain", (error as NSError).code == -1003 {		//couldn't find host, switch to google
			guard let current = self.url, let url = URL(string: "https://www.google.com/#q=\(current.absoluteString)") else { return }
			self.webView.load(URLRequest(url: url))
			return
		}

		if (error as NSError).domain == "NSURLErrorDomain", (error as NSError).code == -1200, !self.forceHTTP {		//SSL Error
			self.forceHTTP = true
			self.didEnterURL(self.url)
			return
		}
		print("Provisional load failed: \(error)")
	}
	
	public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		self.shouldObserveEstimatedProgress = false
	}
	
	open func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		completionHandler(.useCredential, challenge.proposedCredential)
	}
}

extension SafarishViewController: UIScrollViewDelegate {
	
}
