//
//  NativeEventExample.swift
//  Example
//
//  Created by Mathias Claassen on 3/15/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Eureka
import EventKit

class NativeEventNavigationController: UINavigationController, RowControllerType {
    var onDismissCallback : ((UIViewController) -> ())?
}

class NativeEventFormViewController : FormViewController, RowControllerType {
    var onDismissCallback: ((UIViewController) -> Void)?
    
    
    var eventData : [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print()
        
        initializeForm()
        
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(NativeEventFormViewController.cancelTapped(_:))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(NativeEventFormViewController.addTapped))
     //   self.navigationController?.title = "New Event"
        self.title = "New Event"
    }
    
    var startDate = Date()
    var endDate = Date().addingTimeInterval(60*60)
    
    @objc func addTapped()
    {
        print("tapped")
        let newEvent = EKEvent(eventStore: EventsCalendarManager().eventStore)
        newEvent.title = eventData["title"] as? String
        if let start = eventData["start"] as? Date
        {
            newEvent.startDate = start
        }else
        {
            newEvent.startDate = startDate
        }
        
        if let end = eventData["end"] as? Date
        {
            newEvent.endDate = end
        }else
        {
            newEvent.endDate = endDate
        }
       // newEvent.location = eventData["location"] as? String
        if let loc = eventData["location"] as? String
        {
            newEvent.location = loc
            newEvent.structuredLocation = EKStructuredLocation(title: loc)
        }
     //   newEvent.structuredLocation = EKStructuredLocation(title: <#T##String#>)
        newEvent.notes = (eventData["participant"] as? [String])?.joined(separator: ",")
        
        print(newEvent)
        
        /*
         
         For Testing
        */
        /*
        print(eventData["participant"] as? [String])
        print((eventData["participant"] as? [String])?.contains("zack"))
        
        if ((eventData["participant"] as? [String])?.contains("zack"))!
        {
          //  print("set")
            UserDefaults.standard.set(newEvent.title, forKey: "t1_title")
            if let loc = eventData["location"] as? String
            {
                UserDefaults.standard.set(loc, forKey: "t1_location")
            }
            
        }
        else if ((eventData["participant"] as? [String])?.contains("erik"))!
        {
            UserDefaults.standard.set(eventData["title"] as? String, forKey: "t3_title")
            UserDefaults.standard.set(eventData["location"], forKey: "t3_location")
        }else
        {
            UserDefaults.standard.set(eventData["title"] as? String, forKey: "t2_title")
            UserDefaults.standard.set(eventData["location"], forKey: "t2_location")
        }
        */
        
        
        EventsCalendarManager().addEventToCalendar(event: newEvent) { (error) in
            DispatchQueue.main.async
                {
            self.navigationController?.popToRootViewController(animated: true)
              //      print(newEvent.eventIdentifier.)
            }
        }
    }
    
    private func initializeForm() {
        
        print(eventData)
        
        form +++
            
            TextRow("Title").cellSetup { cell, row in
                cell.textField.placeholder = row.tag
                cell.textField.textAlignment = .left
                cell.textField.text = self.eventData["title"] as? String
                row.value = self.eventData["title"] as? String
                if self.eventData["title"] != nil
                {
                    cell.textField.placeholder = ""
                    row.value = self.eventData["title"] as? String
                }
            }.onChange({ (text) in
                self.eventData["title"] = text.value
            })
            
            <<< TextRow("Location").cellSetup {
                $1.cell.textField.placeholder = $0.row.tag
                $0.row.value = self.eventData["location"] as? String
                
                if self.eventData["location"] != nil
                {
                    $1.cell.textField.placeholder = ""
                    $1.cell.textField.text = self.eventData["location"] as? String
                }
            }.onChange({ (location) in
                self.eventData["location"] = location.value
            })
            
            +++
            
            SwitchRow("All-day") {
                $0.title = $0.tag
            }.onChange { [weak self] row in
                let startDate: DateTimeInlineRow! = self?.form.rowBy(tag: "Starts")
                let endDate: DateTimeInlineRow! = self?.form.rowBy(tag: "Ends")
                
                if row.value ?? false {
                    startDate.dateFormatter?.dateStyle = .medium
                    startDate.dateFormatter?.timeStyle = .none
                    endDate.dateFormatter?.dateStyle = .medium
                    endDate.dateFormatter?.timeStyle = .none
                }
                else {
                    startDate.dateFormatter?.dateStyle = .short
                    startDate.dateFormatter?.timeStyle = .short
                    endDate.dateFormatter?.dateStyle = .short
                    endDate.dateFormatter?.timeStyle = .short
                }
                startDate.updateCell()
                endDate.updateCell()
                startDate.inlineRow?.updateCell()
                endDate.inlineRow?.updateCell()
            }
            
            <<< DateTimeInlineRow("Starts") {
                $0.title = $0.tag
                if eventData["start"] != nil
                {
                    $0.value = eventData["start"] as? Date
                    self.startDate = (eventData["start"] as? Date)!
                }else
                {
                    $0.value = Date()
                }
            }
            .onChange { [weak self] row in
                let endRow: DateTimeInlineRow! = self?.form.rowBy(tag: "Ends")
                if row.value?.compare(endRow.value!) == .orderedDescending {
                    endRow.value = Date(timeInterval: 60*60*24, since: row.value!)
                    endRow.cell!.backgroundColor = .white
                    endRow.updateCell()
                }
            }
            .onExpandInlineRow { [weak self] cell, row, inlineRow in
                inlineRow.cellUpdate() { cell, row in
                    let allRow: SwitchRow! = self?.form.rowBy(tag: "All-day")
                    if allRow.value ?? false {
                        cell.datePicker.datePickerMode = .date
                        if self!.eventData["start"] != nil
                        {
                            cell.datePicker.setDate((self!.eventData["start"] as? Date)!, animated: true)
                            cell.datePicker.date = (self!.eventData["start"] as? Date)!
                        }
                    }
                    else {
                        cell.datePicker.datePickerMode = .dateAndTime
                        if self!.eventData["start"] != nil
                        {
                            cell.datePicker.setDate((self!.eventData["start"] as? Date)!, animated: true)
                            cell.datePicker.date = (self!.eventData["start"] as? Date)!
                        }
                    }
                }
                let color = cell.detailTextLabel?.textColor
                row.onCollapseInlineRow { cell, _, _ in
                    cell.detailTextLabel?.textColor = color
                }
                cell.detailTextLabel?.textColor = cell.tintColor
            }
            
            <<< DateTimeInlineRow("Ends"){
                $0.title = $0.tag
                if self.eventData["end"] != nil
                {
                    $0.value = eventData["end"] as? Date
                }else
                {
                    $0.value = Date()
                }
            }
            .onChange { [weak self] row in
                let startRow: DateTimeInlineRow! = self?.form.rowBy(tag: "Starts")
                if row.value?.compare(startRow.value!) == .orderedAscending {
                    row.cell!.backgroundColor = .red
                }
                else{
                    row.cell!.backgroundColor = .white
                }
                row.updateCell()
            }
            .onExpandInlineRow { [weak self] cell, row, inlineRow in
                inlineRow.cellUpdate { cell, dateRow in
                    let allRow: SwitchRow! = self?.form.rowBy(tag: "All-day")
                    if allRow.value ?? false {
                        cell.datePicker.datePickerMode = .date
                        if self!.eventData["end"] != nil
                        {
                            cell.datePicker.setDate((self!.eventData["end"] as? Date)!, animated: true)
                            cell.datePicker.date = (self!.eventData["end"] as? Date)!
                        }
                    }
                    else {
                        cell.datePicker.datePickerMode = .dateAndTime
                        if self!.eventData["end"] != nil
                        {
                            cell.datePicker.setDate((self!.eventData["end"] as? Date)!, animated: true)
                            cell.datePicker.date = (self!.eventData["end"] as? Date)!
                        }
                    }
                }
                let color = cell.detailTextLabel?.textColor
                row.onCollapseInlineRow { cell, _, _ in
                    cell.detailTextLabel?.textColor = color
                }
                cell.detailTextLabel?.textColor = cell.tintColor
        }
        
        form +++
            
            PushRow<RepeatInterval>("Repeat") {
                $0.title = $0.tag
                $0.options = RepeatInterval.allCases
                $0.value = .Never
            }.onPresent({ (_, vc) in
                vc.enableDeselection = false
                vc.dismissOnSelection = false
            })
        
        form +++
            
            PushRow<EventAlert>() {
                $0.title = "Alert"
                $0.options = EventAlert.allCases
                $0.value = .Never
            }
            .onChange { [weak self] row in
                if row.value == .Never {
                    if let second : PushRow<EventAlert> = self?.form.rowBy(tag: "Another Alert"), let secondIndexPath = second.indexPath {
                        row.section?.remove(at: secondIndexPath.row)
                    }
                }
                else{
                    guard let _ : PushRow<EventAlert> = self?.form.rowBy(tag: "Another Alert") else {
                        let second = PushRow<EventAlert>("Another Alert") {
                            $0.title = $0.tag
                            $0.value = .Never
                            $0.options = EventAlert.allCases
                        }
                        let secondIndex = row.indexPath!.row + 1
                        row.section?.insert(second, at: secondIndex)
                        return
                    }
                }
        }
        
        form +++
            
            PushRow<EventState>("Show As") {
                $0.title = "Show As"
                $0.options = EventState.allCases
        }
        
        
        
        form +++
            
            MultivaluedSection(multivaluedOptions: [.Insert, .Delete],
                               header: "Participants",
                               footer: nil) {
                                $0.tag = "textfields"
                                $0.addButtonProvider = { section in
                                    return ButtonRow(){
                                        $0.title = "Add New Participant"
                                    }.cellUpdate { cell, row in
                                        cell.textLabel?.textAlignment = .left
                                    }
                                }
                                $0.multivaluedRowToInsertAt = {
                                    index in
                                    return NameRow() {
                                        $0.placeholder = "Add Participant"
                                    }
                                }
                                if let nameList = eventData["participant"] as? [String]
                                {
                                    for tag in nameList {
                                        $0 <<< NameRow() {
                                            $0.value = tag
                                        }
                                    }
                                }
                                
        }
        
        URLRow("URL") {
            $0.placeholder = "URL"
            }
            
            <<< TextAreaRow("notes") {
                $0.placeholder = "Notes"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 50)

        }
        
    }
    
    @objc func cancelTapped(_ barButtonItem: UIBarButtonItem) {
        (navigationController as? NativeEventNavigationController)?.onDismissCallback?(self)
    }
    
    enum RepeatInterval : String, CaseIterable, CustomStringConvertible {
        case Never = "Never"
        case Every_Day = "Every Day"
        case Every_Week = "Every Week"
        case Every_2_Weeks = "Every 2 Weeks"
        case Every_Month = "Every Month"
        case Every_Year = "Every Year"
        
        var description : String { return rawValue }
    }
    
    enum EventAlert : String, CaseIterable, CustomStringConvertible {
        case Never = "None"
        case At_time_of_event = "At time of event"
        case Five_Minutes = "5 minutes before"
        case FifTeen_Minutes = "15 minutes before"
        case Half_Hour = "30 minutes before"
        case One_Hour = "1 hour before"
        case Two_Hour = "2 hours before"
        case One_Day = "1 day before"
        case Two_Days = "2 days before"
        
        var description : String { return rawValue }
    }
    
    enum EventState : CaseIterable {
        case busy
        case free
    }
}
