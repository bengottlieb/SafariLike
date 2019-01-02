//
//  URL+Safarish.swift
//  Safarish
//
//  Created by Ben Gottlieb on 7/28/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import Foundation


extension URL {
	static let blank = URL(string: "about:blank")!
	public var isEmpty: Bool { return self == URL.blank }
	
	var prettyName: String? {
		let components = URLComponents(url: self, resolvingAgainstBaseURL: false)
		var name = components?.host ?? ""
		if name.hasPrefix("www.") { name = String(name[name.index(name.startIndex, offsetBy: 4)...]) }
		return name
	}
	
	var prettyURLString: String? {
		var string = ""
		if self == URL.blank { return "" }
		
		if let host = self.host, !host.isEmpty { string += host }
		if !self.path.isEmpty {
			if !self.path.hasPrefix("/") && !string.hasSuffix("/") { string += "/" }
			string += self.path
		}
		
		return string
	}
	
	var normalized: URL {
		guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
		if components.scheme == "http" { components.scheme = "https" }
		if components.path == "/" { components.path = "" }
		return components.url ??  self
	}
	
	init?(fragment: String) {
		if URL(string: fragment) != nil {
			self.init(string: fragment)
		} else {
			self.init(string: "https://" + fragment)
		}
	}
	
	public static func build(from fragment: String, completion: @escaping (URL?) -> Void) {
		guard let url = URL(string: fragment), var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			completion(nil)
			return
		}
		
		if (components.scheme ?? "").isEmpty {
			components.scheme = "https"
		}
		
		completion(components.url)
	}
}
