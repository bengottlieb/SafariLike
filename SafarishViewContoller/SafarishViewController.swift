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
	static let blankURL = URL(string: "about:blank")!
	deinit {
		self.clearOut()
	}
	
	override open var toolbarItems: [UIBarButtonItem]? { didSet {
		if let items = self.toolbarItems {
			let midpoint = items.count / 2
			self.ipadToolbarItems = (Array(items[0..<midpoint]), Array(items[midpoint..<items.count]))
		}
	}}
	open var ipadToolbarItems: ([UIBarButtonItem], [UIBarButtonItem])?

	public var forceCenteredURLBar = false
	public var doneButtonTitle = NSLocalizedString("Done", comment: "Done")
    open var doneButtonItem: UIBarButtonItem!
	open var pageBackButtonItem: UIBarButtonItem!
	open var pageForwardButtonItem: UIBarButtonItem!
	open var pageBackImage = UIImage(named: "safarish-page-back", in: Bundle(for: SafarishViewController.self), compatibleWith: nil)
	open var pageForwardImage = UIImage(named: "safarish-page-forward", in: Bundle(for: SafarishViewController.self), compatibleWith: nil)
	open var searchStringTemplate = "https://www.google.com/#q=%@"
	
	public var forceHTTP = false
	
	var titleBar: TitleBarView!
	var webView: WKWebView!
	var url: URL?
	var data: Data?
	
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
	}
	
	public convenience init(data: Data, from url: URL?) {
		self.init()
		self.data = data
		self.url = url
	}
	
	func setupToolbar() {
		if self.doneButtonItem == nil {
			self.doneButtonItem = UIBarButtonItem(title: self.doneButtonTitle, style: .plain, target: self, action: #selector(done))
			
			self.pageBackButtonItem = UIBarButtonItem(image: self.pageBackImage, style: .plain, target: self, action: #selector(pageBack))
			self.pageBackButtonItem.isEnabled = false
			self.pageForwardButtonItem = UIBarButtonItem(image: self.pageForwardImage, style: .plain, target: self, action: #selector(pageForward))
			self.pageForwardButtonItem.isEnabled = false

			self.toolbarItems = [ self.pageBackButtonItem, self.pageForwardButtonItem ]
			self.ipadToolbarItems = ([ self.doneButtonItem, self.pageBackButtonItem, self.pageForwardButtonItem], [])
		}
	}
	
	func clearOut() {
		self.webView?.scrollView.delegate = nil
		self.webView?.navigationDelegate = nil
		self.webView?.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView = nil
	}
	
	var webViewConfiguration = WKWebViewConfiguration()
	var navigationBarWasHidden: Bool?
	
	open override func viewWillAppear(_ animated: Bool) {
        self.updateNavigationBar()
		super.viewWillAppear(animated)
        self.setupViews()
	}
    
    func updateNavigationBar() {
        if let nav = self.navigationController {
            if self.navigationBarWasHidden == nil {
                self.navigationBarWasHidden = nav.isNavigationBarHidden
            }
            self.navigationController?.setNavigationBarHidden(true, animated: false)
			
			if UIDevice.current.userInterfaceIdiom == .phone { self.navigationController?.setToolbarHidden(false, animated: true) }
        }
    }
	
	open override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.setupViews()
    }
	
	open func createWebView(frame: CGRect, configuration: WKWebViewConfiguration) -> WKWebView {
		return WKWebView(frame: frame, configuration: configuration)
	}
    
    func setupViews() {
		if self.titleBar == nil {
            self.setupToolbar()
			self.webView = self.createWebView(frame: self.view.bounds, configuration: self.webViewConfiguration)
			self.view.addSubview(self.webView)
			self.webView.translatesAutoresizingMaskIntoConstraints = false
            self.webView.scrollView.delegate = self.titleBar
            self.webView.navigationDelegate = self
            self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: [], context: nil)

            
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
        }
	}
	
	open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "estimatedProgress", self.webView?.url != SafarishViewController.blankURL {
			self.titleBar.estimatedProgress = self.webView.estimatedProgress
			if self.webView.estimatedProgress == 1.0 { self.loadDidFinish(for: self.webView.url) }
		}
	}
	
	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        self.setupViews()
		if let data = self.data {
			self.titleBar?.set(url: self.url)
            _ = self.webView?.load(data, mimeType: "application/x-webarchive", characterEncodingName: "", baseURL: self.url ?? SafarishViewController.blankURL)
		} else if let url = self.url, url != SafarishViewController.blankURL {
			self.webView.load(URLRequest(url: url))
			self.titleBar.set(url: url)
		} else {
			self.titleBar?.beginEditingURL()
		}
	}

	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.titleBar.makeFieldEditable(false)
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
	
	func done() {
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
        self.pageBackButtonItem.isEnabled = self.webView.canGoBack
        self.pageForwardButtonItem.isEnabled = self.webView.canGoForward
    }
    
    func pageBack() {
        self.webView.goBack()
    }
    
    func pageForward() {
        self.webView.goForward()
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
		
	}
	
	public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		
	}
	
	public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
		self.titleBar.makeFullyVisible(animated: true)
	}
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
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
        self.updateBarButtons()
	}
	
	public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		print("Navigation failed: \(error)")
        self.updateBarButtons()
	}
	
	open func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		completionHandler(.useCredential, challenge.proposedCredential)
	}
}

