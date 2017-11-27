![Logo](https://docs.aaronjsutton.com/overlay/img/logo.png)

[![Build Status](https://travis-ci.org/aaronjsutton/Overlay.svg?branch=master)](https://travis-ci.org/aaronjsutton/Overlay)

An asynchronous, multithreaded, image compositing framework written in Swift.

## Installation

### [CocoaPods](http://cocoapods.org)

Add Overlay to your Podfile:

```ruby
pod 'Overlay'
```

And run `pod install`

## Usage

### Quick Start

#### Creating Layers

Overlay works using the concept of _layered images_. Each layer represents an individual image that can then be added atop another layer. You can think of this like layers in Photoshop, or similar image editor.

For example, take the following model:

![Layer 0](https://docs.aaronjsutton.com/overlay/img/example.png)

- Layer 0: A large blue square
- Layer 1: A medium orange triangle
- Layer 2: A small green polygon

_Technical Note:_ For this guide, we will assume that these images are named "Square", "Triangle", and "Polygon" in our app's Asset Catalog, and they are all formatted as PNG images with a transparent background.

A collection of images organized into layers is represented in code using the `Layers` class.

```swift
// Create a dictionary of all the images and layers we want to create.
// This will then be passed to Layers
let layerDictionary: [Int: String] =
[
  0: "Square",
  1: "Triangle",
  2: "Polygon"
]

// Create the new layers object.
guard let layers = try? Layers(named: layerDictionary) else {
  // Some error occurred
  return
}
```

Alternatively, you could create a dictionary using UIImage objects:
```swift
let layerDictionary: [Int: UIImage]
```
And pass it to `Layers.init(with:)`

_Now we have a layered image represented in Swift!_

#### Rendering Layers

Of course, we want to be able to use our new composite image. To do that we use `OverlayRenderer`

```swift
// Create a new renderer
let renderer = OverlayRenderer()

renderer.composite(from: layers) { result in
  // Here we can access the completed render
}
```

The result:

![Result](https://docs.aaronjsutton.com/overlay/img/result.png)

To see this in action, check out the Sample App included in the source code.

#### Layer Operations

You can insert, append, and remove layers from a `Layers` object.
See the [Layers Guide](https://docs.aaronjsutton.com/overlay/Classes/Layers.html)

### [API Documentation](https://docs.aaronjsutton.com/overlay/)

## Contributing

#### Pull Requests

If you wish to contribute to Overlay, create a new branch, implement your feature or fix, and then submit a pull request.

#### Documentation

Generate documentation with [Jazzy](https://github.com/realm/jazzy)
