//
//  PickAvailabilityViewController.swift
//  Organ.AI
//
//  Created by Ben on 2020/7/13.
//  Copyright © 2020 Organ.AI. All rights reserved.
//

import UIKit
import MapKit
import JFContactsPicker
import ContactsUI


class PickAvailabilityViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ContactsPickerDelegate
{
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var participantCollectionView: UICollectionView!
    @IBOutlet weak var mapkit: MKMapView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventAddress: UILabel!
    
    var contactName = [String]()
    var contactImage = [UIImage]()
    
    var participants = [String]()
    
    var timeCount = 0
    
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 6,
        minimumInteritemSpacing: 5,
        minimumLineSpacing: 5,
        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    )
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == participantCollectionView
        {
            return self.contactName.count
        }
        
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == participantCollectionView
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "participantCell", for: indexPath) as! ParticipantCollectionViewCell
            
                cell.label.text = contactName[indexPath.item]
            cell.iamge.image = contactImage[indexPath.item]
            
            
            
            
            
            return cell
            
        }
        
        
        
        if indexPath.item == 0
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! emptyCellCollectionViewCell
            return cell
        }
        
        
        if indexPath.item < 6
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! PickAvailabilityDateCollectionViewCell
            
            switch indexPath.item {
            case 1:
                cell.date.text = "July\n8\nMon"
            case 2:
                cell.date.text = "July\n9\nTue"
            case 3:
                cell.date.text = "July\n10\nWed"
            case 4:
                cell.date.text = "July\n11\nThu"
            case 5:
                cell.date.text = "July\n12\nFri"
            default:
                cell.date.text = ""
            }
            
            return cell
        }
        
        if indexPath.item % 6 == 0
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeCell", for: indexPath) as! PickAvailabilityTimeCollectionViewCell
            
            switch timeCount {
            case 1:
                cell.timeCell.text = "10:00 - 11:00"
            case 2:
                cell.timeCell.text = "13:00 - 14:00"
            case 3:
                cell.timeCell.text = "15:20 - 16:20"
            case 4:
                cell.timeCell.text = "19:00 - 20:00"
            default:
                cell.timeCell.text = "10:00 - 11:00"
            }
            
            timeCount += 1
            
            
            return cell
        }
        
        if indexPath.item == 17 || indexPath.item == 14
        {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GreenCell", for: indexPath) as! PickAvailabilityCollectionViewCell
            cell.cell.backgroundColor = .gray
            return cell
        }
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GreenCell", for: indexPath) as! PickAvailabilityCollectionViewCell
        return cell
    }
    
    var SelectedCell = IndexPath()
    var timeSelected = false
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if timeSelected == false
        {
            let cell = collectionView.cellForItem(at: indexPath) as! PickAvailabilityCollectionViewCell
            cell.cell.backgroundColor = UIColor(red: 66/255, green: 173/255, blue: 162/255, alpha: 1.0)
            cell.timeText.text = "Selected"
            SelectedCell = indexPath
            timeSelected = true
        }else
        {
            var cell = collectionView.cellForItem(at: SelectedCell) as! PickAvailabilityCollectionViewCell
            cell.cell.backgroundColor = UIColor(red: 114/255, green: 215/255, blue: 210/255, alpha: 1.0)
            cell.timeText.text = "Available"
            
            cell = collectionView.cellForItem(at: indexPath) as! PickAvailabilityCollectionViewCell
            cell.cell.backgroundColor = UIColor(red: 66/255, green: 173/255, blue: 162/255, alpha: 1.0)
            cell.timeText.text = "Selected"
            SelectedCell = indexPath
        }
    }
    
    @IBAction func addInvitees(_ sender: Any) {
        
        let contactPicker = ContactsPicker(delegate: self, multiSelection: true, subtitleCellType: .email)
        let navigationController = UINavigationController(rootViewController: contactPicker)
        self.present(navigationController, animated: true, completion: nil)
        
    }
    
    //MARK: EPContactsPicker delegates
    func contactPicker(_: ContactsPicker, didContactFetchFailed error: NSError) {
        print("Failed with error \(error.description)")
        
    }
    
    func contactPicker(_: ContactsPicker, didSelectContact contact: Contact) {
        //   contact.
        print("Contact \(contact.displayName) has been selected")
    }
    
    func contactPickerDidCancel(_ picker: ContactsPicker) {
        picker.dismiss(animated: true, completion: nil)
        print("User canceled the selection");
    }
    
    func contactPicker(_ picker: ContactsPicker, didSelectMultipleContacts contacts: [Contact]) {
        defer { picker.dismiss(animated: true, completion: nil) }
        guard !contacts.isEmpty else { return }
        print("The following contacts are selected")
        for contact in contacts {
            print("\(contact.displayName)")
            let name = "\(contact.firstName) \(contact.lastName)"
            contactName.append(name)
            if let image = contact.profileImage as? UIImage
            {
                contactImage.append(image)
            }else
            {
                contactImage.append(UIImage(named: "user")!)
            }
          //  contactImage.append(contact.profileImage ?? UIImage(named: "user"))
        }
        participantCollectionView.reloadData()
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
    
    override func viewDidAppear(_ animated: Bool) {
        print("Participants \(participants)")
        

        
        
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
    
    @IBAction func confirmMeeting(_ sender: Any) {
        performSegue(withIdentifier: "homeSegue", sender: nil)
    }
    
}
