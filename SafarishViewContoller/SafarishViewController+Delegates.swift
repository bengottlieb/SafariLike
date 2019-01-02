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
	
}

extension SafarishViewController: WKUIDelegate {
	
}

extension SafarishViewController: UIScrollViewDelegate {
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let adjustedOffset = scrollView.contentOffset.y + scrollView.contentInset.top
		let boundedOffset = min(max(adjustedOffset, 0), self.topBarMaxHeight)
		self.setTopBarHeight(self.topBarMaxHeight - boundedOffset)
	}
}
