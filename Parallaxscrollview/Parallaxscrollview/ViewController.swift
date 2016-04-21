//
//  ViewController.swift
//  Parallaxscrollview
//
//  Created by wzh on 16/4/20.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let headerView = ParallaxScrollView.creatParallaxScrollViewWithImage(UIImage(named: "imageDemo.jpg")!, forSize: CGSize(width: tableView.bounds.width, height: 300),referView: tableView)
        tableView.tableHeaderView = headerView
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        (tableView.tableHeaderView as! ParallaxScrollView).refreshBlurViewForNewImage()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 200
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        }
        cell!.textLabel?.text = "我是第\(indexPath.item)个"
        return cell!
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

