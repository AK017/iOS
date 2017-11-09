//
//  LecturesTableViewController.swift
//  TUM Campus App
//
//  Created by Mathias Quintero on 12/10/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Sweeft
import UIKit

private func mapped(lectures: [Lecture]) -> [(String, [Lecture])] {
    let ordered = lectures.map { $0.semester }
    let semesters = Set(ordered).sorted(ascending: { ordered.index(of: $0) ?? ordered.count })
    return semesters.map { semester in
        return (semester, lectures.filter { $0.semester == semester })
    }
}

class LecturesTableViewController: UITableViewController, DetailViewDelegate, DetailView {
    
    var lectures = [(String,[Lecture])]()
    
    weak var delegate: DetailViewDelegate?
    
    var currentLecture: DataElement?
    
    func dataManager() -> TumDataManager? {
        return delegate?.dataManager()
    }
    
    func fetch() {
        let promise = delegate?.dataManager()?.lecturesManager.fetch()
        promise?.map(completionQueue: .main) { (lectures: [Lecture]) -> [(String, [Lecture])] in
            return mapped(lectures: lectures)
        }.onSuccess(in: .main) { lectures in
            self.lectures = lectures
            self.tableView.reloadData()
        }
    }

}

extension LecturesTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetch()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mvc = segue.destination as? LectureDetailsTableViewController {
            mvc.lecture = currentLecture
            mvc.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
            self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        }
    }
    
}

extension LecturesTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return lectures.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lectures[section].1.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return lectures[section].0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = lectures[indexPath.section].1[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.getCellIdentifier()) as? CardTableViewCell ?? CardTableViewCell()
        if let cell = cell as? SingleDataElementPresentable {
            cell.setElement(item)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.contentView.backgroundColor = Constants.tumBlue
            header.textLabel?.textColor = UIColor.white
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        currentLecture = lectures[indexPath.section].1[indexPath.row]
        return indexPath
    }
    
}
