//
//  ViewController.swift
//  TCParallaxExample
//
//  Created by 谈超 on 2017/5/2.
//  Copyright © 2017年 谈超. All rights reserved.
//

import UIKit
import TCParallax
class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.delegate = self
//        tableView.dataSource = self
//        let headerView = ParallaxScrollView.creatParallaxScrollViewWithImage(image: UIImage(named: "imageDemo.jpg")!, forSize: CGSize(width: tableView.bounds.width, height: 300),referView: tableView)
//        tableView.tableHeaderView = headerView
    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        (tableView.tableHeaderView as! ParallaxScrollView).refreshBlurViewForNewImage()
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 200
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 50
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
//        if (cell == nil) {
//            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
//        }
//        cell!.textLabel?.text = "我是第\(indexPath.item)个"
//        return cell!
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

