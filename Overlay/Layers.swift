//
//  OLLayers.swift
//  Overlay
//
//  Created by Aaron Sutton on 11/24/17.
//  Copyright © 2017 Aaron Sutton. All rights reserved.
//

import Foundation

///
/// ## Overview
/// An object that represents images in layered order.
///
/// These images can then be used by OLImage to create a composite image.
/// ## Create from Asset Catalog
///
/// ### Create a new layer object using images from the Asset catalog:
///
/// ```swift
///		let layers = [0: "Background Image", 1: "Overlay Image"]
///		guard let olLayers = try? OLLayers(from: layers) else {
/// 		// Uh-oh! Error occurred.
///  	}
///	```
///
/// ## Create from UIImage Objects
///
/// ### Create a new layer object using images from UIImages:
///
/// ```swift
///		let layers = [0: image1, 1: image2]
///		guard let olLayers = try? OLLayers(from: layers) else {
/// 		// Uh-oh! Error occurred.
///  	}
///	```
///
/// ## Manipulating Layers
///
/// ### Accessing layers:
/// ```swift
///		olLayers.layer(0)
/// ```
/// Returns a UIImage of layer 0.
///
public final class Layers {

	internal var images: [Int: CIImage] = [:]

	/// The number of layers. 
	public var count: Int {
		return images.count
	}

	// MARK: - Initializers

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
		if !Layers.isLayerDictionary(images) {
			throw OverlayError(.invalidDictionary)
		}

		// Validate images
		for (layer, image) in images {
			// Get the image from the asset catalog
			guard let uiImage = UIImage(named: image) else {
				throw OverlayError(.imageNotFound, imageName: image)
			}
			// Convert the image to CIImage
			guard let ciImage = CIImage(image: uiImage) else {
				throw OverlayError(.invalidImage, imageName: image)
			}
			// Add the image to the registry
			self.images.updateValue(ciImage, forKey: layer)
		}
	}

	/// Create a collection of layers from UIImage objects.
	/// Pass a dictionary to specify the order of the images, starting at 0.
	/// ## Example
	///
	/// Create a dictionary of images and layers:
	///
	/// ```swift
	///		let layers = [0: image1, 1: image2]
	/// ```
	///
	/// **Note:** Ensure layers are in proper order, otherwise an error will be thrown.
	///
	/// - Parameter images: The UIImages and their corresponding layer numbers
	/// - Throws: Errors if the layers could not be organized
	public init(with images: [Int: UIImage]) throws {
		// Validate dictionary
		if !Layers.isLayerDictionary(images) {
			throw OverlayError(.invalidDictionary)
		}

		// Validate images
		for (layer, image) in images {
			// Convert the image to CIImage
			guard let ciImage = CIImage(image: image) else {
				throw OverlayError(.invalidImage)
			}
			// Add the image to the registry
			self.images.updateValue(ciImage, forKey: layer)
		}
	}

	// MARK: - Layer Operations

	/// Get the specified layer.
	///
	/// - Parameter layer: The layer number to retrieve
	/// - Returns: The layer. Nil if the layer does not exist.
	public func layer(_ layer: Int, completion: ((_ image: UIImage) -> Void)? = nil) {
		guard let image = images[layer] else {
			return
		}
		OverlayCore.convert(image: image) { result in
			completion?(result)
		}
	}

	/// Append a layer to the end of the dictionary, making it the topmost image
	///
	/// - Parameter image: The image to append
	/// - Throws: An error if the image could not be created.
	public func appendLayer(_ image: UIImage) throws {
		// Convert the image
		guard let ciImage = CIImage(image: image) else {
			throw OverlayError(.invalidImage)
		}
		// Append the image
		images.updateValue(ciImage, forKey: images.count)
	}

	/// Insert a layer at a given index, nondestructivly.
	///
	/// - Parameters:
	///   - image: The image to insert.
	///   - layer: The layer to insert it at. All other layers will be moved up, no layers will be overwritten.
	/// - Throws: An error if the image could not be read
	public func insertLayer(_ image: UIImage, at layer: Int) throws {
		// Convert the image
		guard let ciImage = CIImage(image: image) else {
			throw OverlayError(.invalidImage)
		}

		// Insert the image
		var updatedImages: [Int: CIImage] = [:]
		for (key, image) in images where key < layer {
			updatedImages.updateValue(image, forKey: key)
		}
		for (key, image) in images where key >= layer {
			updatedImages.updateValue(image, forKey: key + 1)
		}
		updatedImages.updateValue(ciImage, forKey: layer)
		images = updatedImages
	}

	/// Remove a given layer.
	///
	/// - Parameter layer: The layer to remove
	public func removeLayer(_ layer: Int) {
		// Make sure the layer exisits before doing changes
		guard images[layer] != nil else {
			return
		}
		// Remove the layer
		images.removeValue(forKey: layer)
		// Shift all the layers down
		var updatedImages: [Int: CIImage] = [:]
		for (key, image) in images where key < layer {
			updatedImages.updateValue(image, forKey: key)
		}
		for (key, image) in images where key > layer {
			updatedImages.updateValue(image, forKey: key - 1)
		}
		images = updatedImages
	}

	// MARK: - Helpers

	/// Validate a layer dictionary.
	///
	/// - Parameter dictionary: The dictionary to validate
	/// - Returns: False if the dictionary is invalid
	public class func isLayerDictionary(_ dictionary: [Int: Any]) -> Bool {
		let total = dictionary.count - 1
		for index in 0...total where dictionary[index] == nil {
			return false
		}
		return true
	}
}
