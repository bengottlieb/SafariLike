//
//  SafarishViewController+Delegates.swift
//  Safarish
//
//  Created by Ben Gottlieb on 1/1/19.
//  Copyright © 2019 Stand Alone, Inc. All rights reserved.
//

import UIKit
import WebKit

extension SafarishViewController: WKNavigationDelegate {
	open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		self.updateNavigationButtons()
	}
}

extension SafarishViewController: WKUIDelegate {
	
}

extension SafarishViewController: UIScrollViewDelegate {
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.contentOffset.y < self.localScrollMinimum { return }
		let adjustedOffset = (scrollView.contentOffset.y + scrollView.contentInset.top) - self.localScrollMinimum
		let boundedOffset = min(max(adjustedOffset, 0), self.topBarMaxHeight)
		self.setTopBarHeight(self.topBarMaxHeight - boundedOffset)
	}
	
	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.localScrollMinimum = scrollView.contentOffset.y
	}
	
	public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		
		if velocity.y < -0 {
			UIView.animate(withDuration: 0.1) {
				self.setTopBarHeight(self.topBarMaxHeight)
			}
		}
	}
	

}
