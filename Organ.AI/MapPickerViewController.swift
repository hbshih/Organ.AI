//
//  MapPickerViewController.swift
//  Organ.AI
//
//  Created by Ben on 2020/8/9.
//  Copyright © 2020 Organ.AI. All rights reserved.
//

import UIKit
import LocationPicker

class MapPickerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let locationPicker = LocationPickerViewController()

                // you can optionally set initial location
         /*       let location = CLLocation(latitude: 35, longitude: 35)
                let initialLocation = Location(name: location, placemark: "city")
                locationPicker.location = initialLocation
        */
                // button placed on right bottom corner
                locationPicker.showCurrentLocationButton = true // default: true

                // default: navigation bar's `barTintColor` or `UIColor.white`
                locationPicker.currentLocationButtonBackground = .blue

                // ignored if initial location is given, shows that location instead
                locationPicker.showCurrentLocationInitially = true // default: true

                locationPicker.mapType = .standard // default: .Hybrid

                // for searching, see `MKLocalSearchRequest`'s `region` property
                locationPicker.useCurrentLocationAsHint = true // default: false

                locationPicker.searchBarPlaceholder = "Search places" // default: "Search or enter an address"

                locationPicker.searchHistoryLabel = "Previously searched" // default: "Search History"

                // optional region distance to be used for creation region when user selects place from search results
                locationPicker.resultRegionDistance = 500 // default: 600

                locationPicker.completion = { location in
                    // do some awesome stuff with location
                    /*
                    let center = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
                    
                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    self.mapkit.setRegion(region, animated: true)*/
                    
                    
                }
        
        
            //   self.present(locationPicker, animated: true, completion: nil)
        
       
        
              //  navigationController?.present(locationPicker, animated: true)
                

             //   navigationController?.pushViewController(locationPicker, animated: true)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
