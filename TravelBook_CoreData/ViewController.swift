//
//  ViewController.swift
//  TravelBook_CoreData
//
//  Created by Macbook on 20.03.22.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var noteText: UITextField!
    var locationManager = CLLocationManager()
    var chosenLatitude = Double()
    var chosenlongitude = Double()
    var selectedTitle = ""
    var selectedTitleID: UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    private func config() {
        configMapView()
        configLocationManager()
        configGestureRec()
        passingData()
    }
    
    private func configMapView() {
        mapView.delegate = self
    }
    
    private func configLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func configGestureRec() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    private func passingData() {
        if selectedTitle != "" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedTitleID!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
                            
                            if let subtitle = result.value(forKey: "subtitle") as? String {
                                annotationSubtitle = subtitle
                                
                                if let latitude = result.value(forKey: "latitude") as? Double {
                                    annotationLatitude = latitude
                                    
                                    if let longitude = result.value(forKey: "longitude") as? Double {
                                        annotationLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        mapView.addAnnotation(annotation)
                                        nameText.text = annotationTitle
                                        noteText.text = annotationSubtitle
                                        
                                        locationManager.stopUpdatingLocation()
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
        } else {
            
        }
    }
    
    @objc private func chooseLocation(rec: UILongPressGestureRecognizer) {
        if rec.state == .began {
            let touchedPoints = rec.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchedPoints, toCoordinateFrom: self.mapView)
            chosenLatitude = touchedCoordinates.latitude
            chosenlongitude = touchedCoordinates.longitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text
            annotation.subtitle = noteText.text
            self.mapView.addAnnotation(annotation)
        }
    }
    @IBAction func saveButtonPressed(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        
        newPlace.setValue(nameText.text, forKey: "title")
        newPlace.setValue(noteText.text, forKey: "subtitle")
        newPlace.setValue(chosenlongitude, forKey: "longitude")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("Context saved succesfully")
        } catch {
            print(error.localizedDescription)
        }
        
    }

}

extension ViewController: MKMapViewDelegate {
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedTitle == "" {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        } else {
            print("error")
        }
    }
}


