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


extension Reactive where Base : UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self.base) { label, fontSize in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet var label: UILabel!
    @IBOutlet weak var text1: UITextField!
    @IBOutlet weak var text2: UITextField!
    @IBOutlet weak var text3: UITextField!
    
     let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
       _ = Observable.combineLatest(text1.rx.text, text2.rx.text) { $0! + " " + $1! } // 1
            .map { "Greeting \($0)" } // 2
            .bind(to: text3.rx.text) // 3
        
            //Observable序列（每隔0.5秒钟发出一个索引数）
            let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            observable.map { "当前索引\($0)" }
                .bind(to: label.rx.text) //根据索引数不断变放大字体
                .disposed(by: disposeBag)
        
        
//        //这个block有一个回调参数observer就是订阅这个Observable对象的订阅者
//        //当一个订阅者订阅这个Observable对象的时候，就会将订阅者作为参数传入这个block来执行一些内容
//        let observable = Observable<String>.create{observer in
//            //对订阅者发出了.next事件，且携带了一个数据"hangge.com"
//            observer.onNext("hangge.com")
//            //对订阅者发出了.completed事件
//            observer.onCompleted()
//            //因为一个订阅行为会有一个Disposable类型的返回值，所以在结尾一定要returen一个Disposable
//            return Disposables.create()
//        }
//
//        //订阅测试
//        _ = observable.subscribe {
//            print($0)
//        }

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
//        self.present(RxTableViewController(), animated: true, completion: nil)
        self.present(SubjectsViewController(), animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

