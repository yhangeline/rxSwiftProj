//
//  TwoWayBindVC.swift
//  RxSwiftDemo
//
//  Created by yh on 2018/5/3.
//  Copyright © 2018年 YH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


struct UserViewModel {
    //用户名
    let username = Variable("guest")
    
    //用户信息
    lazy var userinfo = {
        return self.username.asObservable()
            .map{ $0 == "yh" ? "您是管理员" : "您是普通访客" }
            .share(replay: 1)
    }()
}

class TwoWayBindVC: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var label: UILabel!
    
     var userVM = UserViewModel()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //将用户名与textField做双向绑定
//        userVM.username.asObservable().bind(to: textField.rx.text).disposed(by: disposeBag)
//        textField.rx.text.orEmpty.bind(to: userVM.username).disposed(by: disposeBag)
        
        
        //自定义双向绑定操作符后 可以这样写  自定义
        _ =  self.textField.rx.textInput <->  self.userVM.username
        
        //将用户信息绑定到label上
        userVM.userinfo.bind(to: label.rx.text).disposed(by: disposeBag)
        
        
    }
}
