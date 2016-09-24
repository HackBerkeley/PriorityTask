//
//  ListViewController.swift
//  PriorityTask
//
//  Created by Luke Brody on 9/23/16.
//  Copyright © 2016 Luke Brody. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        updateNoTasksLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let tasks = TaskList()

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //There is only one section of tasks
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.orderedTasks.count //Let the table view know how many tasks there are
    }
    
    private func loadTaskViewController() -> (UINavigationController, TaskViewController) {
        let nav = storyboard!.instantiateViewController(withIdentifier: "TaskViewController") as! UINavigationController
        let task = nav.viewControllers.first! as! TaskViewController
        return (nav, task)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //this function means the user tapped on the table view cell
        let task = tasks.orderedTasks[indexPath.item]
        let (nav, taskViewController) = loadTaskViewController()
        taskViewController.task = task
        
        taskViewController.callback = {[weak self] (_)->Void in
            //save the tasklist since we just modified one of its members
            self?.tasks.save(url: TaskList.standardStorageURL)
            nav.dismiss(animated: true) {
                guard let tasks = self?.tasks else {return}
                let newIndex = tasks.orderedTasks.index(of: task)!
                let newIndexPath = IndexPath(item: newIndex, section: 0)
                tableView.moveRow(at: indexPath, to: newIndexPath)
                tableView.reloadRows(at: [newIndexPath], with: .fade)
            }
        }
        
        showDetailViewController(nav, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Task", for: indexPath)
        
        // Configure the cell...
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let task = tasks.orderedTasks[indexPath.item]
        cell.textLabel!.text = task.name
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        cell.detailTextLabel!.text = dateFormatter.string(from: task.dueDate)
        
        //set the cell's background color based on the priority
        //60º = yellow = lowest priority
        //0º  = red    = highest priority
        let hue : CGFloat = (1.0 - CGFloat(task.prioirty)) * (60.0 / 360.0)
        cell.backgroundColor = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //get the task at index
            let task = tasks.orderedTasks[indexPath.item]
            //delete it
            tasks.remove(task: task)
            //do the remove animation
            tableView.deleteRows(at: [indexPath], with: .left)
            //save the task list
            tasks.save(url: TaskList.standardStorageURL)
            //update the footer
            updateNoTasksLabel()
        }
    }
    
    @IBOutlet weak var noTasksLabel: UILabel!
    private func updateNoTasksLabel() {
        noTasksLabel.isHidden = tasks.orderedTasks.count > 0
    }

    @IBAction func add(_ sender: AnyObject) {
        //make a new taskviewcontroller
        let (nav, taskViewController) = loadTaskViewController()
        taskViewController.callback = {[weak self] (task)->Void in
            guard let t = task, let tasks = self?.tasks, let tableView = self?.tableView else {
                nav.dismiss(animated: true)
                return
            }
            tasks.add(task: t)
            //save the task list since we just added something to it
            tasks.save(url: TaskList.standardStorageURL)
            
            //get the index of the task, and do an insert animation
            let i = tasks.orderedTasks.index(of: t)!
            self?.updateNoTasksLabel()
            nav.dismiss(animated: true) {
                tableView.insertRows(at: [IndexPath(item: i, section: 0)], with: .right)
            }
        }
        showDetailViewController(nav, sender: nil)
    }
}
