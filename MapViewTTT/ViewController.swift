//
//  ViewController.swift
//  MapViewTTT
//
//  Created by Timothy Hull on 2/22/17.
//  Copyright © 2017 Sponti. All rights reserved.
//

import UIKit
import MapKit
import WebKit

class ViewController: UIViewController, MKMapViewDelegate, WKNavigationDelegate, UITextFieldDelegate {
    
    var mapView: MKMapView!
    var webView: WKWebView!
    
    // Array for search results
    var matchingItems: [MKMapItem] = [MKMapItem]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        
        view.addSubview(turnToTechLogo)
        view.addSubview(segmentedControl)
        
        setupTurnToTechLogo()
        setupSegmentedControl()
        
        // Pins
        let turnToTech = Restaurants(title: "TurnToTech", coordinate: CLLocationCoordinate2D(latitude: 40.708637, longitude: -74.014839))
        let fridays = Restaurants(title: "TGI Friday's", coordinate: CLLocationCoordinate2D(latitude: 40.706729, longitude: -74.013032))
        let georges = Restaurants(title: "George's", coordinate: CLLocationCoordinate2D(latitude: 40.707518, longitude: -74.013343))
        let reserveCut = Restaurants(title: "Reserve Cut", coordinate: CLLocationCoordinate2D(latitude: 40.706046, longitude: -74.012131))
        let oHaras = Restaurants(title: "O'Hara's", coordinate: CLLocationCoordinate2D(latitude: 40.709519, longitude: -74.012667))
        let billsBarAndBurger = Restaurants(title: "Bill's Bar & Burger", coordinate: CLLocationCoordinate2D(latitude: 40.709453, longitude: -74.014053))

        mapView.addAnnotations([turnToTech, fridays, georges, reserveCut, oHaras, billsBarAndBurger])
        
        // Load mapview @ TurnToTech
        let span = MKCoordinateSpanMake(0.001, 0.001)
        let region = MKCoordinateRegion(center: turnToTech.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        view.addSubview(searchBar)
        setupSearchBar()
        searchBar.delegate = self

    }
    
    override func loadView() {
        mapView = MKMapView()
        view = mapView
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    
    
    
    
    
// Mark: - Search
    
    let searchBar: UITextField = {
        let sb = UITextField()
        sb.placeholder = "Search nearby restaurants"
        sb.borderStyle = .roundedRect
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    func setupSearchBar() {
        searchBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        searchBar.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalTo: segmentedControl.heightAnchor).isActive = true
        searchBar.bottomAnchor.constraint(equalTo: segmentedControl.topAnchor, constant: -10).isActive = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.resignFirstResponder()
        mapView.removeAnnotations(mapView.annotations)
        handleSearch()
        self.searchBar.text = nil
        return true
    }
    
    func handleSearch() {
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: {(response, error) in
            
            if error != nil {
                print("Error occured in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
                print("No matches found")
            } else {
                print("Matches found")
                
                for item in response!.mapItems {
                    print("Name = \(item.name)")
                    print("Phone = \(item.phoneNumber)")
                    print("Website = \(item.url)")
                    item.url = self.currentPlaceUrl
                    

                    // Append the array of search results
                    self.matchingItems.append(item as MKMapItem)
                    print("Matching items = \(self.matchingItems.count)")
                    
                    // Add pins for search results
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    self.mapView.addAnnotation(annotation)
                    
                    // zoom out
                    let span = MKCoordinateSpanMake(0.010, 0.010)
                    let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
                    self.mapView.setRegion(region, animated: true)
                    
                }
            }
        })
    }
    

    
    var currentPlaceUrl: URL?
    
    
    
    
    
    
    
    // Search bar stays above keyboard when user is searching, then goes back down when done
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(up: true, moveValue: 260)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(up: false, moveValue: 260)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    func handleReturn() {
        let viewController = ViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    

    
    

    
    
    
// Mark: - Annotation views
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Restaurants"

        if annotation is Restaurants {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true

                let infoButton = UIButton(type: .detailDisclosure)
                
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: annotationView!.frame.height, height: annotationView!.frame.height))
                imageView.contentMode = .scaleAspectFit
                
                let restaurant = annotation as! Restaurants
                let placeName = restaurant.title!
                
                switch placeName {
                case "TurnToTech":
                    imageView.image = UIImage(named: "TTT")
                case "George's":
                    imageView.image = UIImage(named: "georges")
                case "TGI Friday's":
                    imageView.image = UIImage(named: "fridays")
                case "Reserve Cut":
                    imageView.image = UIImage(named: "reserveCut")
                case "Bill's Bar & Burger":
                    imageView.image = UIImage(named: "bills")
                default:
                    imageView.image = UIImage(named: "haras")
                }
                
                annotationView!.leftCalloutAccessoryView = imageView
                annotationView!.rightCalloutAccessoryView = infoButton
            } else {
                annotationView!.annotation = annotation
            }
            return annotationView
        }
        // searched annotation
        var annotationViews = mapView.dequeueReusableAnnotationView(withIdentifier: "user")
        
        if annotationViews == nil {
            annotationViews = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "user")
            annotationViews!.canShowCallout = true
            
            let infoButton = UIButton(type: .detailDisclosure)
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: annotationViews!.frame.height, height: annotationViews!.frame.height))
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "noImage")
            
            annotationViews!.leftCalloutAccessoryView = imageView
            annotationViews!.rightCalloutAccessoryView = infoButton
        } else {
            annotationViews!.annotation = annotation
        }
        
        
        return annotationViews
        
