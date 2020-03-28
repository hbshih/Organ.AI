//
//  EventsCalendarManager.swift
//  Organ.AI
//
//  Created by Ben on 2020/3/27.
//  Copyright © 2020 Organ.AI. All rights reserved.
//
import UIKit
import EventKit
import EventKitUI

enum CustomError: Error {
    case calendarAccessDeniedOrRestricted
    case eventNotAddedToCalendar
    case eventAlreadyExistsInCalendar
}

typealias EventsCalendarManagerResponse = (_ result: Result<Bool, CustomError >) -> Void

class EventsCalendarManager: NSObject {
    
    var eventStore: EKEventStore!
    
    override init() {
        eventStore = EKEventStore()
    }
    
    /* Get iOS calendar access */
    
    // Request access to the Calendar
    func requestAccess(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestAccess(to: EKEntityType.event) { (accessGranted, error) in
            completion(accessGranted, error)
        }
    }
    
    // Get Calendar auth status
    func getAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
    // check calendar auto
    func checkCalendarAuthorization(completion: @escaping() -> ())
    {
        print("try")
        let authStatus = getAuthorizationStatus()
        switch authStatus {
        case .notDetermined:
            //Auth is not determined
            //We should request access to the calendar
            requestAccess { (accessGranted, error) in
                if accessGranted {
                    print("Granted")
                    completion()
                } else {
                    // Auth denied, we should display a popup
                    self.requestAccess { (bool, error) in
                        if bool
                        {
                            print("granted")
                            completion()
                        }
                    }
                }
            }
        case .denied, .restricted:
            // Auth denied or restricted, we should display a popup
            requestAccess { (accessGranted, error) in
                if accessGranted {
                    print("Granted")
                    completion()
                } else {
                    // Auth denied, we should display a popup
                    self.requestAccess { (bool, error) in
                        if bool
                        {
                            print("granted")
                            completion()
                        }
                    }
                }
            }
        case .authorized:
            print("granted")
            completion()
        @unknown default:
            print("null")
        }
        
    }
    
