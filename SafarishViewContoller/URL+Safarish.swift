//
//  URL+Safarish.swift
//  Safarish
//
//  Created by Ben Gottlieb on 7/28/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation


extension URL {
	var prettyName: String? {
		let components = URLComponents(url: self, resolvingAgainstBaseURL: false)
		var name = components?.host ?? ""
		if name.hasPrefix("www.") { name = name.substring(from: name.index(name.startIndex, offsetBy: 4)) }
		return name
	}
	
	var prettyURLString: String? {
		var string = ""
		if self.absoluteString == "about:blank" { return "" }
		
		if let host = self.host, !host.isEmpty { string += host }
		if self.path.isEmpty { string += "/" + self.path}
		
		return string
	}
}
