//
//  LoginViewController.swift
//  RxSwiftDemo
//
//  Created by yh on 2018/5/7.
//  Copyright © 2018年 YH. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "登录"
        
        let viewModel = LoginViewModel(input: (username: usernameTextField.rx.text.orEmpty.asDriver(),
                                               password: passwordTextField.rx.text.orEmpty.asDriver(),
                                               loginTaps:loginButton.rx.tap.asDriver()),
                                       service: ValidationService.instance)
        
        viewModel.usernameUseable.drive(nameLabel.rx.validationResult).disposed(by: disposeBag)
        
        viewModel.loginButtonEnabled.drive(onNext: { [weak self] (valid) in
            self?.loginButton.isEnabled = valid
            self?.loginButton.alpha = valid ? 1.0 : 0.5
        }).disposed(by: disposeBag)
        
        viewModel.loginResult.drive(onNext: { [weak self](result) in
            switch result {
            case let .ok(message):
                self?.showAlert(message: message)
                self?.navigationController?.popToRootViewController(animated: true)
            case .empty:
                self?.showAlert(message: "")
            case let .failed(message):
                self?.showAlert(message: message)
            }
        }).disposed(by: disposeBag)
    }
    
    func showAlert(message:String) {
        let action = UIAlertAction(title: "确定", style: .default) { [weak self](_) in
            self?.usernameTextField.text = ""
            self?.passwordTextField.text = ""
        }
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}
