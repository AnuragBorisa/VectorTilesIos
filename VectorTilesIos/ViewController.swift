import UIKit
import MapboxMaps

final class ViewController: UIViewController {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 23.2156, longitude: 72.6369) // Gandhinagar coordinates
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

        // Set the URL for the tiles source
        vectorSource.tiles = ["https://api.{z}/{x}/{y}.pbf"]
        vectorSource.minzoom = 0
        vectorSource.maxzoom = 14

        var lineLayer = LineLayer(id: "ill-small", source: vectorSource.id)
        lineLayer.sourceLayer = "layer-10"
        let lineColor = StyleColor(UIColor(red: 0.00, green: 0.53, blue: 0.80, alpha: 1.00)) // Blue color
        lineLayer.lineColor = .constant(lineColor)
        lineLayer.lineOpacity = .constant(0.8)
        lineLayer.lineWidth = .constant(1.9)
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

    private func showAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
