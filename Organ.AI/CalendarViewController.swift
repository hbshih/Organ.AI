//
//  AddEventsViewController.swift
//  Organ.AI
//
//  Created by Ben on 2020/2/22.
//  Copyright © 2020 Organ.AI. All rights reserved.
//

import UIKit
import FSCalendar
import SwiftCheckboxDialog
import JFContactsPicker
import SCLAlertView
import EventKit
import EventKitUI

struct cellData
{
    var opened = Bool()
    var title = String()
    var sectionData = [String: Any]()
}

class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate, CheckboxDialogViewDelegate, ContactsPickerDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var weekMonthToggleOutlet: UIBarButtonItem!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var NoEventLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationItem!
    var triggerNotificationTimer = false
    
    // Data Accesible
    var tableViewData = [cellData]()
    var datesWithEvent: [String: [String]] = ["2020/03/14": ["id_1", "id_2"] , "2020/03/18": ["id_3"]]
    var eventDetail: [String: [String:String]] = ["id_1": ["startingTime":"12:00","endingTime":"13:00","title": "Hang out with Ather1", "detail": "Bring a gift1", "location":"Stockholm"],"id_2": ["startingTime":"12:00","endingTime":"13:00","title": "Hang out with Ather2", "detail": "Bring a gift2", "location":"Copenhagen"],"id_3": ["startingTime":"12:00","endingTime":"13:00","title": "Hang out with Ather3", "detail": "Bring a gift3", "location":"Stockholm"]]
    var datesWithEventDetails: [String: [String:String]] = [:]
    
    private var userEventIDMatching = ["id_2","id_3","id_4","id_5"]
    
    private var calendarEventDetail = ["id_1": ["Date": "2020/03/14", "StartingTime": "12:00", "EndingTime": "13:00", "Title": "Going to School", "Detail": "Bring Homework", "Location": "KTH Sweden", "Invitees": ["Brian","Ben"]],
                                       "id_2": ["Date": "2020/03/14", "StartingTime": "12:00", "EndingTime": "13:00", "Title": "Time to Go out", "Detail": "Bring Homework", "Location": "KTH Sweden", "Invitees": ["Brian","Ben"]],
                                       "id_3": ["Date": "2020/03/17", "StartingTime": "12:00", "EndingTime": "13:00", "Title": "Going to School1", "Detail": "Bring Homework", "Location": "KTH Sweden", "Invitees": ["Brian","Ben"]],
                                       "id_4": ["Date": "2020/03/19", "StartingTime": "12:00", "EndingTime": "13:00", "Title": "Going to School2", "Detail": "Bring Homework3", "Location": "KTH Sweden", "Invitees": ["Brian","Ben"]],
                                       "id_5": ["Date": "2020/03/19", "StartingTime": "12:00", "EndingTime": "13:00", "Title": "Going to School3", "Detail": "Bring Homework2", "Location": "KTH Sweden", "Invitees": ["Brian","Ben"]]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        
        // Setting Calendar UI
        
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
        self.view.addGestureRecognizer(self.scopeGesture)
        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        
        // Default selected date: Today
        self.calendar.select(Date())
        self.calendar.scope = .month
        
        let logo = UIImage(named: "WhiteLogo.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        
        // Load Calendar data
        let calendarManager = CalendarModel()
        
        let fh = FirestoreHandler()
        fh.getData(collection: "User")

        
    }
    
    var newEventStartDate: Date?
    var newEventEndDate: Date?
    var newEventTitle: String?
    var newEventLocation: String?
    var newEventNotes: String?
    
    override func viewDidAppear(_ animated: Bool) {
        
        if tableViewData.count > 0
        {
            tableView.reloadData()
            calendar.reloadData()
        }else
        {
             tableViewData = EventsCalendarManager().loadEvents(selectedCalendars: ["Testing Calendar"])
            tableView.reloadData()
            
            
            calendar.reloadData()
        }
        
               
        
tableView.backgroundColor = .clear
        
        print(tableViewData)
        
        if triggerNotificationTimer
        {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                
                         let appearance = SCLAlertView.SCLAppearance(
                           kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
                           kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                           kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                           showCloseButton: false,
                           dynamicAnimatorActive: true,
                           buttonsLayout: .vertical
                       )
                    
                    
                    
                       let alert = SCLAlertView(appearance: appearance)
                    _ = alert.addButton("Add Event To Your Calendar"){
                        
                        let newEvent = EKEvent(eventStore: EventsCalendarManager().eventStore)
                        
                        newEvent.title = self.newEventTitle
                        newEvent.startDate = self.newEventStartDate
                        newEvent.endDate = self.newEventEndDate
                        newEvent.location = self.newEventLocation
                        
                      /*  let startTime = DateFormatHandler().stringToDate(string_date: VC.time["time"]!)
                        newEvent.startDate = startTime
                        newEvent.endDate = startTime.addingTimeInterval(Double(VC.duration)*60.0*60.0)
                        newEvent.title = VC.activity[0]
                        newEvent.location = VC.placeholder[0]*/
                        EventsCalendarManager().addEventToCalendar(event: newEvent) { (error) in
                            DispatchQueue.main.async
                                {
                                    print("done add \(newEvent)")
                                    // self.navigationController?.popToRootViewController(animated: true)
                                    //      print(newEvent.eventIdentifier.)
                                    
                                    print(self.calendarEventDetail)
                                    
                               //     calendarEventDetail
                                    
                                    print(self.newEventTitle)
                                    print(self.newEventStartDate)
                                    print(self.newEventEndDate)
                                    print(self.newEventLocation)
                                    
                                    self.tableViewData.append(cellData(opened: false, title: DateFormatHandler().dateToFormattedString(date: self.newEventStartDate!), sectionData: ["Date": DateFormatHandler().dateToFormattedString(date: self.newEventStartDate!), "StartingTime": DateFormatHandler().dateToFormattedTimeString(date: self.newEventStartDate!), "EndingTime": DateFormatHandler().dateToFormattedTimeString(date: self.newEventEndDate!), "Title": self.newEventTitle!, "Detail": self.newEventNotes!, "Location": "WeWork", "Invitees": ["Ben"]]
                                    ))
                                    
                                    print(self.calendarEventDetail)
                                    
                                    self.tableView.reloadData()
                                    self.calendar.reloadData()
                            }
                        }
                        
                    }
                       _ = alert.addButton("Delete Event") {
                           print("Second button tapped")
                       }
                       
                    let icon = UIImage(named:"checked")
                
                       let color = UIColor.orange
                    
                    _ = alert.showCustom("Invitation Accepted", subTitle: "Your meeting with Ben Shih has been confirmed", color: color, icon: icon!)
                }
                
            }
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
         self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                       self.navigationController?.navigationBar.shadowImage = UIImage()
                       self.navigationController?.navigationBar.isTranslucent = true
                       self.navigationController!.navigationBar.backgroundColor = UIColor.clear
    }
    
    deinit {
        print("\(#function)")
    }
    
    var checkboxDialogViewController: CheckboxDialogViewController!
    @IBAction func selectCalendarDisplay(_ sender: Any) {
        
        let allCalendars = EventsCalendarManager().loadCalendars()
        
        print("all calendar")
        print(allCalendars)
        
        var tableData :[(name: String, translated: String)] = []
        for calendar in allCalendars
        {
            tableData.append((name: calendar, translated: calendar))
        }
        
        self.checkboxDialogViewController = CheckboxDialogViewController()
        self.checkboxDialogViewController.titleDialog = "Calendars"
        self.checkboxDialogViewController.tableData = tableData
        self.checkboxDialogViewController.componentName = DialogCheckboxViewEnum.countries
        self.checkboxDialogViewController.delegateDialogTableView = self
        self.checkboxDialogViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(self.checkboxDialogViewController, animated: false, completion: nil)
        
        print(UserDefaults.standard.array(forKey: "selectedCalendars"))
        
    }
    
    func onCheckboxPickerValueChange(_ component: DialogCheckboxViewEnum, values: TranslationDictionary) {
        print(values.keys)
        let newNames: [String] = Array(values.keys)
        UserDefaults.standard.set(newNames, forKey: "selectedCalendars")
        
        tableViewData = EventsCalendarManager().loadEvents(selectedCalendars: newNames)
        tableView.reloadData()
        calendar.reloadData()
        //UserDefaults.standard.set(newNames,)
    }
    
    @IBAction func addNewEvent(_ sender: Any) {
        
        performSegue(withIdentifier: "MessengeKitSegue", sender: nil)
        
       // performSegue(withIdentifier: "addEventWithAISegue", sender: nil)

        /*
        Bundle.main.loadNibNamed(String(describing: ManualAddEntryViewController.self), owner: self, options: nil)*/
        
    }
    // Controlling week view or month view
    private var calendarWeekView = true
    @IBAction func ToggleCalendarPresent(_ sender: Any) {
        if calendarWeekView
        {
            calendarWeekView = false
            self.calendar.setScope(.month, animated: true)
            weekMonthToggleOutlet.title = "Week"
        }else
        {
            calendarWeekView = true
            self.calendar.setScope(.week, animated: true)
            weekMonthToggleOutlet.title = "Month"
        }
    }
    
    // Load calendar dots for date with events
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = DateFormatHandler().dateToFormattedString(date: date)
        var counter = 0
        
        for data in tableViewData
        {
            if data.title == dateString
            {
                counter += 1
            }
        }
        return counter
      /*
        if self.datesWithEvent.keys.contains(dateString){
            return datesWithEvent[dateString]!.count
        }
        return 0*/
    }
    
    // Calendar View UI Setting
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print(DateFormatHandler().dateToFormattedString(date: calendar.currentPage))
    }
    
    @IBAction func contactTapped(_ sender: Any) {
     
        let contactPicker = ContactsPicker(delegate: self, multiSelection:false, subtitleCellType: .email)
        let navigationController = UINavigationController(rootViewController: contactPicker)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    //MARK: EPContactsPicker delegates
    func contactPicker(_: ContactsPicker, didContactFetchFailed error: NSError) {
        print("Failed with error \(error.description)")
    }
    
    func contactPicker(_: ContactsPicker, didSelectContact contact: Contact) {
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
        }
    
    }
    
    var selectedDate = ""
    var selectedDay = ""
    
    private var numberOfEventInDate = 0
    //   private var selectedDate =
    
    // Selected a particular date
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let dateString = DateFormatHandler().dateToFormattedString(date: date)
        let dayString = DateFormatHandler().dayToDayFormattedString(date: date)
        
        // Prepare to load number of events in Date
        var counter = 0

        for data in tableViewData
        {
            if data.title == dateString
            {
                counter += 1
            }
        }
        
        numberOfEventInDate = counter
        selectedDate = dateString
        selectedDay = dayString
        tableView.reloadData()
    
        if counter == 0
        {
            tableView.isHidden = true
            NoEventLabel.isHidden = false
            print("nothing")
        }else
        {
            tableView.isHidden = false
            NoEventLabel.isHidden = true
        }
        
       /* return counter
        
        if self.datesWithEvent.keys.contains(dateString) {
            numberOfEventInDate = datesWithEvent[dateString]!.count
            selectedDate = dateString
            selectedDay = dayString
            tableView.reloadData()
        }else
        {
            numberOfEventInDate = 0
            tableView.reloadData()
        }*/

        // Setting UI for next month/previous month
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    // Number of events = number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfEventInDate
    }
    
    // To show event details, number of rows in section will have to increase by one.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].opened == true
        {
            return 2
            //return tableViewData[section].sectionData.count + 1
        }else
        {
            if numberOfEventInDate != 0
            {
                return 1
            }else
            {
                return 0
            }
        }
    }
    
    // Cell View
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // data for the selected day
        var presentDataList = [cellData]()
        presentDataList.removeAll()
        
        
        for data in tableViewData{
            if data.title == selectedDate
            {
                presentDataList.append(data)
            }
        }
        
        print(presentDataList)
        
        // Event
        if indexPath.row == 0
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_events") as? CalendarTableViewCell else {return UITableViewCell()}
            
            cell.eventDescription.text = presentDataList[indexPath.section].sectionData["Title"] as? String
            cell.startingTime.text = presentDataList[indexPath.section].sectionData["StartingTime"] as? String
            cell.endingTime.text = presentDataList[indexPath.section].sectionData["EndingTime"] as? String
            cell.importantLevelColor.backgroundColor = presentDataList[indexPath.section].sectionData["Color"] as? UIColor
            cell.date.text = selectedDay
            return cell
        }else
        {
            
            // Event Detail
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventDetailCell") as? eventDetailTableViewCell else {return UITableViewCell()}
          //  cell.eventLocation.text = presentDataList[indexPath.section].sectionData["Location"] as? String
            
            cell.eventLocation.setTitle((presentDataList[indexPath.section].sectionData["Location"] as? String)!, for: .normal)
    //        cell.eventLocation.titleLabel = (presentDataList[indexPath.section].sectionData["Location"] as? String)!

            
            if ((presentDataList[indexPath.section].sectionData["Detail"] as? String) != nil)
            {
                cell.eventNote.text = presentDataList[indexPath.section].sectionData["Detail"] as? String
            }else
            {
                cell.eventNote.text = "Notes..."
                cell.eventNote.textColor = .gray
            }
            
            if ((presentDataList[indexPath.section].sectionData["Title"] as? String)?.contains("seo"))!
            {
                //cell.eventLocation.text = "Room A"
                cell.eventNote.text = "Task 1 Completed"
            }
            return cell
        }
        
        
        
        /*for testing*/
        
    }
    
    // Expand and collapse height setting
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 1
        {
            return 110
        }
        else
        {
            return 55
        }
    }
    
    // Expand and collapse controller
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableViewData[indexPath.section].opened == true
        {
            tableViewData[indexPath.section].opened = false
            let sections = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(sections, with: .none)
        }else
        {
            tableViewData[indexPath.section].opened = true
            let sections = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(sections, with: .none)
        }
    }
    
    // Height for section header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3
    }
    

    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
        }()
    
}
