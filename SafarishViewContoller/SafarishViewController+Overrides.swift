//
//  SafarishViewController+Overrides.swift
//  Safarish
//
//  Created by Ben Gottlieb on 1/1/19.
//  Copyright © 2019 Stand Alone, Inc. All rights reserved.
//

import UIKit

extension SafarishViewController {
	open override func willMove(toParent parent: UIViewController?) {
		super.willMove(toParent: parent)
		if let nav = parent as? UINavigationController ?? parent?.navigationController {
			nav.setNavigationBarHidden(true, animated: false)
		}
	}
	
	
	open override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		self.toolbar?.frame = self.toolbarFrame
		self.webview?.frame = self.webviewFrame
	}
}
