//
//  Service.swift
//  RxSwiftDemo
//
//  Created by yh on 2018/5/7.
//  Copyright © 2018年 YH. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//Service文件主要负责一些网络请求，和一些数据访问的操作。然后供ViewModel使用 由于本次实战没有使用到网络，所以我们只是模拟从本地plist文件中读取用户数据 首先我们在Service文件中创建一个ValidationService类，最好不要继承NSObject，Swift中推荐尽量使用原生类。我们考虑到当文本框内容变化的时候，我们需要把文本框的内容当做参数传递进来进行处理，判断是否符合我们的要求，然后返回处理结果，也就是状态。基于此，我们创建一个Protocol.swift文件，创建一个enum用于表示我们处理结果

class ValidationService {
    
    // 单例类
    static let instance = ValidationService()
    private init(){}
    
    let minCharactersCount = 6
    
    func validationUserName(_ name:String) -> Observable<Result> {
        
        if name.count == 0 { // 当字符串为空的时候，什么也不做
            return Observable.just(Result.empty)
        }
        
        if name.count < minCharactersCount {
            return Observable.just(Result.failed(message: "用户名长度至少为6位"))
        }
        
        if checkHasUserName(name) {
            return Observable.just(Result.failed(message: "用户名已存在"))
        }
        
        return Observable.just(Result.ok(message: "用户名可用"))
    }
    
    func checkHasUserName(_ userName:String) -> Bool {
//        let filePath = NSHomeDirectory() + "/Documents/users.plist"
//        guard let userDict = NSDictionary(contentsOfFile: filePath) else {
//            return false
//        }
//
//        let usernameArray = userDict.allKeys as NSArray
        
        let usernameArray = ["hahahaha","lalalala"]
        
        
        return usernameArray.contains(userName)
    }
    
    func validationPassword(_ password:String) -> Result {
        if password.count == 0 {
            return .empty
        }
        
        if password.count < minCharactersCount {
            return .failed(message: "密码长度至少为6位")
        }
        
        return .ok(message: "密码可用")
    }
    
    func validationRePassword(_ password:String, _ rePassword: String) -> Result {
        if rePassword.count == 0 {
            return .empty
        }
        
        if rePassword.count < minCharactersCount {
            return .failed(message: "密码长度至少为6位")
        }
        
        if rePassword == password {
            return .ok(message: "密码可用")
        }
        
        return .failed(message: "两次密码不一样")
    }
    
    //直接把注册信息写入到本地的plist文件，写入成功就返回ok，否则就是failed。
    func register(_ username:String, password:String) -> Observable<Result> {
        let userDict = [username: password]
        let filePath = Bundle.main.path(forResource: "yh", ofType: "plist")
        if (userDict as NSDictionary).write(toFile: filePath!, atomically: true) {
            return Observable.just(Result.ok(message: "注册成功"))
        }else{
            return Observable.just(Result.failed(message: "注册失败"))
        }
    }
    
}


//接下来该处理我们的RegisterViewModel了，我们声明一个username，指定为Variable类型，为什么是一个Variable类型？因为它既是一个Observer，又是一个Observable，所以我们声明它是一个Variable类型的对象。我们对username处理应该会有一个结果，这个结果应该是由界面监听来改变界面显示，因此我们声明一个usernameUseable表示对username处理的一个结果，因为它是一个Observable，所以我们将它声明为Observable类型的对象，所以RegisterViewModel看起来应该是这样子的

class RegisterViewModel {
    let username = Variable<String>("")
    let password = Variable<String>("")
    let rePassword = Variable<String>("")
    
    let usernameUseable:Observable<Result>
    let passwordUseable:Observable<Result>
    let rePasswordUseable:Observable<Result>
    
    let registerTaps = PublishSubject<Void>()
    
    let registerButtonEnabled:Observable<Bool>
    let registerResult:Observable<Result>
    
    init(){
        let service = ValidationService.instance
        
        usernameUseable = username.asObservable().flatMapLatest{ username in
            return service.validationUserName(username).observeOn(MainScheduler.instance).catchErrorJustReturn(.failed(message: "userName检测出错")).share(replay: 1)
        }
        
        passwordUseable = password.asObservable().map { passWord in
            return service.validationPassword(passWord)
            }.share(replay: 1)
        
        rePasswordUseable = Observable.combineLatest(password.asObservable(), rePassword.asObservable()) {
            return service.validationRePassword($0, $1)
            }.share(replay: 1)
        
        registerButtonEnabled = Observable.combineLatest(usernameUseable, passwordUseable, rePasswordUseable) { (username, password, repassword) in
            return username.isValid && password.isValid && repassword.isValid
            }.distinctUntilChanged().share(replay: 1)
        
        let usernameAndPwd = Observable.combineLatest(username.asObservable(), password.asObservable()){
            return ($0, $1)
        }
        
        registerResult = registerTaps.asObservable().withLatestFrom(usernameAndPwd).flatMapLatest {arg in
            
            return service.register(arg.0, password: arg.1).observeOn(MainScheduler.instance).catchErrorJustReturn(Result.failed(message: "注册失败"))
        }
    }
    
}


