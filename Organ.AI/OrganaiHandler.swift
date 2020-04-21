//
//  OrganaiHandler.swift
//  Organ.AI
//
//  Created by Ben on 2020/4/15.
//  Copyright © 2020 Organ.AI. All rights reserved.
//

import Foundation

struct OrganAIHandler
{
    
    var api_response_handler = ["activity": [""], "person": [""], "duration": 0, "time": ""] as [String : Any]
    
    var query = "Book a meeting with @John"
    
    mutating func queryProcessor(token: String, query: String, completion: @escaping ([String:Any]) -> ())
    {
        let sessionConfig = URLSessionConfiguration.default
        let authValue: String? = "Bearer \(token)"
        sessionConfig.httpAdditionalHeaders = ["Authorization": authValue ?? ""]
        
        var _url = URLComponents()
        _url.scheme = "https"
        _url.host = "organaise.ngrok.io"
        _url.path = "/api/projects/default/logs"
        _url.queryItems = [URLQueryItem(name: "q", value: query)]
        
        if let queryURL = _url.url
        {
            var request = URLRequest(url: queryURL)
            request.httpMethod = "POST"
            let session = URLSession(configuration: sessionConfig)
            
            let sessionTask = session.dataTask(with: request) { (data, response, error) in
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                
                //   print(json)
                var activity = [String]()
                var person = [String]()
                var duration = Int()
                var time = [String: String]()
                var placeholder = [String]()
                
                
                
                if let dict_data = json as? [String: Any] {
                    //  print(dict_data)
                    
                    if let user_input = dict_data["user_input"] as? [String: Any]
                    {
                        //     print(user_input)
                        
                        let seng_msg = user_input["text"] as! String
                        print(seng_msg)
                        
                        //        print(user_input["entities"] as! NSArray)
                        
                        if let entities = user_input["entities"] as? NSArray
                        {
                            //  print(entities)
                            for entity in entities
                            {
                                if let single_entity = entity as? [String: Any]
                                {
                                    //    print(single_entity)
                                    if let entityName = single_entity["entity"] as? String
                                    {
                                        switch entityName {
                                        case "time":
                                            if single_entity["extractor"] as! String == "activityparser"
                                            {
                                                if let time_entity = single_entity["value"] as? [String: String]
                                                {
                                                    time["from"] = time_entity["from"]
                                                    time["to"] = time_entity["to"]
                                                }else
                                                {
                                                    time["time"] = (single_entity["value"] as? String)!
                                                }
                                            }else
                                            {
                                                time["time"] = (single_entity["value"] as? String)!
                                            }
                                        case "activity":
                                            if single_entity["extractor"] as! String == "activityparser"
                                            {
                                                activity.append(single_entity["value"] as! String)
                                            }else
                                            {
                                                if single_entity["extractor"] as! String == "CRFEntityExtractor"
                                                {
                                                    if single_entity["confidence"] as! Double > 0.8
                                                    {
                                                        activity.append(single_entity["value"] as! String)
                                                    }
                                                }
                                            }
                                            
                                        case "PERSON":
                                            if single_entity["extractor"] as! String == "activityparser"
                                            {
                                                person = single_entity["value"] as! [String]
                                            }else
                                            {
                                                if single_entity["confidence"] as! Double > 0.8
                                                {
                                                    person.append(single_entity["value"] as! String)
                                                }
                                            }
                                        case "duration":
                                            if single_entity["extractor"] as! String == "activityparser"
                                            {
                                                duration = single_entity["value"] as! Int
                                            }else
                                            {
                                                if single_entity["confidence"] as! Double > 0.8
                                                {
                                                    duration = single_entity["value"] as! Int
                                                }
                                            }
                                        case "placeholder":
                                            if single_entity["extractor"] as! String == "RegexEntityExtractor"
                                            {
                                                placeholder.append(single_entity["value"] as! String)
                                            }else
                                            {
                                                if single_entity["extractor"] as! String == "CRFEntityExtractor"
                                                {
                                                    if single_entity["confidence"] as! Double > 0.5
                                                    {
                                                        placeholder.append(single_entity["value"] as! String)
                                                    }
                                                }
                                            }
                                        default:
                                            print("error")
                                        }
                                    }
                                    
                                }
                            }
                            print("\n ########## VALUE ######### \n")
                            print(time)
                            print(activity)
                            print(person)
                            print(duration)
                            print(placeholder)
                            if time.count == 0
                            {
                                print("Ask for Time")
                            }
                            if activity.count == 0
                            {
                                print("Ask for Title")
                            }
                            if person.count == 0
                            {
                                print("Ask for Person")
                            }
                            if duration == 0
                            {
                                print("Ask for Duration")
                            }
                            completion(["time":time, "activity": activity, "person": person, "duration": duration, "placeholder": placeholder])
                        }
                    }
                }
            }
            sessionTask.resume()
        }
    }
    
    func getToken (completion: @escaping (String) -> ())
    {
        guard let url = URL(string: "http://organaise.ngrok.io/api/auth"),
            let payload = "{\"username\": \"me\", \"password\": \"organaise2019\"}".data(using: .utf8) else
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
            guard let data = data else { print("Empty data"); return }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let dict_token = json as? [String: String] {
                let token = dict_token["access_token"]!
                completion(token)
            }
        }.resume()
    }
    
}
