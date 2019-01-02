//
//  SafarishViewController+WKNavigationDelegate.swift
//  Internal-iOS
//
//  Created by Ben Gottlieb on 12/25/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import UIKit
import WebKit

extension NavBarSafarishViewController: WKNavigationDelegate {
	open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
		if navigationAction.sourceFrame.isMainFrame, let url = navigationAction.request.url, url != URL.blank {
		//	self.titleView.currentURL = url
		}
		decisionHandler(.allow)
	}
	
	open func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void) {
		if navigationResponse.isForMainFrame, navigationResponse.canShowMIMEType, let url = navigationResponse.response.url, url != URL.blank {
			self.titleView.currentURL = url
		}
		decisionHandler(.allow)
	}
	
	open func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
		self.updateURLField()
	}
	
	open func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//		self.updateURLField()
	}
	
	open func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
		self.isLoading = true
		//self.titleBar?.makeFullyVisible(animated: true)
	}
	
	open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		self.updateBarButtons()
		self.isLoading = false
	}
	
	open func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
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
	
	open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {

		self.isLoading = false
	}
	
	open func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		completionHandler(.useCredential, challenge.proposedCredential)
	}
}

extension NavBarSafarishViewController: UIScrollViewDelegate {
	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.currentScrollStart = scrollView.contentOffset.y
	}
	
	var currentScrollPercentage: Double? {
		let scrollview = self.webView.scrollView
		let height = Double(scrollview.contentSize.height - scrollview.bounds.height)
		return height > 0 ? Double(scrollview.contentOffset.y) / height : nil
	}
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if let amount = self.currentScrollPercentage { self.webViewScrollChanged(to: amount) }
		guard !self.isLoading, scrollView.isDragging || scrollView.isDecelerating, let bar = self.scrollableNavigationBar else { return }
		var scrollOffset = (scrollView.contentOffset.y - self.currentScrollStart)
		
		
		if self.isNavigationBarMinimized, scrollOffset > 0 { return }		//already minimized, scrolling down, ignore
		if !self.isNavigationBarMinimized, scrollOffset < 0 { return }		//already maxmiized, scrolling up, ignore
		
		if self.isNavigationBarMinimized { scrollOffset += self.maxNavigationReduction }
		let effectiveOffset = min(self.maxNavigationReduction, max(0, scrollOffset))
		let newPercentage = abs(effectiveOffset / self.maxNavigationReduction)
		
		let remainingPercentage = 1.0 - newPercentage
		if remainingPercentage != 0 {
			//self.subviewTopConstraint?.constant = -(self.maxNavigationBarHeight + self.statusBarHeight) + (effectiveOffset / remainingPercentage)
		}
		self.titleView?.shrinkPercentage = newPercentage
		bar.transform = CGAffineTransform(translationX: 0, y: -effectiveOffset)
		if newPercentage == 1.0 {
			self.isNavigationBarMinimized = true
		} else if newPercentage == 0.0 {
			self.isNavigationBarMinimized = false
		}
		
		self.updateNavigationSubviewsWith(offset: -effectiveOffset, remainingPercentage: remainingPercentage)
	}
	
	public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		let delta = scrollView.contentOffset.y - self.currentScrollStart
		
		if delta > 0, delta < self.maxNavigationReduction {
			targetContentOffset.pointee = CGPoint(x: 0, y: self.currentScrollStart + 0)
		}
		
		if velocity.y == 0.0, let amount = self.currentScrollPercentage { self.finishedScrolling(to: amount) }
	}
	
	public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		if let amount = self.currentScrollPercentage { self.finishedScrolling(to: amount) }
	}
	
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		if let amount = self.currentScrollPercentage { self.finishedScrolling(to: amount) }
	}
}

