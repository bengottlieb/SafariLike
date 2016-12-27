//
//  WebViewController.swift
//  Safarish
//
//  Created by Ben Gottlieb on 12/18/16.
//  Copyright © 2016 Stand Alone, Inc. All rights reserved.
//

import UIKit
import WebKit
//import Gulliver

class WebViewController: UIViewController {
	var titleBar: TitleBar!
	var webView: WKWebView!
	var url: URL?
	
	convenience init(url: URL) {
		self.init()
		self.url = url
	}
	
	var webViewConfiguration = WKWebViewConfiguration()
	
	override func viewDidLayoutSubviews() {
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
			self.webView.scrollView.contentInset = UIEdgeInsets(top: TitleBar.maxHeight, left: 0, bottom: 0, right: 0)
			
			self.titleBar = TitleBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: TitleBar.maxHeight))
			self.view.addSubview(self.titleBar)
			self.titleBar.translatesAutoresizingMaskIntoConstraints = false
			self.view.addConstraints([
				NSLayoutConstraint(item: self.titleBar, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: self.titleBar, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: self.titleBar, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0),
			])

			self.titleBar.setup()
			self.webView.scrollView.delegate = self.titleBar
			self.webView.navigationDelegate = self
			self.titleBar.webViewController = self
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if let url = self.url {
			self.webView.load(URLRequest(url: url))
			self.titleBar.set(url: url)
		}
	}
	
	func didEnterURL(_ url: URL?) {
		guard let url = url else { return }
		self.url = url
		self.webView.load(URLRequest(url: url))
	}
}

extension WebViewController: WKNavigationDelegate {
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

extension WebViewController {
	
	class TitleBar: UIView, UIScrollViewDelegate, UITextFieldDelegate {
		static let maxHeight: CGFloat = 64
		static let minHeight: CGFloat = 40
		
		weak var webViewController: WebViewController!
		var originalText: String = ""
		var fieldBackgroundMargin: CGFloat = 10
		var fieldBackgroundMaxMargin: CGFloat = 10
		var fieldBackgroundHeight: CGFloat = 27
		var fieldBackground: UIView!
		var cancelButtonRight: CGFloat = 60.0
		let fieldBackgroundTopMargin: CGFloat = 20
		var effectiveScrollTop: CGFloat!
		var scrollView: UIScrollView?
		var editing = false
		var cancelButton: UIButton!
		var cancelButtonRightConstraint: NSLayoutConstraint!
		var isCancelButtonVisible = false { didSet {
			self.cancelButtonRightConstraint?.constant = self.isCancelButtonVisible ? -self.fieldBackgroundMargin : self.cancelButtonRight
		}}
		
		var urlField: UITextField!
		var urlFieldFont: UIFont {
			return UIFont.systemFont(ofSize: 12 + self.displayedHeightFraction * 4)
		}
		
