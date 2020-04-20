//
//  AddEventViewController.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 11/6/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit
import Former
import EventKit

final class AddEventViewController: FormViewController {
    
    // MARK: Public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: Private
    
    private enum Repeat {
        case Never, Daily, Weekly, Monthly, Yearly
        func title() -> String {
            switch self {
            case .Never: return "Never"
            case .Daily: return "Daily"
            case .Weekly: return "Weekly"
            case .Monthly: return "Monthly"
            case .Yearly: return "Yearly"
            }
        }
        static func values() -> [Repeat] {
            return [Daily, Weekly, Monthly, Yearly]
        }
    }
    
    private enum Alert {
        case None, AtTime, Five, Thirty, Hour, Day, Week
        func title() -> String {
            switch self {
            case .None: return "None"
            case .AtTime: return "At time of event"
            case .Five: return "5 minutes before"
            case .Thirty: return "30 minutes before"
            case .Hour: return "1 hour before"
            case .Day: return "1 day before"
            case .Week: return "1 week before"
            }
        }
        static func values() -> [Alert] {
            return [AtTime, Five, Thirty, Hour, Day, Week]
        }
    }
    
    var eventData : [String: Any] = [:]
    
    
    func configure() {
        title = "Add Event"
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 30
        tableView.contentOffset.y = -10
        
        // Create RowFomers
        let titleRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFont(ofSize: 15)
            }.configure {
                
                $0.text = eventData["title"] as? String
                
                $0.placeholder = "Event title"
        }
        
        let locationRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFont(ofSize: 15)
            }.configure {
                $0.text = eventData["location"] as? String
                $0.placeholder = "Location"
        }
/*        let startRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Start"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .formerSubColor()
            $0.displayLabel.font = .systemFont(ofSize: 15)
            }.inlineCellSetup {
                $0.datePicker.datePickerMode = .dateAndTime
            }.displayTextFromDate(String.mediumDateShortTime)*/
        
        let startRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Start"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            
            $0.displayLabel.textColor = .formerSubColor()
            $0.displayLabel.font = .systemFont(ofSize: 15)
         //   $0.displayLabel.text = "2020-04-20T04:00:00.000-07:00"
        //    $0.displayLabel.text =
        }.inlineCellSetup { (datepicker) in
            datepicker.datePicker.setDate(Date().addingTimeInterval(60*60*60*24), animated: true)
        //    datepicker.datePicker.setDate(DateFormatHandler().stringToDate(string_date: "2020-04-20T04:00:00.000-07:00"), animated: true)
            datepicker.datePicker.date = Date().addingTimeInterval(60*60*60*24)
        }
        /*
         
         .inlineCellSetup {
                  
             //     $0.datePicker.
                  
                //  $0.datePicker.setDate(<#T##date: Date##Date#>, animated: <#T##Bool#>)
                 // $0.datePicker.minimumDate = DateFormatHandler().stringToDate(string_date: "2020-04-20T04:00:00.000-07:00")
                  $0.datePicker.date = DateFormatHandler().stringToDate(string_date: "2020-04-20T04:00:00.000-07:00")
                  $0.datePicker.setDate(DateFormatHandler().stringToDate(string_date: "2020-04-20T04:00:00.000-07:00"), animated: true)
              }.displayTextFromDate(String.mediumDateShortTime)
         // startRow.date = DateFormatHandler().stringToDate(string_date: "2020-04-20T04:00:00.000-07:00")
         
         */
        
        let endRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "End"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .formerSubColor()
            $0.displayLabel.font = .systemFont(ofSize: 15)
            }.inlineCellSetup {
                $0.datePicker.datePickerMode = .dateAndTime
        }.displayTextFromDate(String.mediumDateShortTime)
        let allDayRow = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "All-day"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.switchButton.onTintColor = .formerSubColor()
            }.onSwitchChanged { on in
                startRow.update {
                    $0.displayTextFromDate(
                        on ? String.mediumDateNoTime : String.mediumDateShortTime
                    )
                }
                startRow.inlineCellUpdate {
                    $0.datePicker.datePickerMode = on ? .date : .dateAndTime
                }
                endRow.update {
                    $0.displayTextFromDate(
                        on ? String.mediumDateNoTime : String.mediumDateShortTime
                    )
                }
                endRow.inlineCellUpdate {
                    $0.datePicker.datePickerMode = on ? .date : .dateAndTime
                }
        }
        let repeatRow = InlinePickerRowFormer<FormInlinePickerCell, Repeat>() {
            $0.titleLabel.text = "Repeat"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .formerSubColor()
          $0.displayLabel.font = .systemFont(ofSize: 15)
            }.configure {
                let never = Repeat.Never
                $0.pickerItems.append(
                    InlinePickerItem(title: never.title(),
                                     displayTitle: NSAttributedString(string: never.title(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]),
                        value: never)
                )
                $0.pickerItems += Repeat.values().map {
                    InlinePickerItem(title: $0.title(), value: $0)
                }
        }
        let alertRow = InlinePickerRowFormer<FormInlinePickerCell, Alert>() {
            $0.titleLabel.text = "Alert"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .formerSubColor()
            $0.displayLabel.font = .systemFont(ofSize: 15)
            }.configure {
                let none = Alert.None
                $0.pickerItems.append(
                    InlinePickerItem(title: none.title(),
                                     displayTitle: NSAttributedString(string: none.title(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]),
                        value: none)
                )
                $0.pickerItems += Alert.values().map {
                    InlinePickerItem(title: $0.title(), value: $0)
                }
        }
        let urlRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .systemFont(ofSize: 15)
            $0.textField.keyboardType = .alphabet
            }.configure {
                $0.placeholder = "URL"
        }
        let noteRow = TextViewRowFormer<FormTextViewCell>() {
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "Note"
                $0.rowHeight = 150
        }
        
        // Create Headers
        
        let createHeader: (() -> ViewFormer) = {
            return CustomViewFormer<FormHeaderFooterView>()
                .configure {
                    $0.viewHeight = 20
            }
        }
        
        // Create SectionFormers
        
        let titleSection = SectionFormer(rowFormer: titleRow, locationRow)
            .set(headerViewFormer: createHeader())
        let dateSection = SectionFormer(rowFormer: allDayRow, startRow, endRow)
            .set(headerViewFormer: createHeader())
        let repeatSection = SectionFormer(rowFormer: repeatRow, alertRow)
            .set(headerViewFormer: createHeader())
        let noteSection = SectionFormer(rowFormer: urlRow, noteRow)
            .set(headerViewFormer: createHeader())
        
        former.append(sectionFormer: titleSection, dateSection, repeatSection, noteSection)
        
        titleRow.onReturn { (string) in
            self.eventData["Title"] = string
        }
        
        locationRow.onReturn { (string) in
            self.eventData["location"] = string
        }
        
        startRow.onDateChanged { (date) in
            self.eventData["Start"] = date
        }
        
        endRow.onDateChanged { (date) in
            self.eventData["End"] = date
        }
        
        
        
    }
    
    @IBAction func createEventTapped(_ sender: Any) {
        
        //former.
        

        
        let newEvent = EKEvent(eventStore: EventsCalendarManager().eventStore)
        newEvent.title = eventData["title"] as? String
        newEvent.startDate = eventData["start"] as? Date
        newEvent.endDate = eventData["end"] as? Date
        newEvent.location = eventData["location"] as? String
        
        EventsCalendarManager().presentEventCalendarDetailModal(event: newEvent)
        /*
        EventsCalendarManager().addEventToCalendar(event: newEvent) { (error) in
            print(error)
        }
        */
    }
}
