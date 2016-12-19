//
//  WebViewController.swift
//  SafariLike
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
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if let url = self.url {
			self.webView.load(URLRequest(url: url))
			self.titleBar.set(url: url)
		}
	}
}

extension WebViewController {
	
	class TitleBar: UIView, UIScrollViewDelegate {
		static let maxHeight: CGFloat = 64
		static let minHeight: CGFloat = 40
		
		var fieldBackgroundMargin: CGFloat = 10
		var fieldBackgroundMaxMargin: CGFloat = 10
		var fieldBackgroundHeight: CGFloat = 27
		var fieldBackground: UIView!
		let fieldBackgroundTopMargin: CGFloat = 20
		var effectiveScrollTop: CGFloat!
		var scrollView: UIScrollView?
		
		var urlField: UITextField!
		var urlFieldFont: UIFont {
			return UIFont.systemFont(ofSize: self.fieldBackground.bounds.height * 0.6)
		}
		
		func setEditable() {
			guard let scrollView = self.scrollView, self.displayedHeightFraction != 1.0 else { return }
			
			let delta = (TitleBar.maxHeight - TitleBar.minHeight)
			self.effectiveScrollTop = scrollView.contentOffset.y - delta
			
			scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: self.effectiveScrollTop), animated: true)
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.makeFieldEditable() }
		}
		
		func makeFieldEditable() {
			let str = NSAttributedString(string: self.urlField.text ?? "", attributes: [NSFontAttributeName: self.urlField.font!])
			let size = str.size()
			let offset = ((self.urlField.bounds.width - size.width) / 2) - 2
			
			UIView.animate(withDuration: 0.2, animations: {
				self.urlField.transform = CGAffineTransform(translationX: -offset, y: 0)
			}) { complete in
				self.urlField.isUserInteractionEnabled = true
				self.urlField.transform = CGAffineTransform.identity
				self.urlField.textAlignment = .left
				self.urlField.selectAll(nil)
				self.urlField.clearButtonMode = .whileEditing
			}
		}
		
		var currentHeight = TitleBar.maxHeight
		var displayedHeightFraction: CGFloat = 1.0 { didSet {
			if self.displayedHeightFraction == oldValue { return }
			
			let maxDelta = TitleBar.maxHeight - TitleBar.minHeight
			self.currentHeight = TitleBar.minHeight + maxDelta * self.displayedHeightFraction
			
			self.fieldBackgroundMargin = self.fieldBackgroundMaxMargin * self.displayedHeightFraction
			self.fieldBackground.translatesAutoresizingMaskIntoConstraints = false
			
			self.backgroundTopConstraint.constant = (self.fieldBackgroundMargin + self.fieldBackgroundTopMargin)
			self.backgroundBottomConstraint.constant = -self.fieldBackgroundMargin

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
			self.addConstraints([
				NSLayoutConstraint(item: self.fieldBackground, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
				self.backgroundTopConstraint,
				self.backgroundBottomConstraint
			])
			
			self.fieldBackground.layer.cornerRadius = 5
			self.fieldBackground.layer.masksToBounds = true
			
			let ratio = backgroundWidth / backgroundHeight
			let constraint = NSLayoutConstraint(item: self.fieldBackground, attribute: .width, relatedBy: .equal, toItem: self.fieldBackground, attribute: .height, multiplier: ratio, constant: 0.0)
			self.fieldBackground.addConstraint(constraint)
			self.fieldBackground.backgroundColor = UIColor(white: 0.89, alpha: 1.0)
			
			self.urlField = UITextField(frame: self.fieldBackground.frame)
			self.addSubview(self.urlField)
			self.urlField.translatesAutoresizingMaskIntoConstraints = false
			self.addConstraints([
				NSLayoutConstraint(item: self.urlField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: backgroundHeight),
				NSLayoutConstraint(item: self.urlField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: backgroundWidth - 10),
				NSLayoutConstraint(item: self.urlField, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: self.urlField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: (self.fieldBackgroundTopMargin + contentHeight / 2) - (self.bounds.height / 2)),
			])
			self.urlField.textAlignment = .center
			self.urlField.adjustsFontSizeToFitWidth = true
			self.urlField.font = self.urlFieldFont
			
			self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setEditable)))
		}
		
		func scrollViewDidScroll(_ scrollView: UIScrollView) {
			if self.effectiveScrollTop == nil { self.effectiveScrollTop = -scrollView.contentInset.top }
			let maxDelta = TitleBar.maxHeight - TitleBar.minHeight
			let scrollAmount = scrollView.contentOffset.y - self.effectiveScrollTop
			self.scrollView = scrollView
			
			if scrollAmount < 0 {
				self.displayedHeightFraction = 1.0
			} else if scrollAmount < maxDelta {
				self.displayedHeightFraction = 1.0 - scrollAmount / maxDelta
			} else {
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
	}
}