		func tapped() {
			guard let scrollView = self.scrollView else { return }
			
			if self.displayedHeightFraction != 1.0 {
				let delta = (TitleBar.maxHeight - TitleBar.minHeight)
				self.effectiveScrollTop = scrollView.contentOffset.y - delta
			
				scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: self.effectiveScrollTop), animated: true)
			} else {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.makeFieldEditable(true) }
			}
		}
		
		func makeFieldEditable(_ editable: Bool) {
			let str = NSAttributedString(string: self.urlField.text ?? "", attributes: [NSFontAttributeName: self.urlField.font!])
			let size = str.size()
			let offset = ((self.urlField.bounds.width - size.width) / 2) - 2
			let duration: TimeInterval = 0.2

			if editable {
				if self.editing { return }
				self.editing = true
				self.isCancelButtonVisible = true
				self.originalText = self.urlField.text ?? ""
				UIView.animate(withDuration: duration, animations: {
					self.updateConstraintsIfNeeded()
					self.urlField.transform = CGAffineTransform(translationX: -(offset - self.cancelButtonRight / 2), y: 0)
				}) { complete in
					self.urlField.isUserInteractionEnabled = true
					self.cancelButton.isUserInteractionEnabled = true
					self.urlField.transform = CGAffineTransform.identity
					self.urlField.textAlignment = .left
					self.urlField.selectAll(nil)
					self.urlField.clearButtonMode = .whileEditing
				}
			} else {
				if !self.editing { return }
				self.isCancelButtonVisible = false
				self.urlField.clearButtonMode = .never
				self.urlField.isUserInteractionEnabled = false
				self.cancelButton.isUserInteractionEnabled = false

				UIView.animate(withDuration: duration, animations: {
					self.updateConstraintsIfNeeded()
					self.urlField.transform = CGAffineTransform(translationX: offset + self.cancelButtonRight / 2, y: 0)
				}) { complete in
					self.urlField.transform = CGAffineTransform.identity
					self.urlField.textAlignment = .center
					self.editing = false
				}
			}
		}
		
		func cancelEditing() {
			self.urlField.text = self.originalText
			self.makeFieldEditable(false)
		}
		
		var currentHeight = TitleBar.maxHeight
		var displayedHeightFraction: CGFloat = 1.0 { didSet {
			if self.displayedHeightFraction == oldValue { return }
			
			let maxDelta = TitleBar.maxHeight - TitleBar.minHeight
			self.currentHeight = TitleBar.minHeight + maxDelta * self.displayedHeightFraction
			
		//	self.fieldBackgroundMargin = self.fieldBackgroundMaxMargin * self.displayedHeightFraction
			self.fieldBackground.translatesAutoresizingMaskIntoConstraints = false
			
			//self.backgroundTopConstraint.constant = (self.fieldBackgroundMargin + self.fieldBackgroundTopMargin)
			//self.backgroundBottomConstraint.constant = -self.fieldBackgroundMargin

			self.fieldBackground.alpha = self.displayedHeightFraction * self.displayedHeightFraction
			self.titleHeightConstraint.constant = self.currentHeight
			self.urlField.font = self.urlFieldFont
			if self.displayedHeightFraction != 1.0 {
				self.urlField.isUserInteractionEnabled = false
				self.urlField.textAlignment = .center
			}
		}}
		
		func set(url: URL) {
			let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
			var name = components?.host ?? ""
			if name.hasPrefix("www.") { name = name.substring(from: name.index(name.startIndex, offsetBy: 4)) }
			self.urlField.text = name
		}

		var titleHeightConstraint: NSLayoutConstraint!
		var backgroundTopConstraint: NSLayoutConstraint!
		var backgroundBottomConstraint: NSLayoutConstraint!
		
		func setup() {
			self.titleHeightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: TitleBar.maxHeight)
			self.addConstraint(self.titleHeightConstraint)
			self.backgroundColor = UIColor.white
			self.contentMode = .redraw
			let contentHeight = self.bounds.height - self.fieldBackgroundTopMargin
			
			let backgroundWidth = (self.bounds.width - self.fieldBackgroundMargin * 2)
			let backgroundHeight = (contentHeight - self.fieldBackgroundMargin * 2)
			self.fieldBackground = UIView(frame: CGRect(x: self.fieldBackgroundMargin, y: self.fieldBackgroundMargin + self.fieldBackgroundTopMargin, width: backgroundWidth, height: backgroundHeight))
			self.addSubview(self.fieldBackground)
			self.fieldBackground.translatesAutoresizingMaskIntoConstraints = false
			self.backgroundTopConstraint = NSLayoutConstraint(item: self.fieldBackground, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: (self.fieldBackgroundMargin + self.fieldBackgroundTopMargin))
			self.backgroundBottomConstraint = NSLayoutConstraint(item: self.fieldBackground, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -self.fieldBackgroundMargin)
			self.fieldBackground.layer.cornerRadius = 5
			self.fieldBackground.layer.masksToBounds = true
			
			let ratio = backgroundWidth / backgroundHeight
			let constraint = NSLayoutConstraint(item: self.fieldBackground, attribute: .width, relatedBy: .equal, toItem: self.fieldBackground, attribute: .height, multiplier: ratio, constant: 0.0)
			self.fieldBackground.addConstraint(constraint)
			self.fieldBackground.backgroundColor = UIColor(white: 0.89, alpha: 1.0)
			
			self.urlField = UITextField(frame: self.fieldBackground.frame)
			self.addSubview(self.urlField)
			self.urlField.translatesAutoresizingMaskIntoConstraints = false
			self.urlField.autocorrectionType = .no
			self.urlField.autocapitalizationType = .none
			self.urlField.spellCheckingType = .no
			
			self.addConstraints([
				NSLayoutConstraint(item: self.urlField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: backgroundHeight),
				NSLayoutConstraint(item: self.urlField, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: self.fieldBackgroundMargin + 5),
				NSLayoutConstraint(item: self.urlField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: (self.fieldBackgroundTopMargin + contentHeight / 2) - (self.bounds.height / 2)),
			])
			self.urlField.textAlignment = .center
			self.urlField.adjustsFontSizeToFitWidth = true
			self.urlField.font = self.urlFieldFont
			self.urlField.returnKeyType = .go
			self.urlField.delegate = self
			
			self.cancelButton = UIButton(type: .system)
			self.cancelButton.addTarget(self, action: #selector(cancelEditing), for: .touchUpInside)
			self.cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), for: .normal)
			self.addSubview(self.cancelButton)
			self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
			self.cancelButtonRightConstraint = NSLayoutConstraint(item: self.cancelButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: self.isCancelButtonVisible ? -self.fieldBackgroundMargin : self.cancelButtonRight)
			self.addConstraints([
				NSLayoutConstraint(item: self.cancelButton, attribute: .left, relatedBy: .equal, toItem: self.urlField, attribute: .right, multiplier: 1.0, constant: 5),
				NSLayoutConstraint(item: self.cancelButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60),
				NSLayoutConstraint(item: self.cancelButton, attribute: .centerY, relatedBy: .equal, toItem: self.urlField, attribute: .centerY, multiplier: 1, constant: 0),
				self.cancelButtonRightConstraint,
			])

			self.addConstraints([
				NSLayoutConstraint(item: self.fieldBackground, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: self.fieldBackgroundMargin),
				NSLayoutConstraint(item: self.fieldBackground, attribute: .right, relatedBy: .equal, toItem: self.cancelButton, attribute: .left, multiplier: 1.0, constant: -self.fieldBackgroundMargin),
				self.backgroundTopConstraint,
				self.backgroundBottomConstraint
			])
			

			self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
		}
		
		func scrollViewDidScroll(_ scrollView: UIScrollView) {
			if self.effectiveScrollTop == nil { self.effectiveScrollTop = -scrollView.contentInset.top }
			let maxDelta = TitleBar.maxHeight - TitleBar.minHeight
			let scrollAmount = scrollView.contentOffset.y - self.effectiveScrollTop
			self.scrollView = scrollView
			
			if scrollAmount < 0 {
				self.displayedHeightFraction = 1.0
			} else if scrollAmount < maxDelta {
				self.makeFieldEditable(false)
				self.displayedHeightFraction = 1.0 - scrollAmount / maxDelta
			} else {
				self.makeFieldEditable(false)
				self.displayedHeightFraction = 0.0
			}
			scrollView.scrollIndicatorInsets = UIEdgeInsets(top: self.currentHeight, left: 0, bottom: 0, right: 0)
		}
		
		override func draw(_ rect: CGRect) {
			let lineWidth = 1.0 / UIScreen.main.scale
			let bezier = UIBezierPath()
			let bounds = self.bounds
			UIColor.lightGray.setStroke()
			bezier.move(to: CGPoint(x: 0, y: bounds.height - lineWidth))
			bezier.addLine(to: CGPoint(x: bounds.width, y: bounds.height - lineWidth))
			bezier.lineWidth = lineWidth
			bezier.stroke()
		}
		
		func textFieldShouldReturn(_ textField: UITextField) -> Bool {
			self.makeFieldEditable(false)
			if let text = self.urlField.text, let url = URL(string: text) {
				guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return false }
				
				if components.scheme == nil { components.scheme = "https" }
				if components.host == nil {
					components.host = components.path
					components.path = ""
				}
				
				self.webViewController?.didEnterURL(components.url)
			}
			return false
		}
	}
}
