//
//  SafarishURLEntryField.swift
//  Safarish
//
//  Created by Ben Gottlieb on 7/27/17.
//  Copyright © 2017 Stand Alone, Inc. All rights reserved.
//

import UIKit

class SafarishURLEntryField: UIView {
	var fontSize: CGFloat = 15
	var field: UITextField!
	var label: UILabel!
	var isEnabled: Bool = true { didSet {
		if self.isEnabled {
			self.field.isEnabled = true
			self.field.isUserInteractionEnabled = true
			self.field.alpha = 1.0
		} else {
			self.field.isEnabled = false
			self.field.isUserInteractionEnabled = false
			self.field.alpha = 0.2
		}
	}}
	var labelCenterConstraint: NSLayoutConstraint!
	var labelLeftConstraint: NSLayoutConstraint!
	var backgroundRightConstraint: NSLayoutConstraint!
	var cancelButton: UIButton!
	var shouldShowCancelButton: Bool { return !self.safarishViewController.isIPad }
	var fieldFakeSelectAllEnabled = false
	weak var safarishViewController: SafarishViewController!
	var shrinkPercentage: CGFloat = 0.0 { didSet { self.updateShrinkage() }}
	var drawBackground = true { didSet { self.fieldBackground.alpha = self.drawBackground ? 1.0 : 0.0 } }
	var enabledAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black] { didSet { self.updateText() }}
	var disabledAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black] { didSet { self.updateText() }}

	func updateText() {
		let attr = self.isEnabled ? self.enabledAttributes : self.disabledAttributes
		self.field.attributedText = NSAttributedString(string: self.url?.prettyURLString ?? "", attributes: attr)
		self.label.attributedText = NSAttributedString(string: self.url?.prettyName ?? self.title ?? "", attributes: attr)
	}
	
	var title: String? { didSet {
		self.label.attributedText = NSAttributedString(string: self.title ?? self.url?.prettyURLString ?? "", attributes: self.enabledAttributes)
		if self.title != nil {
			self.label.isHidden = false
			self.drawBackground = false
		}
	}}
	var reloadButton: UIButton!
	var fieldBackground: UIImageView!
	var backgroundHeight: CGFloat = 30
	var url: URL? { didSet {
		let url = self.url?.isFileURL == true ? nil : self.url
		
		if url != nil {
			self.title = nil
			self.drawBackground = true
		}
		self.updateText()
	}}
	
	let selectionColor = UIColor(red: 0.0, green: 0.33, blue: 0.65, alpha: 0.2)
	
	convenience init(in parent: SafarishViewController) {
		self.init(frame: .zero)
		self.backgroundColor = .clear
		
		self.safarishViewController = parent
		self.fieldBackground = UIImageView(frame: .zero)
		//self.fieldBackground.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
		self.fieldBackground.contentMode = .scaleToFill
		self.fieldBackground.image = UIImage(named: "url_field_background", in: Bundle(for: SafarishViewController.self), compatibleWith: nil)
		self.fieldBackground.translatesAutoresizingMaskIntoConstraints = false
		self.fieldBackground.layer.cornerRadius = 8
		self.fieldBackground.layer.masksToBounds = true
		self.addSubview(self.fieldBackground)
		self.backgroundRightConstraint = self.fieldBackground.trailingAnchor.constraint(equalTo: self.trailingAnchor)
		self.backgroundRightConstraint.isActive = true
		
		self.heightAnchor.constraint(equalToConstant: 44).isActive = true
		self.widthAnchor.constraint(greaterThanOrEqualToConstant: 300).isActive = true
		self.fieldBackground.heightAnchor.constraint(equalToConstant: self.backgroundHeight).isActive = true
		self.fieldBackground.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		self.fieldBackground.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		
		self.field = UITextField(frame: .zero)
		self.field.translatesAutoresizingMaskIntoConstraints = false
		self.field.autocorrectionType = .no
		self.field.autocapitalizationType = .none
		self.field.spellCheckingType = .no
		self.field.textAlignment = .left
		self.field.adjustsFontSizeToFitWidth = true
		self.field.returnKeyType = .go
		self.field.clipsToBounds = false
		self.field.font = UIFont.systemFont(ofSize: self.fontSize)
		self.field.delegate = self
		self.field.isHidden = true
		self.addSubview(self.field)
		self.field.addTarget(self, action: #selector(urlFieldChanged), for: .editingChanged)
		
		self.field.leadingAnchor.constraint(equalTo: self.fieldBackground.leadingAnchor, constant: 5).isActive = true
		self.field.trailingAnchor.constraint(equalTo: self.fieldBackground.trailingAnchor).isActive = true
		self.field.heightAnchor.constraint(equalToConstant: self.backgroundHeight).isActive = true
		self.field.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		
		self.reloadButton = UIButton(type: .custom)
		self.reloadButton.setImage(UIImage(named: "safarish-refresh", in: Bundle(for: SafarishViewController.self), compatibleWith: nil), for: .normal)
		self.reloadButton.sizeToFit()
		self.reloadButton.translatesAutoresizingMaskIntoConstraints = false
		self.reloadButton.showsTouchWhenHighlighted = true
		self.reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
		self.fieldBackground.addSubview(self.reloadButton)
		self.reloadButton.trailingAnchor.constraint(equalTo: self.fieldBackground.trailingAnchor, constant: -10).isActive = true
		self.reloadButton.centerYAnchor.constraint(equalTo: self.fieldBackground.centerYAnchor).isActive = true
		
		self.label = UILabel(frame: .zero)
		self.label.translatesAutoresizingMaskIntoConstraints = false
		self.label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		self.label.textAlignment = .center
		self.label.adjustsFontSizeToFitWidth = true
		self.label.lineBreakMode = .byTruncatingTail
		self.label.minimumScaleFactor = 0.9
		self.label.font = UIFont.systemFont(ofSize: self.fontSize)
		self.addSubview(self.label)
		
		self.labelCenterConstraint = self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor)
		self.labelLeftConstraint = self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor)
		
		self.labelCenterConstraint.isActive = true
		
		self.label.widthAnchor.constraint(equalTo: self.fieldBackground.widthAnchor).isActive = true
		self.label.heightAnchor.constraint(equalToConstant: self.backgroundHeight).isActive = true
		self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

		let recog = UITapGestureRecognizer(target: self, action: #selector(beginEditing))
		self.isUserInteractionEnabled = true
		self.addGestureRecognizer(recog)

		self.field.addTarget(self, action: #selector(clearSelectAll), for: .touchDown)
	}
	
	func updateShrinkage() {
		let newAlpha = (1.0 - self.shrinkPercentage) * (1.0 - self.shrinkPercentage)
		self.fieldBackground.alpha = self.drawBackground ? newAlpha : 0.0
//		self.label.transform = CGAffineTransform(translationX: 0, y: 10 * self.shrinkPercentage)
//		self.fieldBackground.transform = CGAffineTransform(translationX: 0, y: 10 * self.shrinkPercentage)

		let minFontSize: CGFloat = 10
		self.label.font = UIFont.systemFont(ofSize: minFontSize + (self.fontSize - minFontSize) * (1 - self.shrinkPercentage))

		self.isUserInteractionEnabled = self.shrinkPercentage == 0.0
	}
	
	@objc func reload() {
		self.safarishViewController?.reload()
	}
}


