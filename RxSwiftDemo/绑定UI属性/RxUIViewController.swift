//
//  RxUIViewController.swift
//  RxSwiftDemo
//
//  Created by yh on 2018/5/2.
//  Copyright © 2018年 YH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//Rx写法
extension Reactive where Base : UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self.base) { label, fontSize in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}

//常规写法
extension UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self) { label, fontSize in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}

class RxUIViewController: UIViewController {

    @IBOutlet weak var text1: UITextField!
    @IBOutlet weak var text2: UITextField!
    @IBOutlet weak var text3: UITextField!
    
    @IBOutlet weak var label: UILabel!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = Observable.combineLatest(text1.rx.text, text2.rx.text) { $0! + " " + $1! } // 1
            .map { "Greeting \($0)" } // 2
            .bind(to: text3.rx.text) // 3
        

        //Observable序列（每隔0.5秒钟发出一个索引数）
        let observable = Observable<Int>.interval(0.5, scheduler: MainScheduler.instance)
        observable.map { CGFloat($0) }
            .bind(to: label.rx.fontSize) //根据索引数不断变放大字体
            .disposed(by: disposeBag)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
