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

open class NavBarSafarishViewController: UIViewController {
	deinit {
		self.clearOut()
	}
	
	open var barButtonItems: BarButtonItemsSet! { didSet { self.loadBarButtonItems() }}
	public var forceCenteredURLBar = false
	public var doneButtonTitle = NSLocalizedString("Done", comment: "Done")
    open var doneButtonItem: UIBarButtonItem!
	open var pageBackButtonItem: UIBarButtonItem!
	open var pageForwardButtonItem: UIBarButtonItem!
	open var pageBackImage = UIImage(named: "safarish-page-back", in: Bundle(for: NavBarSafarishViewController.self), compatibleWith: nil)
	open var pageForwardImage = UIImage(named: "safarish-page-forward", in: Bundle(for: NavBarSafarishViewController.self), compatibleWith: nil)
	open var searchStringTemplate = "https://www.google.com/#q=%@"
	open var autoHideToolbar = true
	open var showBackForwardButtons = true
	var enabledAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black] { didSet { (self.titleView as? SafarishNavigationURLView)?.enabledAttributes = self.enabledAttributes }}
	var disabledAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black] { didSet { (self.titleView as? SafarishNavigationURLView)?.disabledAttributes = self.disabledAttributes }}

	open var allowURLEditing = true { didSet {
		if !self.allowURLEditing { self.urlFieldEnabled = false }
	}}

	public var minNavigationBarHeight: CGFloat = 20
	public var maxNavigationBarHeight: CGFloat = 44
	public var maxNavigationReduction: CGFloat { return self.maxNavigationBarHeight - self.minNavigationBarHeight }
	var isNavigationBarMinimized = false { didSet {
		if self.autoHideToolbar {
			self.navigationController?.setToolbarHidden(self.isNavigationBarMinimized, animated: true)
		}
	}}
	var hasLoaded = false
	
	public var widthDeterminingViewController: UIViewController?
	public var areNavigationControlsHidden: Bool = false { didSet {
		self.titleView?.areNavigationControlsHidden = self.areNavigationControlsHidden
		self.barButtonItems.left = self.areNavigationControlsHidden ? [self.doneButtonItem] : [ self.doneButtonItem, self.pageBackButtonItem, self.pageForwardButtonItem ]
		self.loadBarButtonItems()
	}}
	
	var statusBarHeight: CGFloat = 20
	public var scrollableNavigationBar: UINavigationBar?
	var currentScrollStart: CGFloat = 0
	
	public var forceHTTP = false
	
	var navigationSubviewHost: UIView!
	var navigationSubviewInfo: [NavigationSubviewInfo] = []
	
	var webView: WKWebView! { didSet {
		print("Webview: \(self.webView?.description ?? "no web view")")
	}}
	var subviewTopConstraint: NSLayoutConstraint!
	var url: URL? { didSet { self.titleView?.currentURL = self.url }}
	var currentURL: URL? { return self.webView?.url ?? self.url }
	var data: Data?
	var html: String?
	var titleView: SafarishNavigationTitleView! { didSet {
		self.navigationItem.titleView = self.titleView as? UIView
		self.titleView.leftBarButtonItems = oldValue?.leftBarButtonItems ?? []
		self.titleView.rightBarButtonItems = oldValue?.rightBarButtonItems ?? []
	}}
	var isLoading = false {
		didSet {
			if self.isLoading == false, oldValue == true {
				self.didFinishLoading()
			} else if self.isLoading == true, oldValue == false {
				self.didStartLoading()
			}
		}
	}
	var isIPad: Bool { return UIDevice.current.userInterfaceIdiom == .pad }
	var isBlank: Bool {
		if let data = self.data, !data.isEmpty { return false }
		if let html = self.html, !html.isEmpty { return false }
		if self.url != nil, self.url != URL.blank { return false }
		return true
	}
	
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
	
	func unlinkWebView(_ webView: WKWebView?) {
		webView?.removeFromSuperview()
		webView?.removeObserver(self, forKeyPath: "title")
		webView?.removeObserver(self, forKeyPath: "canGoBack")
		webView?.removeObserver(self, forKeyPath: "canGoForward")
		webView?.removeObserver(self, forKeyPath: "backForwardList")
		webView?.removeObserver(self, forKeyPath: "estimatedProgress")

		webView?.scrollView.delegate = nil
		webView?.navigationDelegate = nil
		webView?.uiDelegate = nil
	}
	
	func loadBarButtonItems() {
		if self.isIPad, self.titleView != nil {
			self.titleView.leftBarButtonItems = self.barButtonItems?.left ?? []
			self.titleView.rightBarButtonItems = self.barButtonItems?.right ?? []
			
			self.titleView.rightBarButtonItems.forEach { item in
				if item.width == 0 { item.width = UIBarButtonItem.defaultSafarishItemWidth }
			}
			
		} else {
			self.hidesBottomBarWhenPushed = false
			self.toolbarItems = (self.barButtonItems.left + self.barButtonItems.right).flatMap({
				return [$0, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)]
			})
			self.toolbarItems?.removeLast()
		}
	}
	
	func setup() { }
	
	func setupBarButtonItems() {
		if self.titleView == nil {
			self.titleView = SafarishNavigationURLView(in: self)
			(self.titleView as? UIView)?.tintColor = self.view.tintColor
			(self.titleView as? SafarishNavigationURLView)?.enabledAttributes = self.enabledAttributes
			(self.titleView as? SafarishNavigationURLView)?.disabledAttributes = self.disabledAttributes
			self.titleView.currentURL = self.url
			self.titleView.areNavigationControlsHidden = self.areNavigationControlsHidden
		}

		if self.doneButtonItem == nil {
			self.doneButtonItem = UIBarButtonItem(title: self.doneButtonTitle, style: .plain, target: self, action: #selector(done))
			self.doneButtonItem.width = 50
		}
		
		if self.pageBackButtonItem == nil {
			self.pageBackButtonItem = UIBarButtonItem(image: self.pageBackImage, style: .plain, target: self, action: #selector(pageBack))
			self.goBackButtonEnabled = false
			self.pageBackButtonItem.width = UIBarButtonItem.defaultSafarishItemWidth
		}

		if self.pageForwardButtonItem == nil {
			self.pageForwardButtonItem = UIBarButtonItem(image: self.pageForwardImage, style: .plain, target: self, action: #selector(pageForward))
			self.goForwardButtonEnabled = false
			self.pageForwardButtonItem.width = UIBarButtonItem.defaultSafarishItemWidth
		}
		
		var left: [UIBarButtonItem] = [self.doneButtonItem]
		if self.showBackForwardButtons { left += [self.pageBackButtonItem, self.pageForwardButtonItem] }
		self.barButtonItems = ( left: left, right: [] )

		self.navigationItem.leftBarButtonItems = []
		self.navigationItem.rightBarButtonItems = []
		self.navigationItem.hidesBackButton = true

		self.loadBarButtonItems()
	}
	
	public func reload() {
		self.webView?.reload()
	}
	
	open func load(request: URLRequest) {
		self.url = request.url
		self.titleView.currentURL = self.url
		self.webView.load(request)
	}
	
	func clearOut() {
		self.unlinkWebView(self.webView)
		self.webView = nil
	}
	
	var webViewConfiguration = WKWebViewConfiguration()
	var navigationBarWasHidden: Bool?
	var userAgent: String? { didSet { self.webView?.customUserAgent = self.userAgent }}
	
	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.scrollableNavigationBar = self.navigationController?.navigationBar
	}
	
	var canGoBack: Bool {
		if let url = self.url?.normalized, url != self.webView.url?.normalized { return true }
		return self.webView.canGoBack
	}
	
	var canGoForward: Bool {
		return self.webView.canGoForward
	}
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		
		self.currentScrollStart = -(self.maxNavigationBarHeight + 20)
		self.setupBarButtonItems()
	}

	open override func viewDidLayoutSubviews() {
		self.statusBarHeight = self.view.safeAreaInsets.top
		super.viewDidLayoutSubviews()
		self.titleView.viewWidth = (self.widthDeterminingViewController ?? self).view.bounds.width
		self.setupViews()
    }
	
	open func createWebView(frame: CGRect, configuration: WKWebViewConfiguration) -> WKWebView {
		return WKWebView(frame: frame, configuration: configuration)
	}
	
	
	func linkWebView(_ webView: WKWebView) {
		self.unlinkWebView(self.webView)
		
		self.webView = webView
		self.webView.scrollView.delegate = self
		self.webView.navigationDelegate = self
		self.webView.customUserAgent = self.userAgent
		
		self.webView.addObserver(self, forKeyPath: "canGoBack", options: [], context: nil)
		self.webView.addObserver(self, forKeyPath: "canGoForward", options: [], context: nil)
		self.webView.addObserver(self, forKeyPath: "backForwardList", options: [], context: nil)
		self.webView.addObserver(self, forKeyPath: "title", options: [], context: nil)
		self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: [], context: nil)
		self.webView.scrollView.contentInsetAdjustmentBehavior = .never
		
		var offset = self.currentScrollStart
		if let view = self.navigationSubviewHost { offset -= view.bounds.height }
		self.webView.scrollView.contentInset = UIEdgeInsets(top: self.initialContentInset, left: 0, bottom: 0, right: 0)
		if !self.hasLoaded { self.loadInitialContent() }
	}
	
	var webviewFrame: CGRect { return self.view.bounds }
	func setupViews() {
		if self.webView == nil {
			let webView = self.createWebView(frame: self.webviewFrame, configuration: self.webViewConfiguration)
			self.view.addSubview(webView)
			webView.translatesAutoresizingMaskIntoConstraints = false
			
			let topOffset: CGFloat = self.isIPad ? -64 : 0
			webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
			webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
			webView.topAnchor.constraint(equalTo: view.topAnchor, constant: topOffset).isActive = true
			webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
			self.linkWebView(webView)
		}
		if let view = self.navigationSubviewHost { self.view.bringSubviewToFront(view) }
	}

	open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		let progress = CGFloat(webView.estimatedProgress)
		if self.webView.url == URL.blank { return }
		if progress != 0.0, !self.isLoading {
			self.isLoading = true
		} else if progress == 1.0, self.isLoading {
			self.isLoading = false
			self.loadDidFinish(for: self.webView.url)
		}
		self.titleView?.estimatedProgress = progress
	}
	
	func updateNavigationButtons() {
		self.goBackButtonEnabled = self.canGoBack
		self.goForwardButtonEnabled = self.canGoForward
	}
	
	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if !self.hasLoaded { self.loadInitialContent() }
		self.navigationController?.setNavigationBarHidden(false, animated: true)
		self.navigationController?.setToolbarHidden(self.isIPad, animated: true)
		if self.isBlank { self.titleView?.isEditing = true }
	}
	
	func loadInitialContent() {
		if self.webView == nil { return }
		if let data = self.data {
			self.hasLoaded = true
			self.updateURLField()
			_ = self.webView?.load(data, mimeType: "application/x-webarchive", characterEncodingName: "", baseURL: self.url ?? URL.blank)
		} else if let html = self.html {
			self.hasLoaded = true
			self.webView?.loadHTMLString(html, baseURL: URL(fileURLWithPath: "/"))
		} else if let url = self.url, url != URL.blank {
			self.hasLoaded = true
			self.webView?.load(URLRequest(url: url))
			self.updateURLField()
		} else {
			
		}
	}

	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.titleView?.isEditing = false
	}
	
	func didEnterURL(_ url: URL?) {
		guard let url = url else { return }

		if url != self.url { self.forceHTTP = false }
		
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
	
	open func loadDidFinish(for: URL?) {
		if let title = self.webView?.title, !title.isEmpty {
			self.title = title
		}
	}
	
	open func didStartLoading() {
		DispatchQueue.main.async { self.resetNavigationBar() }

		if let url = self.webView.url, !url.isFileURL {
			self.titleView?.currentURL = self.url
		}
		
	}
	open func didFinishLoading() { }
	
	var initialContentInset: CGFloat { return (self.maxNavigationBarHeight + 20 + (self.navigationSubviewHost?.bounds.height ?? 0)) }
	
	func resetNavigationBar(animated: Bool = true) {
		self.currentScrollStart = -(self.maxNavigationBarHeight + 20)
		self.isNavigationBarMinimized = false
		UIView.animate(withDuration: animated ? 0.2 : 0.0) {
			self.titleView.shrinkPercentage = 0.0
			self.scrollableNavigationBar?.transform = .identity
		}
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
	
	var goForwardButtonEnabled: Bool = false { didSet { self.pageForwardButtonItem.isEnabled = self.goForwardButtonEnabled }}
	var goBackButtonEnabled: Bool = false { didSet { self.pageBackButtonItem.isEnabled = self.goBackButtonEnabled }}
	
	open func webViewScrollChanged(to: Double) { }
	open func finishedScrolling(to: Double) { }
}

extension NavBarSafarishViewController {
	func updateBarButtons() {
		self.goBackButtonEnabled = self.canGoBack
		self.goForwardButtonEnabled = self.canGoForward
	}
	
	func updateURLField() {
		if let url = self.webView?.url, !url.isFileURL {
			self.url = url
		}
	}
}

extension NavBarSafarishViewController {
	var urlFieldEnabled: Bool {
		get { return self.titleView?.isEnabled ?? false }
		set { self.titleView?.isEnabled = self.allowURLEditing && newValue }
	}
}


