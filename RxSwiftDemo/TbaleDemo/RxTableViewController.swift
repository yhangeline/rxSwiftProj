//
//  RxTableViewController.swift
//  RxSwiftDemo
//
//  Created by yh on 2018/4/26.
//  Copyright © 2018年 YH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxTableViewController: UIViewController {

    var tableView: UITableView!
    //歌曲列表数据源
    let musicListViewModel = MusicListViewModel()
    
    //负责对象销毁
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTable()
        
    }
    
    func createTable() {
        tableView = UITableView(frame: view.bounds, style: UITableViewStyle.plain)
//        tableView.delegate = self
//        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "musicCell")
        view.addSubview(tableView)
        
        
        /*
         DisposeBag：作用是 Rx 在视图控制器或者其持有者将要销毁的时候，自动释法掉绑定在它上面的资源。它是通过类似“订阅处置机制”方式实现（类似于 NotificationCenter 的 removeObserver）。
         rx.items(cellIdentifier:）:这是 Rx 基于 cellForRowAt 数据源方法的一个封装。传统方式中我们还要有个 numberOfRowsInSection 方法，使用 Rx 后就不再需要了（Rx 已经帮我们完成了相关工作）。
         rx.modelSelected： 这是 Rx 基于 UITableView 委托回调方法 didSelectRowAt 的一个封装。
         */
        
        musicListViewModel.data.debug("调试1").bind(to: tableView.rx.items(cellIdentifier: "musicCell")) {
            _, music, cell in
            cell.textLabel?.text = music.name
            cell.detailTextLabel?.text = music.singer
        }.disposed(by: disposeBag)


        //tableView点击响应
        tableView.rx.modelSelected(Music.self).subscribe(onNext: { music in
            print("你选中的歌曲信息【\(music)】")
        }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext:{index in
            print(index)
        }).disposed(by: disposeBag)
    }
    
    
    
}


/***********以下是传统写法*************/

//extension RxTableViewController: UITableViewDataSource {
//    //返回单元格数量
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return musicListViewModel.data.count
//    }
//
//    //返回对应的单元格
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
//        -> UITableViewCell {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell")!
//            let music = musicListViewModel.data[indexPath.row]
//            cell.textLabel?.text = music.name
//            cell.detailTextLabel?.text = music.singer
//            return cell
//    }
//}
//
//extension RxTableViewController: UITableViewDelegate {
//    //单元格点击
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("你选中的歌曲信息【\(musicListViewModel.data[indexPath.row])】")
//    }
//}
