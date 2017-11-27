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

/// ## Overview
/// Render [Layers](Layers.html) objects into single, usable images.
///
/// **Note**: Creating renderer objects can be an expensive task.
/// It is recommeneded that you minimize creation of renderer objects for optimum performance.
///
/// # Examples
///
/// ## Rendering a Layers Object
/// ```swift
/// // Create a new render object
///	let renderer = OverlayRenderer()
/// // Render an image
///	renderer.composite(from: myLayers) { result in
///		// Access the UIImage result here
/// }
///	```
/// Renders `myLayers` to a UIImage.
///
/// ## Standalone Conversion
/// ```swift
/// // Convert an image
///	OverlayRenderer.convert(myCiImage) { result in
///		// Access the UIImage result here
/// }
///	```
/// Converts `myCiImage` to a UIImage.
///
public final class OverlayRenderer {

	let context: CIContext
	let filter: CIFilter

	/// Create a new renderer object.
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
		guard OverlayRenderer.valid(layers) else {
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
		OverlayRenderer.convert(image: workingRender, context) { result in
			completion(result)
		}
	}

	/// Convert a CIImage to a UIImage.
	///
	/// - Parameters:
	///   - image: The image convert.
	///   - context: The optional context to use. If possible,
	/// use a preexisting context for performance. If one is not avalible, pass nil and a
	/// new context will be created.
	///   - completion: Passes the completed render.
	public class func convert(
														image: CIImage,
														_ contextToUse: CIContext? = nil,
														completion: @escaping (_ image: UIImage) -> Void) {

		var context: CIContext

		// Determine the context to use
		if contextToUse != nil {
			context = contextToUse!
		} else {
			// Check if the devive supports Metal
			if let mtlDevice = MTLCreateSystemDefaultDevice() {
				// Use Metal enhanced context
				context = CIContext.init(mtlDevice: mtlDevice)
			} else {
				// Use default context
				context = CIContext.init()
			}
		}

		var cgImage: CGImage?

		// Render the image
		DispatchQueue.global(qos: .userInitiated).async {
			// Create bitmap data
			cgImage = context.createCGImage(image, from: image.extent)
			DispatchQueue.main.async {
				if cgImage != nil {
					completion(UIImage(cgImage: cgImage!))
				} else {
					return
				}
			}
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
	private class func valid(_ layers: Layers) -> Bool {
		if layers.images[0] != nil && layers.images[1] != nil {
			return true
		} else {
			return false
		}
	}
}
