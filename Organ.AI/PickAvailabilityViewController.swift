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
import LocationPicker
import KVKCalendar


class PickAvailabilityViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ContactsPickerDelegate
{
    
    /*Calendar*/
    
    private var events = [Event]()
       
       // Set First day
        var selectDate: Date?
       
       
       private lazy var style: Style = {
           var style = Style()
           
           style.defaultType = .week
           
           if UIDevice.current.userInterfaceIdiom == .phone {
               style.month.isHiddenSeporator = true
               style.timeline.widthTime = 40
               style.timeline.offsetTimeX = 1
               style.timeline.offsetLineLeft = 2
           } else {
               style.timeline.widthEventViewer = 500
           }
           style.timeline.startFromFirstEvent = false
           //style.timezone = TimeZone.
           style.followInSystemTheme = true
           style.timeline.offsetTimeY = 30
           style.timeline.offsetEvent = 3
           style.timeline.currentLineHourWidth = 10
           style.allDay.isPinned = true
           style.startWeekDay = .sunday
           style.timeHourSystem = .twentyFourHour
           style.event.isEnableMoveEvent = true
           style.timezone = TimeZone(abbreviation: "GMT+1")!
           return style
       }()
       
       private lazy var calendarView: CalendarView = {
        let calendar = CalendarView(frame: view.frame, date: selectDate ?? Date(), style: style)
           calendar.delegate = self
           calendar.dataSource = self
           return calendar
       }()
       
     /*  private lazy var segmentedControl: UISegmentedControl = {
           let array = CalendarType.allCases
           let control = UISegmentedControl(items: array.map({ $0.rawValue.capitalized }))
           control.tintColor = .systemRed
           control.selectedSegmentIndex = 0
           control.addTarget(self, action: #selector(switchCalendar), for: .valueChanged)
           return control
       }()*/
       
       private lazy var eventViewer: EventViewer = {
           let view = EventViewer(frame: CGRect(x: 0, y: 0, width: 500, height: calendarView.frame.height))
           return view
       }()
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var participantCollectionView: UICollectionView!
    @IBOutlet weak var mapkit: MKMapView!
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var eventLocation: UIButton!
    @IBOutlet weak var eventLocation_Label: UILabel!
    @IBOutlet weak var pickAvailabilityView: UIView!
    @IBOutlet weak var eventNotes: UITextView!
  //  var startdate: Date?
    
    var selectedSlots = [Event]()
    
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
        
        self.navigationController?.isNavigationBarHidden = true
        
        collectionView?.collectionViewLayout = columnLayout
        collectionView?.contentInsetAdjustmentBehavior = .always
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        // Do any additional setup after loading the view.
        
        coordinates(forAddress: "Regeringsgatan 29, 111 53 Stockholm")
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
            
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            self.mapkit.setRegion(region, animated: true)
        }
        
        pickAvailabilityView.addSubview(calendarView)
      //    view.addSubview(calendarView)
        //  navigationItem.titleView = segmentedControl
        //  navigationItem.rightBarButtonItem = todayButton
          
          calendarView.addEventViewToDay(view: eventViewer)
          
          loadEvents { [weak self] (events) in
              DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                  //self?.events = events
                //  self?.calendarView.reloadData()
              }
          }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var frame = view.frame
        frame.origin.y = 0
        calendarView.reloadFrame(frame)
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
        
        
        //upload event to DB
        
        performSegue(withIdentifier: "homeSegue", sender: nil)
    }
    
    
    
    @IBAction func pickLocationTapped(_ sender: Any) {
        
        print("tapped")
        
        
    }
    
    var location: Location? {
        didSet {
            eventLocation_Label.text = location.flatMap({ $0.title }) ?? "No location selected"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "homeSegue"
        {
            print("segueing")
            print(selectedSlots)
            if let VC = segue.destination as? UINavigationController
            {
                if let controller = VC.viewControllers.first as? CalendarViewController
                {
                    print("checl")
         //           print(selectedSlots[0].start)
                    if selectedSlots.count > 0
                    {
                    controller.newEventStartDate = selectedSlots[0].start
                    controller.newEventEndDate = selectedSlots[0].end
                    controller.newEventTitle = eventTitle.text
                    controller.newEventLocation = "WeWork"
                    controller.newEventNotes = eventNotes.text
                        controller.triggerNotificationTimer = true
                    }
                }
            }
            

            
        }
        
        if segue.identifier == "LocationPicker" {
            
            
            let locationPicker = segue.destination as! LocationPickerViewController
            locationPicker.location = location
            locationPicker.showCurrentLocationButton = true
            locationPicker.useCurrentLocationAsHint = true
            locationPicker.selectCurrentLocationInitially = true
            locationPicker.completion = { self.location = $0 }
        }
    }
    
}

