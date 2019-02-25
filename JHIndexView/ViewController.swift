//
//  ViewController.swift
//  JHIndexView
//
//  Created by youdone-dev on 2019/2/25.
//  Copyright © 2019 com.zjh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, JHIndexViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var sectionTitles: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "JHTableViewCell")
        
        let indexView = JHIndexView(frame: CGRect(x: view.frame.width - 20, y: 0, width: 20, height: view.frame.height))
        indexView.dataSource = sectionTitles
        indexView.rowHeight = 20
        indexView.delegate = self
        view.addSubview(indexView)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JHTableViewCell")
        cell?.textLabel?.text = "\(indexPath.row)"
        return cell!
    }
    
    //MARK: JHIndexViewDelegate
    func indexView(_ indexView: JHIndexView, selectedForIndexTitle title: String, atIndex index: Int) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
    }
}

