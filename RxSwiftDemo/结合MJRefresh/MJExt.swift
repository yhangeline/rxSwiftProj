//
//  MJExt.swift
//  RxSwiftDemo
//
//  Created by yh on 2018/5/9.
//  Copyright © 2018年 YH. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension Reactive where Base : MJRefreshComponent {
    //正在刷新事件
    var refreshing: ControlEvent<Void> {
        let source: Observable<Void> = Observable.create {
            [weak control = self.base] observer  in
            if let control = control {
                control.refreshingBlock = {
                    observer.on(.next(()))
                }
            }
            return Disposables.create()
        }
        return ControlEvent(events: source)
    }
    
    //停止刷新
    var endRefreshing: Binder<Bool> {
        return Binder(base) { refresh, isEnd in
            if isEnd {
                refresh.endRefreshing()
            }
        }
    }
}
