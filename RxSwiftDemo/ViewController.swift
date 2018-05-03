//
//  ViewController.swift
//  RxSwiftDemo
//
//  Created by yh on 2018/4/25.
//  Copyright © 2018年 YH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa



class ViewController: UIViewController {

    var tableView: UITableView!

    let disposeBag = DisposeBag()
    let data = ["subject及常用方法","绑定UI属性","Rx创建TableView","自定义可绑定属性","Traits","特征序列2：Driver","特征序列3：ControlProperty、 ControlEvent","双向绑定"]
    let vcs = ["SubjectsViewController","RxUIViewController","RxTableViewController","RxUIViewController","TraitsViewController","DriverViewController","ControlPropertyViewController","TwoWayBindVC"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
                
        tableView = UITableView(frame: view.bounds, style: UITableViewStyle.plain)
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        Observable.just(data).bind(to: tableView.rx.items(cellIdentifier: "cell")) {
            index, title, cell in
            cell.textLabel?.text = "\(index+1). \(title)"
        }.disposed(by: disposeBag)
    
        
        tableView.rx.itemSelected.subscribe(onNext:{index in
            let vc = (NSClassFromString("RxSwiftDemo." + self.vcs[index.row]) as! UIViewController.Type).init()
            self.navigationController?.pushViewController(vc , animated: true)
        }).disposed(by: disposeBag)
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
        self.present(RxTableViewController(), animated: true, completion: nil)
//        self.present(SubjectsViewController(), animated: true, completion: nil)
    }
    
}

