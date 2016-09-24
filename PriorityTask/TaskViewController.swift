//
//  TaskViewController.swift
//  PriorityTask
//
//  Created by Luke Brody on 9/23/16.
//  Copyright © 2016 Luke Brody. All rights reserved.
//

import UIKit

class TaskViewController: UITableViewController, UITextFieldDelegate {

    var task : Task! //If there is no task, we are making a new one.
    var callback : ((Task?) -> Void)! //If there is a task argument, the caller should add it
    var createNewTask = false
    
    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var prioritySlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if there's no task on view load, make a task
        if task == nil {
            task = Task()
            createNewTask = true
        } else {
            //set our title to the task's original title
            navigationItem.title = task.name
        }
        
        //set each field to the task's values
        taskNameField.text = task.name
        dueDatePicker.date = task.dueDate
        prioritySlider.value = task.prioirty
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        //do cancel
        //don't change any of the task properties
        //call back with nil, meaning no new task was added
        callback(nil)
    }
    
    @IBAction func done(_ sender: AnyObject) {
        //done! set the the Task's properties to those presented in the UI
        task.name = taskNameField.text ?? ""
        task.dueDate = dueDatePicker.date
        task.prioirty = prioritySlider.value
        //call back with the task if this is the new task, otherwise just call back nil since we modified a task
        callback(createNewTask ? task : nil)
    }
    
    //this makes sure the keyboard hides when we hit done on the name field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
