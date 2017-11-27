//
//  OverlayRender.swift
//  Overlay
//
//  Created by Aaron Sutton on 11/26/17.
//  Copyright © 2017 Aaron Sutton. All rights reserved.
//

import Foundation
import CoreImage
import Metal

/// Renders Layers objects into composite images.
public final class OverlayRenderer {

	let context: CIContext
	let filter: CIFilter

	/// Initialize a new renderer.
	public init() {
		// Check if the devive supports Metal
		if let mtlDevice = MTLCreateSystemDefaultDevice() {
			// Use Metal enhanced context
			context = CIContext.init(mtlDevice: mtlDevice)
		} else {
			// Use default context
			context = CIContext.init()
		}
		filter = CIFilter(name: "CISourceOverCompositing")!
	}

	/// Render a layers object into one CIImage.
	///
	/// - Parameters:
	///   - from: The layers to render.
	///   - completion: Passes the completed render.
	public func composite(from layers: Layers, completion: @escaping (_ result: UIImage) -> Void) {
		// Check the layers
		guard valid(layers) else {
			layers.layer(0) { result in
				completion(result)
			}
			return
		}
		var rendered: Int = 0
		var workingRender: CIImage
		// The initial render
		workingRender = render(base: layers.images[0]!, overlay: layers.images[1]!)
		rendered += 2
		// Render each layer over the other
		while layers.count > rendered {
			workingRender = render(base: workingRender, overlay: layers.images[rendered]!)
			rendered += 1
		}
		// Conver the final result
		OverlayCore.convert(image: workingRender) { result in
			completion(result)
		}
	}

	/// Render two images.
	///
	/// - Parameters:
	///   - base: The base image.
	///   - overlay: The overlay image.
	/// - Returns: The render.
	private func render(base: CIImage, overlay: CIImage) -> CIImage {
		filter.setValue(base, forKey: "inputBackgroundImage")
		filter.setValue(overlay, forKey: "inputImage")
		return filter.outputImage!
	}

	/// Check to make sure a Layer object has two valid layers.
	///
	/// - Parameter layers: The Layers object to validate.
	/// - Returns: True if valid, false if not.
	private func valid(_ layers: Layers) -> Bool {
		if layers.images[0] != nil && layers.images[1] != nil {
			return true
		} else {
			return false
		}
	}
}
