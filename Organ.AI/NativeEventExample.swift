//
//  NativeEventExample.swift
//  Example
//
//  Created by Mathias Claassen on 3/15/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Eureka

class NativeEventNavigationController: UINavigationController, RowControllerType {
    var onDismissCallback : ((UIViewController) -> ())?
}

class NativeEventFormViewController : FormViewController {
    
    var eventData : [String: Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeForm()

        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(NativeEventFormViewController.cancelTapped(_:))
    }

    private func initializeForm() {
        
        print(eventData)

        form +++

            TextRow("Title").cellSetup { cell, row in
                cell.textField.placeholder = row.tag
                cell.textField.text = self.eventData["title"] as? String
                row.title = self.eventData["title"] as? String
                if (self.eventData["title"] as! String).count != 0
                {
                    cell.textField.placeholder = ""
                 //   cell.textField.text = "Lacsd"
                    row.title = self.eventData["title"] as? String
             //       cell.textField.text = self.eventData["title"] as! String
                }
            }

            <<< TextRow("Location").cellSetup {
                $1.cell.textField.placeholder = $0.row.tag
        //        $1.cell.textField.text = self.eventData["location"] as? String
                
                $0.row.title = self.eventData["location"] as? String
                
                if (self.eventData["location"] as! String).count != 0
                {
                $1.cell.textField.placeholder = ""
                    $1.cell.textField.text = self.eventData["location"] as! String
                 //   cell.textField.text = self.eventData["location"] as! String
                }
            }

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
                $0.value = eventData["start"] as? Date
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
                            cell.datePicker.setDate((self!.eventData["start"] as? Date)!, animated: true)
                            cell.datePicker.date = (self!.eventData["start"] as? Date)!
                        }
                        else {
                            cell.datePicker.datePickerMode = .dateAndTime
                            cell.datePicker.setDate((self!.eventData["start"] as? Date)!, animated: true)
                            cell.datePicker.date = (self!.eventData["start"] as? Date)!
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
                $0.value = eventData["end"] as? Date
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
                            cell.datePicker.setDate((self!.eventData["end"] as? Date)!, animated: true)
                            cell.datePicker.date = (self!.eventData["end"] as? Date)!
                        }
                        else {
                            cell.datePicker.datePickerMode = .dateAndTime
                            cell.datePicker.setDate((self!.eventData["end"] as? Date)!, animated: true)
                            cell.datePicker.date = (self!.eventData["end"] as? Date)!
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

            URLRow("URL") {
                $0.placeholder = "URL"
            }

            <<< TextAreaRow("notes") {
                $0.placeholder = "Notes"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 50)
           //     $0.value = "adjsfklj"
                
                if (self.eventData["participant"] as! String).count != 0
                {
                    $0.value = self.eventData["participant"] as! String
             //       $0
              //      $.textField.text = self.eventData["participants"] as! String
                }
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
