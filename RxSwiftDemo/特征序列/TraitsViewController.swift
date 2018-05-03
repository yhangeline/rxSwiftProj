//
//  TraitsViewController.swift
//  RxSwiftDemo
//
//  Created by yh on 2018/5/2.
//  Copyright © 2018年 YH. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TraitsViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        single()
//        completable()
        maybe()
    }
    
    func maybe() {
        generateString()
            .subscribe { maybe in
                switch maybe {
                case .success(let element):
                    print("执行完毕，并获得元素：\(element)")
                case .completed:
                    print("执行完毕，且没有任何元素。")
                case .error(let error):
                    print("执行失败: \(error.localizedDescription)")
                    
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    
    func generateString() -> Maybe<String> {
        return Maybe<String>.create { maybe in
            
            //成功并发出一个元素
            maybe(.success("hangge.com"))
            
            //成功但不发出任何元素
//            maybe(.completed)
            
            //失败
//            maybe(.error(StringError.failedGenerate))
            
            return Disposables.create {}
        }
    }
    
    //与缓存相关的错误类型
    enum StringError: Error {
        case failedGenerate
    }
    
    func completable() {
        cacheLocally()
            .subscribe { completable in
                switch completable {
                case .completed:
                    print("保存成功!")
                case .error(let error):
                    print("保存失败: \(error.localizedDescription)")
                }
            }
            .disposed(by: disposeBag)
    }
    
    func single() {
        //获取第0个频道的歌曲信息
        getPlaylist("0")
            .subscribe { event in
                switch event {
                case .success(let json):
                    print("JSON结果: ", json)
                case .error(let error):
                    print("发生错误: ", error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    //将数据缓存到本地
    func cacheLocally() -> Completable {
        return Completable.create { completable in
            //将数据缓存到本地（这里掠过具体的业务代码，随机成功或失败）
            let success = (arc4random() % 2 == 0)
            
            guard success else {
                completable(.error(CacheError.failedCaching))
                return Disposables.create {}
            }
            
            completable(.completed)
            return Disposables.create {}
        }
    }
    
    //与缓存相关的错误类型
    enum CacheError: Error {
        case failedCaching
    }
    

    //获取豆瓣某频道下的歌曲信息
    func getPlaylist(_ channel: String) -> Single<[String: Any]> {
        return Single<[String: Any]>.create { single in
            let url = "https://douban.fm/j/mine/playlist?"
                + "type=n&channel=\(channel)&from=mainsite"
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, _, error in
                if let error = error {
                    single(.error(error))
                    return
                }

                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data,
                                                                 options: .mutableLeaves),
                    let result = json as? [String: Any] else {
                        single(.error(DataError.cantParseJSON))
                        return
                }

                single(.success(result))
            }

            task.resume()

            return Disposables.create { task.cancel() }
        }
    }

    //与数据相关的错误类型
    enum DataError: Error {
        case cantParseJSON
    }

}
