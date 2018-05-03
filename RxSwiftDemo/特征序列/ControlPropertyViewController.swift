//
//  ControlPropertyViewController.swift
//  RxSwiftDemo
//
//  Created by yh on 2018/5/3.
//  Copyright © 2018年 YH. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/*
 （1）ControlProperty 是专门用来描述 UI 控件属性，拥有该类型的属性都是被观察者（Observable）。
 （2）ControlProperty 具有以下特征：
 不会产生 error 事件
 一定在 MainScheduler 订阅（主线程订阅）
 一定在 MainScheduler 监听（主线程监听）
 共享状态变化
 */

/*
 1）ControlEvent 是专门用于描述 UI 所产生的事件，拥有该类型的属性都是被观察者（Observable）。
 （2）ControlEvent 和 ControlProperty 一样，都具有以下特征：
 不会产生 error 事件
 一定在 MainScheduler 订阅（主线程订阅）
 一定在 MainScheduler 监听（主线程监听）
 共享状态变化

 */

class ControlPropertyViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        //订阅按钮点击事件
        button.rx.tap
            .subscribe(onNext: {
                print("欢迎访问hangge.com")
            }).disposed(by: disposeBag)
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        
        //页面显示状态完毕
        self.rx.isVisible
            .subscribe(onNext: { visible in
                print("当前页面显示状态：\(visible)")
            }).disposed(by: disposeBag)
        
        //页面加载完毕
        self.rx.viewDidLoad
            .subscribe(onNext: {
                print("viewDidLoad")
            }).disposed(by: disposeBag)
        
        //页面将要显示
        self.rx.viewWillAppear
            .subscribe(onNext: { animated in
                print("viewWillAppear")
            }).disposed(by: disposeBag)
        
        //页面显示完毕
        self.rx.viewDidAppear
            .subscribe(onNext: { animated in
                print("viewDidAppear")
            }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}



/*
 这里我们对 UIViewController 进行扩展：
 将 viewDidLoad、viewDidAppear、viewDidLayoutSubviews 等各种 ViewController 生命周期的方法转成 ControlEvent 方便在 RxSwift 项目中使用。
 增加 isVisible 序列属性，方便对视图的显示状态进行订阅。
 增加 isDismissing 序列属性，方便对视图的释放进行订阅。

 */
extension Reactive where Base: UIViewController {
    public var viewDidLoad: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }
    
    public var viewWillAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear))
            .map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    public var viewDidAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidAppear))
            .map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    public var viewWillDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear))
            .map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    public var viewDidDisappear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidDisappear))
            .map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    public var viewWillLayoutSubviews: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillLayoutSubviews))
            .map { _ in }
        return ControlEvent(events: source)
    }
    public var viewDidLayoutSubviews: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLayoutSubviews))
            .map { _ in }
        return ControlEvent(events: source)
    }
    
    public var willMoveToParentViewController: ControlEvent<UIViewController?> {
        let source = self.methodInvoked(#selector(Base.willMove))
            .map { $0.first as? UIViewController }
        return ControlEvent(events: source)
    }
    public var didMoveToParentViewController: ControlEvent<UIViewController?> {
        let source = self.methodInvoked(#selector(Base.didMove))
            .map { $0.first as? UIViewController }
        return ControlEvent(events: source)
    }
    
    public var didReceiveMemoryWarning: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.didReceiveMemoryWarning))
            .map { _ in }
        return ControlEvent(events: source)
    }
    
    //表示视图是否显示的可观察序列，当VC显示状态改变时会触发
    public var isVisible: Observable<Bool> {
        let viewDidAppearObservable     = self.base.rx.viewDidAppear.map{_ in true}
        let viewWillDisappearObservable = self.base.rx.viewWillDisappear.map{_ in false}
        
        return Observable<Bool>.merge(viewDidAppearObservable,
                                      viewWillDisappearObservable)
    }
    
    //表示页面被释放的可观察序列，当VC被dismiss时会触发
    public var isDismissing: ControlEvent<Bool> {
        let source = self.sentMessage(#selector(Base.dismiss))
            .map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
}
