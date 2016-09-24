//
//  Task.swift
//  PriorityTask
//
//  Created by Luke Brody on 9/23/16.
//  Copyright © 2016 Luke Brody. All rights reserved.
//

import Foundation

protocol DictionaryConvertibleValue {}

extension String : DictionaryConvertibleValue {}
extension NSNumber : DictionaryConvertibleValue {}
extension Float : DictionaryConvertibleValue {}
extension Double : DictionaryConvertibleValue {}
extension Array where Element:DictionaryConvertibleValue {}
//See https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Protocols.html#//apple_ref/doc/uid/TP40014097-CH25-ID277
extension Dictionary where Value:DictionaryConvertibleValue {}

protocol DictionaryConvertible: DictionaryConvertibleValue {
    var dictionary : [String : DictionaryConvertibleValue] {get}
    init(dictionary : [String : DictionaryConvertibleValue])
}

fileprivate let newTaskDelay : TimeInterval = 3600

class Task : Comparable, DictionaryConvertible {
    let UUID : String
    var name : String
    var dueDate : Date
    var prioirty : Float
    
    //Creates a new task with default values.
    init() {
        UUID = NSUUID().uuidString
        name = ""
        dueDate = Date(timeIntervalSinceNow: newTaskDelay)
        prioirty = 0.5
    }
    
    var weightedPriority : Double {
        return Double(prioirty) * dueDate.timeIntervalSinceNow
    }
    
    public static func ==(lhs: Task, rhs: Task) -> Bool {
        return lhs.UUID == rhs.UUID
    }
    
    public static func <(lhs: Task, rhs: Task) -> Bool {
        return lhs.weightedPriority < rhs.weightedPriority
    }
    
    //Serialize as a dictionary
    var dictionary: [String : DictionaryConvertibleValue] {
        return [
            "UUID": UUID,
            "name": name,
            "dueDate": Date.timeIntervalSinceReferenceDate,
            "priority": prioirty
        ]
    }
    
    required init(dictionary: [String : DictionaryConvertibleValue]) {
        UUID = dictionary["UUID"] as! String
        name = dictionary["name"] as! String
        dueDate = Date(timeIntervalSinceReferenceDate: dictionary["dueDate"] as! TimeInterval)
        prioirty = dictionary["priority"] as! Float
    }
}

class TaskList {
    
    private var tasks : [Task]
    
    var orderedTasks : [Task] {
        return tasks.sorted()
    }
    
    func add(task: Task) {
        tasks.append(task);
    }
    
    func remove(task: Task) {
        guard let i = tasks.index(of: task) else {fatalError()}
        tasks.remove(at: i)
    }
    
    /*
     DANGER:
     This file handling code does not have proper error handling!
     Notice the try! s. If these fail, the app would just crash.
     This is fine in a hackathon, but in real life we should handle errors.
     See: https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/ErrorHandling.html
     */
    
    //See: https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html
    //And: http://stackoverflow.com/questions/6907381/what-is-the-documents-directory-nsdocumentdirectory
    //This is the file where we're going to store our JSON persistence file.
    static let standardStorageURL : URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        return documents.appendingPathComponent("tasks.json")
    }()
    
    func save(url: URL) {
        let dictionaryTasks = tasks.map {task in
            return task.dictionary
        } //Map each task to a dictionary.
        let json = try! JSONSerialization.data(withJSONObject: dictionaryTasks, options: [.prettyPrinted]) //Convert to JSON.
        try! json.write(to: url) //Write to file.
    }
    
    //Precondition: Storage file exists.
    //Load the task list from the speicified URL.
    init(url: URL) {
        let fileContents = try! Data(contentsOf: url) //Read the file data.
        let jsonData = try! JSONSerialization.jsonObject(with: fileContents, options: []) //Run the data through the JSON parser.
        let array = jsonData as! Array<[String : DictionaryConvertibleValue]> //Assume the data is an array, and cast it
        tasks = array.map {dict in Task(dictionary: dict)} //Initialize tasks by mapping each dictionary in the JSON to through Task's initializer.
    }
    
    //Just make a new task list with some tasks without loading anything.
    init(tasks: [Task]) {
        self.tasks = tasks
    }
    
    //Either init from the standard file if it exists, or just make a new blank task list.
    convenience init() {
        if FileManager.default.fileExists(atPath: TaskList.standardStorageURL.path) {
            self.init(url: TaskList.standardStorageURL)
        } else {
            self.init(tasks: [])
        }
    }
    
    
}
