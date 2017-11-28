//
//  ViewController.swift
//  Sample App
//
//  Created by Aaron Sutton on 11/24/17.
//  Copyright © 2017 Aaron Sutton. All rights reserved.
//

import UIKit
import Overlay

class ViewController: UIViewController {

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var label: UILabel!

	var layers: Layers!
	var renderer: OverlayRenderer!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		renderer = OverlayRenderer()
		clear()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		clear()
	}

	@IBAction func insertTriangle() {
		try? layers.insertLayer(named: "Triangle", at: 1)
		update()
	}

	@IBAction func addPolygon() {
		try? layers.appendLayer(named: "Polygon")
		update()
	}

	@IBAction func replaceStar() {
		try? layers.updateLayer(2, named: "Star")
		update()
	}

	@IBAction func removeTopmost() {
		layers.removeLayer(layers.count - 1)
		update()
	}

	@IBAction func clear() {
		let layerDictionary =
			[
				0: UIImage(named: "Square")!,
				]
		guard let compositeLayers = try? Layers(with: layerDictionary) else {
			return
		}
		layers = compositeLayers
		update()
	}

	func update() {
		label.text = "Layers: " + String(layers.count)
		renderer.composite(from: layers) { result in
			self.imageView.image = result
		}
		if layers.count == 0 {
			self.imageView.image = nil
		}
	}
}