extension PickAvailabilityViewController: CalendarDelegate {
 
    /*func didChangeEvent(_ event: Event, start: Date?, end: Date?) {
        var eventTemp = event
        guard let startTemp = start, let endTemp = end else { return }
        
        let startTime = timeFormatter(date: startTemp)
        let endTime = timeFormatter(date: endTemp)
        eventTemp.start = startTemp
        eventTemp.end = endTemp
        eventTemp.text = "\(startTime) - \(endTime)\n new time"
        
        if let idx = events.firstIndex(where: { $0.compare(eventTemp) }) {
            events.remove(at: idx)
            events.append(eventTemp)
      //      calendarView.reloadData()
        }
    }*/
    
    func didSelectDate(_ date: Date?, type: CalendarType, frame: CGRect?) {
        selectDate = date ?? Date()
        calendarView.reloadData()
    }
    
    func didSelectEvent(_ event: Event, type: CalendarType, frame: CGRect?) {
        
        
        var eventTemp = event
    
        if eventTemp.backgroundColor == UIColor.black
        {
            let color = UIColor.cyan
            eventTemp.backgroundColor = color
            eventTemp.text = "Selected"
            
            selectedSlots.append(event)
            
        }else
        {
            let color = UIColor.black
            eventTemp.backgroundColor = color
            eventTemp.text = "Available"
            
            if let idx = selectedSlots.firstIndex(where: { $0.compare(event)})
            {
                selectedSlots.remove(at: idx)
            }
            
        }
                
        if let idx = events.firstIndex(where: { $0.compare(eventTemp) }) {
            events.remove(at: idx)
            events.append(eventTemp)
            calendarView.reloadData()
        }
        
       // print(event)
        //print(events)
        print(selectedSlots)
    }
    
    func didSelectMore(_ date: Date, frame: CGRect?) {
        print(date)
    }
    
    func eventViewerFrame(_ frame: CGRect) {
        eventViewer.reloadFrame(frame: frame)
    }
}

extension PickAvailabilityViewController: CalendarDataSource {
    func eventsForCalendar() -> [Event] {
        return events
    }
    
    private var dates: [Date] {
        return Array(0...10).compactMap({ Calendar.current.date(byAdding: .day, value: $0, to: Date()) })
    }
    /*
    func willDisplayDate(_ date: Date?, events: [Event]) -> DateStyle? {
        guard dates.first(where: { $0.year == date?.year && $0.month == date?.month && $0.day == date?.day }) != nil else { return nil }
        
        return DateStyle(backgroundColor: .orange, textColor: .black, dotBackgroundColor: .red)
    }*/
    
    func willDisplayEventView(_ event: Event, frame: CGRect, date: Date?) -> EventViewGeneral? {
        guard event.ID == "2" else { return nil }
        
        return CustomViewEvent(style: style, event: event, frame: frame)
    }
}

