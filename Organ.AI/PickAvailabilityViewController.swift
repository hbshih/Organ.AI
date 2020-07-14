//
//  PickAvailabilityViewController.swift
//  Organ.AI
//
//  Created by Ben on 2020/7/13.
//  Copyright © 2020 Organ.AI. All rights reserved.
//

import UIKit
import MapKit

class PickAvailabilityViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapkit: MKMapView!
    
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 6,
        minimumInteritemSpacing: 5,
        minimumLineSpacing: 5
       // sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    )
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! emptyCellCollectionViewCell
            return cell
        }
        
        
        if indexPath.item < 6
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! PickAvailabilityDateCollectionViewCell
            return cell
        }
        
        if indexPath.item % 6 == 0
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeCell", for: indexPath) as! PickAvailabilityTimeCollectionViewCell
            return cell
        }
        
        if indexPath.item == 17
        {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GreenCell", for: indexPath) as! PickAvailabilityCollectionViewCell
            cell.cell.backgroundColor = .gray
            return cell
        }
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GreenCell", for: indexPath) as! PickAvailabilityCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        performSegue(withIdentifier: "homeSegue", sender: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.collectionViewLayout = columnLayout
        collectionView?.contentInsetAdjustmentBehavior = .always
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        // Do any additional setup after loading the view.
        
        coordinates(forAddress: "Stockholm 111 23")
        {
            (location) in
            guard let location = location else {
                // Handle error here.
                return
            }
            
            print("get")
            print(location)
            
            
            let pLat = location.latitude
            let pLong = location.longitude
            let center = CLLocationCoordinate2D(latitude: pLat, longitude: pLong)

            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapkit.setRegion(region, animated: true)
        }
    }

    func coordinates(forAddress address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            (placemarks, error) in
            guard error == nil else {
                print("Geocoding error: \(error!)")
                completion(nil)
                return
            }
            completion(placemarks?.first?.location?.coordinate)
        }
    }
    
    
}
