//
//  MasterViewController.swift
//  GitAmend
//
//  Created by Timothy Andrew on 15/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    let refresh = UIRefreshControl()
    var detailViewController: DetailViewController? = nil
    var repo: GithubAPIRepository?
    var objects = [GithubAPIFile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = refresh
        refresh.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewFile))
        
        refresh.beginRefreshing()
        refreshTable()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let file = objects[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.maybeFile = file
                controller.maybeRepo = repo
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let object = objects[indexPath.row]
        cell.textLabel!.text = object.prettyFilename()
        return cell
    }
    
    // MARK: - Custom
    
    @objc
    func addNewFile(_ sender: UIBarButtonItem) {
        let alert = AlertUtil.sheet(title: "Add a File", actions: [
            ("Learning Note", { _ in print("Learning") }),
            ("Journal Entry", { _ in print("LearningX") })
        ])
        alert.popoverPresentationController?.barButtonItem = sender
        self.present(alert, animated: true)
    }
    
    @objc
    func refreshTable() {
        print("Attempting to fetch repo")
        GithubAPIRepository.fetch(repo: "timothyandrew/kb") { maybeRepo in
            guard let repo = maybeRepo else {
                // TODO: UI alert
                print("Failed to fetch repo")
                return
            }

            print("Fetched repo: \(repo.path)")
            let files = repo.tree.files()
            self.objects.append(contentsOf: files)
            self.tableView.reloadData()
            self.repo = repo
            
            self.refresh.endRefreshing()
        }
    }
}