extension PickAvailabilityViewController {
    func loadEvents(completion: ([Event]) -> Void) {
        let decoder = JSONDecoder()
        
        guard let url = URL(string: "https://us-central1-organai-service.cloudfunctions.net/getParticipantAvailability"),
            let payload = "{\"event_id\": \"R57FXMD6IBccm1P1pGkS\"}".data(using: .utf8) else
        {
            print("hey")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        //  request.addValue("your_api_key", forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else { print(error!.localizedDescription); return }
          //  guard let data = data else { print("Empty data"); return }
            
            let decoder = JSONDecoder()
                       
            if let data = data, let dataList = try? decoder.decode(jsonData.self, from: data) {
                        
          //      print(dataList.users!)
                //print(dataList.users!.username)
                
                for i in 0..<7
                {
                    for j in 0..<dataList.users.bookedSlots[0][i].bookedSlots.count
                    {
                        let startT = "\(dataList.users.bookedSlots[0][i].date) \(dataList.users.bookedSlots[0][i].bookedSlots[j].start_time) +08:00"
                        
                        let converted_startT = self.formatter(date: startT)
                        let endT = converted_startT.addingTimeInterval(Double(dataList.users.bookedSlots[0][i].bookedSlots[j].duration)*60.0*60.0)
                        
                        self.events.append(Event.init(ID: "\(i) \(j)", text: "Available", start: converted_startT, end: endT, color: EventColor(.white), backgroundColor: .black, textColor: .white, isAllDay: false, isContainsFile: false, textForMonth: "asd", eventData: nil, recurringType: .none))
                    }
                }
                
                print(self.events)

                
                DispatchQueue.main.async {
                    
                    self.calendarView.reloadData()
                }
                       } else {
                           print("Error...")
                       }
            
            
            
            
        }.resume()
        completion(events)
    }
    
    func timeFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = style.timeHourSystem.format
        return formatter.string(from: date)
    }
    
    func formatter(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "E MMM dd yyyy HH:mm Z"
        return formatter.date(from: date) ?? Date()
    }
}

extension PickAvailabilityViewController: UIPopoverPresentationControllerDelegate { }

struct ItemData: Decodable {
    let data: [Item]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([Item].self, forKey: CodingKeys.data)
    }
}

struct jsonData: Decodable
{
    var users: users
}

struct users: Decodable
{
    var username: String
    var bookedSlots: [[occupied]]
}

struct occupied: Decodable
{
    var date: String
    var bookedSlots: [bookedDetails]
}

struct bookedDetails: Decodable {
    var start_time: String
    var duration: Double
}

struct Item: Decodable {
    let id: String, title: String, start: String, end: String
    let color: UIColor, colorText: UIColor
    let files: [String]
    let allDay: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, title, start, end, color, files
        case colorText = "text_color"
        case allDay = "all_day"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: CodingKeys.id)
        title = try container.decode(String.self, forKey: CodingKeys.title)
        start = try container.decode(String.self, forKey: CodingKeys.start)
        end = try container.decode(String.self, forKey: CodingKeys.end)
        allDay = try container.decode(Int.self, forKey: CodingKeys.allDay) != 0
        files = try container.decode([String].self, forKey: CodingKeys.files)
        let strColor = try container.decode(String.self, forKey: CodingKeys.color)
        color = UIColor.hexStringToColor(hex: strColor)
        let strColorText = try container.decode(String.self, forKey: CodingKeys.colorText)
        colorText = UIColor.hexStringToColor(hex: strColorText)
    }
}

extension UIColor {
    static func hexStringToColor(hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count != 6 {
            return .gray
        }
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                       alpha: 1.0)
    }
}

final class CustomViewEvent: EventViewGeneral {
    override init(style: Style, event: Event, frame: CGRect) {
        super.init(style: style, event: event, frame: frame)
        
        let imageView = UIImageView(image: UIImage(named: "ic_stub"))
        imageView.frame = CGRect(origin: CGPoint(x: 3, y: 1), size: CGSize(width: frame.width - 6, height: frame.height - 2))
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        backgroundColor = event.backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
