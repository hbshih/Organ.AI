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

struct cellData
{
    var opened = Bool()
    var title = String()
    var sectionData = [String: Any]()
}

class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate, CheckboxDialogViewDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var weekMonthToggleOutlet: UIBarButtonItem!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    
    
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
        self.calendar.scope = .week
        
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        
        // Load Calendar data
        let calendarManager = CalendarModel()
        
        let fh = FirestoreHandler()
        fh.getData(collection: "User")
        
        var calendarData = calendarManager.getCalendar()
        //  print("All Calendar Data: \(calendarData)")
        
        var event_id = calendarData["event_id"] as! [String]
        var calendar_id = calendarData["id"] as! String
        var date_occupied = calendarData["date_occupied"] as! [String: [String]]
        
        var eventManager = EventModel()
        
        for event in event_id
        {
            
        }
        
        for eventID in userEventIDMatching
        {
            if calendarEventDetail.keys.contains(eventID)
            {
                tableViewData.append(cellData(opened: false, title: calendarEventDetail[eventID]!["Date"] as! String, sectionData: calendarEventDetail[eventID]!))
            }
        }
        
        UserDefaults.standard.array(forKey: "")
        
        
        
        
        
        
        
        /*
        tableViewData = [cellData(opened: false, title: "2020/03/14", sectionData: ["id1"]),
                         cellData(opened: false, title: "2020/03/14", sectionData: ["id2"]),
                         cellData(opened: false, title: "2020/03/18", sectionData: ["id3"])]*/
        
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
        self.checkboxDialogViewController.titleDialog = "Countries"
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
        
        performSegue(withIdentifier: "addEventWithAISegue", sender: nil)

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
            
            
            cell.eventLocation.text = presentDataList[indexPath.section].sectionData["Location"] as? String
            cell.eventNote.text = presentDataList[indexPath.section].sectionData["Detail"] as? String
            /*
            cell.eventLocation.text = eventDetail[datesWithEvent[selectedDate]![indexPath.section]]?["location"]
            cell.eventNote.text = eventDetail[datesWithEvent[selectedDate]![indexPath.section]]?["detail"]*/
            return cell
        }
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
