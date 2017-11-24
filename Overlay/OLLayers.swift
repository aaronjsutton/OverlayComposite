//
//  OLLayers.swift
//  Overlay
//
//  Created by Aaron Sutton on 11/24/17.
//  Copyright © 2017 Aaron Sutton. All rights reserved.
//

import Foundation

/// ## Overview
/// An object that represents images in layered order.
///
/// These images can then be used by OLImage to create a composite image.
/// ## Create from Asset Catalog
///
/// Create a new layer object using images from the Asset catalog:
///
/// ```swift
///		let layers = [0: "Background Image", 1: "Overlay Image"]
///		guard let olLayers = try? OLLayers(from: layers) else {
/// 		// Uh-oh! Error occurred.
///  	}
///	```
public final class OLLayers {

	private var images: [Int: CIImage] = [:]

	/// Create a collection of layers from images stored in the asset catalog.
	/// Pass a dictionary to specify the order of the images, starting at 0.
	/// ## Example
	///
	/// Create a dictionary of images and layers:
	///
	/// ```swift
	///		let layers = [0: "Image 1", 1: "Image 2"]
	/// ```
	///
	/// **Note:** Ensure layers are in proper order, otherwise an error will be thrown.
	///
	/// - Parameter images: The images to be composited, ordered by layer.
	/// - Throws: Errors if the layers could not be organized
	public init(from images: [Int: String]) throws {
		// Validate dictionary
		if !OLLayers.isLayerDictionary(images) {
			throw OLError(.invalidDictionary)
		}

		// Validate images
		for (layer, image) in images {
			// Get the image from the asset catalog
			guard let uiImage = UIImage(named: image) else {
				throw OLError(.imageNotFound, imageName: image)
			}
			// Convert the image to CIImage
			guard let ciImage = CIImage(image: uiImage) else {
				throw OLError(.invalidImage, imageName: image)
			}
			// Add the image to the registry
			self.images.updateValue(ciImage, forKey: layer)
		}
	}

	/// Validate a layer dictionary.
	///
	/// - Parameter dictionary: The dictionary to validate
	/// - Returns: False if the dictionary is invalid
	public class func isLayerDictionary(_ dictionary: [Int: String]) -> Bool {
		let total = dictionary.count - 1
		for index in 0...total {
			if dictionary[index] == nil {
				return false
			}
		}
		return true
	}
}