    // Try to add an event to the calendar if authorized
    func addEventToCalendar(event: EKEvent, completion : @escaping EventsCalendarManagerResponse) {
        let authStatus = getAuthorizationStatus()
        switch authStatus {
        case .authorized:
            self.addEvent(event: event, completion: { (result) in
                switch result {
                case .success:
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        case .notDetermined:
            //Auth is not determined
            //We should request access to the calendar
            requestAccess { (accessGranted, error) in
                if accessGranted {
                    self.addEvent(event: event, completion: { (result) in
                        switch result {
                        case .success:
                            completion(.success(true))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    })
                } else {
                    // Auth denied, we should display a popup
                    completion(.failure(.calendarAccessDeniedOrRestricted))
                }
            }
        case .denied, .restricted:
            // Auth denied or restricted, we should display a popup
            completion(.failure(.calendarAccessDeniedOrRestricted))
        }
    }
    
    // Generate an event which will be then added to the calendar
    private func generateEvent(event: EKEvent) -> EKEvent {
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.calendar = eventStore.defaultCalendarForNewEvents
        newEvent.title = event.title
        newEvent.startDate = event.startDate
        newEvent.endDate = event.endDate
        
        // Set default alarm minutes before event
        
        let alarm1hour = EKAlarm(relativeOffset: -3600) //1 hour
        let alarm1day = EKAlarm(relativeOffset: -86400) //1 day
        
        let alarm = alarm1day
        newEvent.addAlarm(alarm)
        return newEvent
    }
    
    // Try to save an event to the calendar
    private func addEvent(event: EKEvent, completion : @escaping EventsCalendarManagerResponse) {
        let eventToAdd = generateEvent(event: event)
        if !eventAlreadyExists(event: eventToAdd) {
            do {
                try eventStore.save(eventToAdd, span: .thisEvent)
            } catch {
                // Error while trying to create event in calendar
                completion(.failure(.eventNotAddedToCalendar))
            }
            completion(.success(true))
        } else {
            completion(.failure(.eventAlreadyExistsInCalendar))
        }
        
    }
    
    // Check if the event was already added to the calendar
    
    private func eventAlreadyExists(event eventToAdd: EKEvent) -> Bool {
        let predicate = eventStore.predicateForEvents(withStart: eventToAdd.startDate, end: eventToAdd.endDate, calendars: nil)
        let existingEvents = eventStore.events(matching: predicate)
        
        let eventAlreadyExists = existingEvents.contains { (event) -> Bool in
            return eventToAdd.title == event.title && event.startDate == eventToAdd.startDate && event.endDate == eventToAdd.endDate
        }
        return eventAlreadyExists
    }
    
    // Show event kit ui to add event to calendar
    
    func presentCalendarModalToAddEvent(event: EKEvent, completion : @escaping EventsCalendarManagerResponse) {
        let authStatus = getAuthorizationStatus()
        switch authStatus {
        case .authorized:
            presentEventCalendarDetailModal(event: event)
            completion(.success(true))
        case .notDetermined:
            //Auth is not determined
            //We should request access to the calendar
            requestAccess { (accessGranted, error) in
                if accessGranted {
                    self.presentEventCalendarDetailModal(event: event)
                    completion(.success(true))
                } else {
                    // Auth denied, we should display a popup
                    completion(.failure(.calendarAccessDeniedOrRestricted))
                }
            }
        case .denied, .restricted:
            // Auth denied or restricted, we should display a popup
            completion(.failure(.calendarAccessDeniedOrRestricted))
        }
    }
    
    // Present edit event calendar modal
    
    func presentEventCalendarDetailModal(event: EKEvent) {
        let event = generateEvent(event: event)
        let eventModalVC = EKEventEditViewController()
        eventModalVC.event = event
        eventModalVC.eventStore = eventStore
        eventModalVC.editViewDelegate = self
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        if let rootVC = keyWindow?.rootViewController {
            rootVC.present(eventModalVC, animated: true, completion: nil)
        }
    }
    
    func loadCalendars() -> [String]
    {
        var titleArray = [""]
        titleArray.removeAll()
        
        //eventStore.requestAccess(to: .event){ granted, error in
        let calendars = self.eventStore.calendars(for: .event)
        for calendar in calendars
        {
            titleArray.append(calendar.title)
            // titleArray.append(calendar.title)
            print(titleArray)
        }
        //     }
        
        
        return titleArray
        /*
         var titles : [String] = []
         var startDates : [Date] = []
         var endDates : [Date] = []
         
         //    let eventStore = EKEventStore()
         let calendars = eventStore.calendars(for: .event)
         
         for calendar in calendars {
         
         print(calendar.title)
         
         /*     if calendar.title == "Appointment" {
         
         let oneMonthAgo = Date(timeIntervalSinceNow: -30*24*3600)
         let oneMonthAfter = Date(timeIntervalSinceNow: +30*24*3600)
         
         let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo, end: oneMonthAfter, calendars: [calendar])
         var events = eventStore.events(matching: predicate)
         
         for event in events {
         
         print(event)
         
         titles.append(event.title)
         startDates.append(event.startDate)
         endDates.append(event.endDate)
         }
         }*/
         
         }
         print(titles)*/
    }
    
    var tableViewData = [cellData]()
    func loadEvents(selectedCalendars: [String]) -> [cellData]
    {
        var eventDetails: [String: Any]
        
        //    let eventStore = EKEventStore()
        let calendars = eventStore.calendars(for: .event)
        for calendar in calendars {
            
            if selectedCalendars.contains(calendar.title) {
                
                let oneMonthAgo = Date(timeIntervalSinceNow: -30*24*12*3600)
                let oneMonthAfter = Date(timeIntervalSinceNow: +30*24*12*3600)
                
                let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo, end: oneMonthAfter, calendars: [calendar])
                var events = eventStore.events(matching: predicate)
                
                print("calendar color")
                print(calendar.cgColor)
                
                for event in events {
                    
                    
                    var format = ["Date": DateFormatHandler().dateToFormattedString(date: event.startDate),
                                  "StartingTime": DateFormatHandler().dateToFormattedTimeString(date: event.startDate),
                                  "EndingTime": DateFormatHandler().dateToFormattedTimeString(date: event.endDate),
                                  "Title": event.title,
                                  "Detail": event.notes,
                                  "Color": UIColor(cgColor: event.calendar.cgColor),
                                  "Location": event.location,
                                  "Invitees": event.attendees] as [String : Any]
                    
                    tableViewData.append(cellData(opened: false, title: DateFormatHandler().dateToFormattedString(date: event.startDate), sectionData: format))
                }
            }
            
        }
        print(tableViewData)
        return tableViewData
    }
    
    
}

// EKEventEditViewDelegate
extension EventsCalendarManager: EKEventEditViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
}

struct e
{
    var opened = Bool()
    var title = String()
    var sectionData = [String: Any]()
}

