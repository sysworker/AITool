//
//  LoginViewController.swift
//  toolBox
//
//  Created by joyo on 2025/3/28.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class LoginViewController: BaseViewController {

    @IBOutlet weak var logoImgV: UIImageView!
    
    ///手机号
    @IBOutlet weak var phoneTextF: UITextField!
    ///密码
    @IBOutlet weak var passwordTextF: UITextField!
    ///协议勾选按钮
    @IBOutlet weak var agreementButton: UIButton!
    ///登录按钮
    @IBOutlet weak var loginButton: UIButton!
    
    // 登录完成回调 - success: 是否成功登录
    var loginCompletionHandler: ((Bool) -> Void)?
    
    // 手机号正则表达式
    private let phoneRegex = "^1[3-9]\\d{9}$"
    // 错误提示文本框
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - UI设置
    
    private func setupUI() {
        // 设置导航栏
        navView.isHidden = false
        navTitleLabel.text = "登录/注册"
        navLeftBtn.setImage(.backArr, for: .normal)
        navView.backgroundColor = .clear
        
        // 设置密码输入框
        passwordTextF.isSecureTextEntry = true
        passwordTextF.keyboardType = .numberPad
        
        
        
        // 设置错误提示标签
        view.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextF.snp.bottom).offset(8)
            make.left.equalTo(passwordTextF)
            make.right.equalTo(passwordTextF)
        }
        
        // 默认选中协议勾选框
        agreementButton.isSelected = true
    }
    
    // MARK: - RxSwift绑定
    
    private func setupBindings() {
        // 监听手机号输入
        phoneTextF.rx.text.orEmpty
            .map { [weak self] phone in
                guard let self = self else { return false }
                return self.isValidPhone(phone)
            }
            .bind(to: phoneTextF.rx.validPhone)
            .disposed(by: disBag)
        
        // 监听密码输入
        passwordTextF.rx.text.orEmpty
            .map { password in
                return password.count == 6 && password.allSatisfy { $0.isNumber }
            }
            .bind(to: passwordTextF.rx.validPassword)
            .disposed(by: disBag)
        
        // 创建一个表示验证状态的Observable
        let validationState = Observable.combineLatest(
            phoneTextF.rx.text.orEmpty.map { [weak self] phone in
                guard let self = self else { return false }
                return self.isValidPhone(phone)
            },
            passwordTextF.rx.text.orEmpty.map { password in
                return password.count == 6 && password.allSatisfy { $0.isNumber }
            },
            agreementButton.rx.observe(Bool.self, "isSelected").map { $0 ?? false }
        ) { validPhone, validPassword, agreementChecked in
            return validPhone && validPassword && agreementChecked
        }
        
        // 绑定验证状态到登录按钮的启用状态
        validationState
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disBag)
        
        // 使用验证状态Observable来设置登录按钮的样式
        validationState
            .subscribe(onNext: { [weak self] isEnabled in
                self?.loginButton.alpha = isEnabled ? 1.0 : 0.5
            })
            .disposed(by: disBag)
        
        // 协议按钮点击事件已通过IBAction处理
    }
    
    // MARK: - Action事件
    
    ///协议状态
    @IBAction func AgreementAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    ///隐私协议
    @IBAction func touchAction(_ sender: UIButton) {
        let privacyURL = URL(string: "https://www.termsfeed.com/live/632afebe-18d5-42ae-ade6-2cbad0d8c3eb")!
        let privacyVC = PrivacyPolicyViewController(url: privacyURL)
        privacyVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privacyVC, animated: true)
    }
    
    @IBAction func loginAccount(_ sender: Any) {
        // 验证手机号和密码
        guard let phone = phoneTextF.text, isValidPhone(phone) else {
            showError("请输入正确的手机号码")
            return
        }
        
        guard let password = passwordTextF.text, password.count == 6, password.allSatisfy({ $0.isNumber }) else {
            showError("请输入6位数字密码")
            return
        }
        
        guard agreementButton.isSelected else {
            showError("请阅读并同意隐私政策")
            return
        }
        
        // 显示加载中
        SVProgressHUD.show(withStatus: "登录中...")
        
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            SVProgressHUD.dismiss()
            // 保存登录状态
            self?.saveLoginStatus(phone: phone)
            // 显示登录成功
            SVProgressHUD.showSuccess(withStatus: "登录成功")
            // 延迟关闭当前页面
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                NotificationCenter.default.post(name: NSNotification.Name("UserDidLogin"), object: nil)
                // 登录成功，触发回调
                self?.loginCompletionHandler?(true)

                if self?.presentingViewController != nil {
                    // 如果是模态呈现的，使用dismiss
                    self?.dismiss(animated: true)
                } else {
                    // 如果是导航控制器推出的，使用pop
    //                super.back()
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - 辅助方法
    
    /// 验证手机号是否有效
    private func isValidPhone(_ phone: String) -> Bool {
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phone)
    }
    
    /// 显示错误信息
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        
        // 3秒后自动隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.errorLabel.isHidden = true
        }
    }
    
    /// 保存登录状态到沙盒
    private func saveLoginStatus(phone: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "isLoggedIn")
        userDefaults.set(phone, forKey: "userPhone")
        userDefaults.synchronize()
    }
    
    // 重写返回按钮方法，在用户取消登录时调用回调
    override func back() {
        print("用户点击返回按钮，取消登录")
        // 用户取消登录，触发回调
        loginCompletionHandler?(false)
        
        // 延迟一下再返回，确保回调完全执行
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 判断当前控制器是如何呈现的
            if self.presentingViewController != nil {
                // 如果是模态呈现的，使用dismiss
                self.dismiss(animated: true)
            } else {
                // 如果是导航控制器推出的，使用pop
//                super.back()
                navigationController?.popViewController(animated: true)

            }
        }
    }
    
    // 重写视图消失事件，处理其他返回方式（如滑动返回）
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 如果是被导航控制器弹出（而不是被遮盖），触发取消登录回调
        if self.isMovingFromParent {
            print("视图被弹出，可能是滑动返回")
            // 用户取消登录，触发回调
            loginCompletionHandler?(false)
        }
    }
}

// MARK: - 扩展Reactive，为UITextField添加验证状态
extension Reactive where Base: UITextField {
    var validPhone: Binder<Bool> {
        return Binder(self.base) { textField, valid in
            textField.layer.borderWidth = 1
            textField.layer.borderColor = valid ? UIColor.green.cgColor : UIColor.red.cgColor
        }
    }
    
    var validPassword: Binder<Bool> {
        return Binder(self.base) { textField, valid in
            textField.layer.borderWidth = 1
            textField.layer.borderColor = valid ? UIColor.green.cgColor : UIColor.red.cgColor
        }
    }
}

// MARK: - 用户登录状态管理
class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    var isLoggedIn: Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    var userPhone: String? {
        return UserDefaults.standard.string(forKey: "userPhone")
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userPhone")
        UserDefaults.standard.synchronize()
        
        // 发送登出通知
        NotificationCenter.default.post(name: NSNotification.Name("UserDidLogout"), object: nil)
    }
}