extension SafarishURLEntryField: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if self.self.fieldFakeSelectAllEnabled {
			self.field.attributedText = NSAttributedString(string: string, attributes: self.enabledAttributes)
			self.fieldFakeSelectAllEnabled = false
			return false
		}
		return true
	}
	
	@objc func clearSelectAll() {
		if self.fieldFakeSelectAllEnabled {
			self.urlFieldChanged()
			if let position = self.field.position(from: self.field.endOfDocument, offset: -1) {
				self.field.selectedTextRange = self.field.textRange(from: position, to: position)
			}
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if let url = URL(fragment: textField.text) {
			self.url = url
			self.safarishViewController?.didEnterURL(url)
		} else {
			self.label.attributedText = NSAttributedString(string: url?.prettyName ?? "", attributes: self.enabledAttributes)
		}
		textField.resignFirstResponder()
		self.finishEditing()
		return false
	}
	
	@objc func urlFieldChanged() {
		if self.fieldFakeSelectAllEnabled {
			self.fieldFakeSelectAllEnabled = false
			let text = self.field.text
			self.field.attributedText = NSAttributedString(string: text ?? "", attributes: [.font: self.field.font!, .foregroundColor: self.field.textColor!])
		}
	}
	
	@objc func finishEditing() {
		self.labelCenterConstraint.isActive = true
		self.labelLeftConstraint.isActive = false
		self.reloadButton.isHidden = false
		self.backgroundRightConstraint.constant = 0
		UIView.animate(withDuration: 0.25, animations: {
			self.cancelButton?.alpha = 0.0
			self.layoutIfNeeded()
		}) { complete in
			self.updateText()
			self.fieldFakeSelectAllEnabled = true
			self.field.isHidden = true
			self.label.isHidden = false
			self.field.attributedText = NSAttributedString(string: self.field.text ?? "", attributes: [.font: self.field.font!, .backgroundColor: self.selectionColor, .foregroundColor: self.field.textColor!])
		}
	}
	
	var isEditing: Bool {
		return !self.field.isHidden
	}
	
	@objc func beginEditing(recog: UITapGestureRecognizer?) {
		let hit = self.reloadButton.hitTest(recog?.location(in: self.reloadButton) ?? .zero, with: nil)
		if hit == self.reloadButton {
			self.reloadButton.sendActions(for: .touchUpInside)
			return
		}
		guard self.field.isHidden, self.isEnabled else { return }
		self.field.isHidden = true
		self.label.isHidden = false
		self.labelCenterConstraint.isActive = false
		self.labelLeftConstraint.isActive = true
		self.reloadButton.isHidden = true
		if self.shouldShowCancelButton {
			if self.cancelButton == nil {
				self.cancelButton = UIButton(type: .system)
				self.cancelButton.frame = CGRect(x: self.bounds.width, y: 0, width: 0, height: 0)
				self.cancelButton.showsTouchWhenHighlighted = true
				self.cancelButton.addTarget(self, action: #selector(finishEditing), for: .touchUpInside)
				self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
				self.cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), for: .normal)
				self.addSubview(self.cancelButton)
				self.cancelButton.alpha = 0.0
				self.addConstraints([
					NSLayoutConstraint(item: self.cancelButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
					NSLayoutConstraint(item: self.cancelButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 5),
				])
			}

			self.cancelButton.sizeToFit()
			self.backgroundRightConstraint.constant = -(self.cancelButton.bounds.width + 6)
		}
		
		
		if let current = self.label.text, let new = self.field.text, let range = new.range(of: current) {
			let attr: [NSAttributedString.Key: Any] = [ .font: self.label.font ]
			let prefix = String(new[...range.lowerBound])
			self.labelLeftConstraint.constant = 0 + (NSAttributedString(string: prefix, attributes: attr).size().width)
		} else {
			self.labelLeftConstraint.constant = 10
		}

		UIView.animate(withDuration: 0.25, animations: {
			self.cancelButton?.alpha = 1.0
			self.layoutIfNeeded()
		}) { complete in
			self.fieldFakeSelectAllEnabled = true
			self.field.isHidden = false
			self.label.isHidden = true
			self.field.becomeFirstResponder()
			self.field.attributedText = NSAttributedString(string: self.field.text ?? "", attributes: [.font: self.field.font!, .backgroundColor: self.selectionColor, .foregroundColor: self.field.textColor!])
		}
	}
}

extension URL {
	init?(fragment: String?) {
		guard let frag = fragment, !frag.isEmpty else { self.init(string: ""); return nil }
		
		if let components = URLComponents(string: frag), components.scheme != nil {
			self.init(string: frag)
		} else {
			self.init(string: "https://" + frag)
		}
	}
}
