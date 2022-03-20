//
//  ListViewController.swift
//  TravelBook_CoreData
//
//  Created by Macbook on 20.03.22.
//

import UIKit
import CoreData

class ListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var titles = [String]()
    var idies = [UUID]()
    var chosenTitle = ""
    var chosenTitleID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    private func config() {
        configTableView()
        getData()
        addBarButtonItem()
    }
    
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func addBarButtonItem() {
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonPressed))
    }
    
    @objc private func addButtonPressed() {
        performSegue(withIdentifier: "2Map", sender: nil)
    }
    
    private func getData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                self.titles.removeAll(keepingCapacity: false)
                self.idies.removeAll(keepingCapacity: false)
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String {
                        self.titles.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idies.append(id)
                    }
                    self.tableView.reloadData()
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "2Map" {
            let destinationVC = segue.destination as! ViewController
            destinationVC.selectedTitle = chosenTitle
            destinationVC.selectedTitleID = chosenTitleID
        }
    }

}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = titles[indexPath.row]
        chosenTitleID = idies[indexPath.row]
        performSegue(withIdentifier: "2Map", sender: nil)
    }
}
