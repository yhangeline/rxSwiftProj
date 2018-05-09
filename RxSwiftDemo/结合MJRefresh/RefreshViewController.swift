//
//  RefreshViewController.swift
//  RxSwiftDemo
//
//  Created by yh on 2018/5/9.
//  Copyright © 2018年 YH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewModel {
    
    //表格数据序列
//    let tableData:Driver<[String]>
    let tableData = BehaviorRelay<[String]>(value: [])
    
    //停止刷新状态序列
//    let endHeaderRefreshing: Driver<Bool>
    
    //停止上拉加载刷新状态序列
    let endFooterRefreshing: Driver<Bool>
    
    //ViewModel初始化（根据输入实现对应的输出）
//    init(headerRefresh: Driver<Void>) {
//
//        //网络请求服务
//        let networkService = NetworkService()
//
//        //生成查询结果序列
//        self.tableData = headerRefresh
//            .startWith(()) //初始化完毕时会自动加载一次数据
//            .flatMapLatest{ _ in networkService.getRandomResult() }
//
//        //生成停止刷新状态序列
//        self.endHeaderRefreshing = self.tableData.map{ _ in true }
//    }
    
    //ViewModel初始化（根据输入实现对应的输出）
    init(footerRefresh: Driver<Void>,
         dependency: (
        disposeBag:DisposeBag,
        networkService: NetworkService )) {
        
        //上拉结果序列
        let footerRefreshData = footerRefresh
            .startWith(()) //初始化完毕时会自动加载一次数据
            .flatMapLatest{ return dependency.networkService.getRandomResult() }
        
        //生成停止上拉加载刷新状态序列
        self.endFooterRefreshing = footerRefreshData.map{ _ in true }
        
        //上拉加载时，将查询到的结果拼接到原数据底部
        footerRefreshData.drive(onNext: { items in
            self.tableData.accept(self.tableData.value + items )
        }).disposed(by: dependency.disposeBag)
    }
}

//网络请求服务
class NetworkService {
    
    //获取随机数据
    func getRandomResult() -> Driver<[String]> {
        print("正在请求数据......")
        let items = (0 ..< 15).map {_ in
            "随机数据\(Int(arc4random()))"
        }
        let observable = Observable.just(items)
        return observable
            .delay(1, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: Driver.empty())
    }
}

class RefreshViewController: UIViewController {
    //表格
    var tableView:UITableView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //创建表格视图
        self.tableView = UITableView(frame: self.view.bounds, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self,
                                 forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
        
//        //设置头部刷新控件
//        self.tableView.mj_header = MJRefreshNormalHeader()
//
//        //初始化ViewModel
//        let viewModel = ViewModel(headerRefresh:
//            self.tableView.mj_header.rx.refreshing.asDriver())
//
//        //单元格数据的绑定
//        viewModel.tableData.asDriver()
//            .drive(tableView.rx.items) { (tableView, row, element) in
//                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
//                cell.textLabel?.text = "\(row+1)、\(element)"
//                return cell
//            }
//            .disposed(by: disposeBag)
//
//        //下拉刷新状态结束的绑定
//        viewModel.endHeaderRefreshing
//            .drive(self.tableView.mj_header.rx.endRefreshing)
//            .disposed(by: disposeBag)
        
        //设置尾部刷新控件
        self.tableView.mj_footer = MJRefreshBackNormalFooter()
        
        //初始化ViewModel
        let viewModel = ViewModel(
            footerRefresh: self.tableView.mj_footer.rx.refreshing.asDriver(),
            dependency: (
                disposeBag: self.disposeBag,
                networkService: NetworkService()))
        
        //单元格数据的绑定
        viewModel.tableData.asDriver()
            .drive(tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = "\(row+1)、\(element)"
                return cell
            }
            .disposed(by: disposeBag)
        
        //上拉刷新状态结束的绑定
        viewModel.endFooterRefreshing
            .drive(self.tableView.mj_footer.rx.endRefreshing)
            .disposed(by: disposeBag)
        
        
    }
}
