//
//  ViewController.swift
//  Safarish
//
//  Created by Ben Gottlieb on 12/18/16.
//  Copyright © 2016 Stand Alone, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let url = URL(string: "https://digg.com")!
		let wv = WebViewController(url: url)
		self.present(wv, animated: true, completion: nil)
	}
}

