# VectorTilesIos

This project is an iOS application that demonstrates how to integrate Mapbox vector tiles in an iOS app using Swift.

## Features

- Display Mapbox map with custom vector tiles from an external source
- Highlight vector layers with specific styles

## Setup

1. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/VectorTilesIos.git
    cd VectorTilesIos
    ```

2. Install dependencies using CocoaPods:
    ```sh
    pod install
    ```

3. Open the project in Xcode:
    ```sh
    open VectorTilesIos.xcworkspace
    ```

4. Build and run the project on your simulator or device.

## Usage

- On launching the app, the map will display with the specified vector tiles and styles.

## Requirements

- Xcode 12.0+
- iOS 13.0+
- CocoaPods

## Code Overview

### AppDelegate.swift

Standard setup for the iOS app's lifecycle.

### ViewController.swift

Main view controller that sets up and displays the Mapbox map with custom vector tiles.

```swift
import UIKit
import MapboxMaps

final class ViewController: UIViewController {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 41.878781, longitude: -87.622088)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 12.0),
                                     styleURI: .light)

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allow the view controller to receive information about map events.
        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            self?.drawLineLayer()
        }.store(in: &cancelables)
    }

    func drawLineLayer() {
        var vectorSource = VectorSource(id: "tiles-small")

        // For sources using the {z}/{x}/{y} URL scheme, use the `tiles`
        // property on `VectorSource` to set the URL.
        vectorSource.tiles = ["https://api.com/{z}/{x}/{y}.pbf"]
        vectorSource.minzoom = 6
        vectorSource.maxzoom = 14

        var lineLayer = LineLayer(id: "line-layer", source: vectorSource.id)
        lineLayer.sourceLayer = "layer-0"
        let lineColor = StyleColor(UIColor(red: 0.21, green: 0.69, blue: 0.43, alpha: 1.00))
        lineLayer.lineColor = .constant(lineColor)
        lineLayer.lineOpacity = .constant(0.6)
        lineLayer.lineWidth = .constant(2.0)
        lineLayer.lineCap = .constant(.round)

        do {
            try mapView.mapboxMap.addSource(vectorSource)
        } catch {
            showAlert(with: error.localizedDescription)
        }

        // Define the layer's positioning within the layer stack so
        // that it doesn't obscure other important labels.
        do {
            try mapView.mapboxMap.addLayer(lineLayer, layerPosition: .below("waterway-label"))
        } catch let layerError {
            showAlert(with: layerError.localizedDescription)
        }
    }
}