//        return nil
    }
    
    
    
    

    
    
    
    
// Mark: - WebView
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let selectedLoc = view.annotation
        if let placeName = selectedLoc?.title! {
            
            print("Annotation '\(selectedLoc?.title!)' has been selected")
            
            let selectedPlacemark = MKPlacemark(coordinate: (selectedLoc?.coordinate)!, addressDictionary: nil)
            let selectedMapItem = MKMapItem(placemark: selectedPlacemark)
        
            switch placeName {
            case "TurnToTech":
                if let tttUrl = URL(string: "http://turntotech.io") {
                    self.webView.load(URLRequest(url: tttUrl))
                }
            case "George's":
                if let georgesUrl = URL(string: "http://www.georges-ny.com") {
                    self.webView.load(URLRequest(url: georgesUrl))
                }
            case "TGI Friday's":
                if let fridaysUrl = URL(string: "https://www.tgifridays.com") {
                    self.webView.load(URLRequest(url: fridaysUrl))
                }
            case "Reserve Cut":
                if let rcUrl = URL(string: "http://reservecut.com") {
                    self.webView.load(URLRequest(url: rcUrl))
                }
            case "Bill's Bar & Burger":
                if let billsUrl = URL(string: "http://www.billsbarandburger.com") {
                    self.webView.load(URLRequest(url: billsUrl))
                }
            case "O'Hara's":
                if let oharasUrl = URL(string: "http://www.oharaspubnyc.com") {
                    self.webView.load(URLRequest(url: oharasUrl))
                }
            default:
                print("Website for selected location is: \(selectedMapItem.url)")
                if let site = selectedMapItem.url {
                    self.webView.load(URLRequest(url: site))
                    print("Website for selected location is: \(site)")
                }
            }
        }
        
    
        webView.allowsBackForwardNavigationGestures = true
        self.view = webView
        

        // WebView nav bar
        viewWillDisappear(true)
        
        var backButton = UIImage(named: "back")
        backButton = backButton?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backButton, style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleReturn))
        navigationItem.title = "Restaurant Webpage"

    }



    
    
    

    
    
// Mark: - TTT Logo
    
    lazy var turnToTechLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "TTT")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        // Shadows bc shadows are dope
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.7
        imageView.layer.shadowOffset = CGSize.zero
        imageView.layer.shadowRadius = 8
        
        // Cache the rendered shadow so it doesn't need to be redrawn every run
        imageView.layer.shouldRasterize = true
        
        return imageView
    }()
    
    func setupTurnToTechLogo() {
        turnToTechLogo.widthAnchor.constraint(equalToConstant: 80).isActive = true
        turnToTechLogo.heightAnchor.constraint(equalToConstant: 80).isActive = true
        turnToTechLogo.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        turnToTechLogo.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
    }
    
    
    
    
    
    
    
// Mark: - Segmented Control
    
    lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Standard", "Hybrid", "Satellite"])
        sc.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(mapTypeChanged), for: .valueChanged)
        
        return sc
    }()
    
    func setupSegmentedControl() {
        let margins = self.view.layoutMarginsGuide
        segmentedControl.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        segmentedControl.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -8).isActive = true
    }
    
    func mapTypeChanged(segControl: UISegmentedControl) {
        switch segControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        case 2:
            mapView.mapType = .satellite
        default:
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on WebView
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    
    
    
    
    


    
    
    

}

