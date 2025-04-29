//
//  HomeMine.swift
//  toolBox
//
//  Created by wang on 2025/3/24.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit
import SDWebImage
import TZImagePickerController
import SVProgressHUD
import WebKit
import MessageUI

class HomeMine: BaseViewController {
    // MARK: - UI组件
    
    /// 标题标签
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "资料"
        label.font = .boldSystemFont(ofSize: 33)
        label.textColor = .white
        return label
    }()
    ///用户头像
    @IBOutlet weak var headImgV: UIImageView!
    ///用户昵称
    @IBOutlet weak var nickNameLab: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加登录成功通知监听
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserLoginStatusChange), name: NSNotification.Name("UserDidLogin"), object: nil)
        
        // 添加登出通知监听
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserLoginStatusChange), name: NSNotification.Name("UserDidLogout"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func initUI() {
        super.initUI()
        navView.isHidden = false
        /// 背景渐变视图
        view.backgroundColor = .gradientColor(
            with: CGSize(width: screenW, height: screenH),
            direction: .upwardDiagonalLine,
            startColor: .hex(hexString: "#0C7BB3"),
            endColor: .hex(hexString: "#F2BAE8")
        )
        
        // 添加标题
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(statusBarHeight + 10)
            make.leading.equalTo(20)
        }
        navView.backgroundColor = .clear
        navLeftBtn.isHidden = true
        navRightBtn.setImage(.init(named: "icon_home_message"), for: .normal)
        navRightBtn.rx.controlEvent(.touchUpInside).bind { [weak self]() in
            let vc = MessageListViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by:disBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 不再在此处进行登录检查，而是在TabBar点击时检查
        // 如果已登录，则更新用户信息
        if UserManager.shared.isLoggedIn {
            updateUserInfo()
        }
    }
    
    
    // MARK: - 登录状态检查
    
    private func checkLoginStatus() {
        if !UserManager.shared.isLoggedIn {
            // 显示登录页面
            presentLoginVC()
        } else {
            // 已登录，更新用户信息
            updateUserInfo()
        }
    }
    
    private func presentLoginVC() {
        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        loginVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(loginVC, animated: true)
//        loginVC.modalPresentationStyle = .fullScreen
//        present(loginVC, animated: true)
    }
    
    private func updateUserInfo() {
        // 这里可以添加更新用户信息的代码
        if let phone = UserManager.shared.userPhone {
            nickNameLab.text = "用户\(phone.suffix(4))"
        }
    }
    
    @objc private func handleUserLoginStatusChange() {
        // 登录状态变化后更新界面
        if UserManager.shared.isLoggedIn {
            updateUserInfo()
        }
    }
    
    ///修改头像
    @IBAction func touchChangeHead(_ sender: Any) {
        let alertController = UIAlertController(
            title: "请选择操作内容",
            message: "系统头像不需要审核，上传头像需要审核",
            preferredStyle: .actionSheet
        )
        // 添加举报选项
        let randomAction = UIAlertAction(title: "随机系统头像", style: .default) { [weak self] _ in
            self?.handleReport(reason: "随机系统头像", forRow: 1)
        }
        
        let cameraAction = UIAlertAction(title: "上传头像", style: .default) { [weak self] _ in
            self?.handleReport(reason: "上传头像", forRow: 2)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        // 将选项添加到控制器
        alertController.addAction(randomAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        // 在iPad上设置弹出位置
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        // 显示警告控制器
        present(alertController, animated: true)
    }
    
    // 处理头像
    private func handleReport(reason: String, forRow row: Int) {
        switch row {
        case 1:
            print("系统随机头像")
            if let path = Bundle.main.path(forResource: "DynamicHead", ofType: "plist"),
               let urlArray = NSArray(contentsOfFile: path) as? [String] {

                let randomIndex = Int.random(in: 0..<urlArray.count)
                let headUrs = urlArray[randomIndex]
                headImgV.sd_setImage(with: NSURL(string: headUrs) as URL?)
            }
        case 2:
            print("相册上传头像")
            
            let picker = TZImagePickerController(maxImagesCount: 1, delegate: nil)!
            
            // 配置选择器界面
            picker.allowPickingVideo = false
            picker.allowTakePicture = true
            picker.allowPickingOriginalPhoto = true
            picker.showSelectedIndex = true
            picker.allowCrop = false
            picker.modalPresentationStyle = .fullScreen
            
            // 自定义UI
            picker.iconThemeColor = .systemBlue
            picker.showPhotoCannotSelectLayer = true
            picker.oKButtonTitleColorNormal = .systemBlue
            picker.oKButtonTitleColorDisabled = .lightGray
            
            // 自定义文本
            picker.doneBtnTitleStr = "完成"
            picker.cancelBtnTitleStr = "取消"
            picker.previewBtnTitleStr = "预览"
            picker.fullImageBtnTitleStr = "原图"
            picker.settingBtnTitleStr = "设置"
            picker.processHintStr = "处理中..."
            
            // 设置完成回调
            picker.didFinishPickingPhotosHandle = { [weak self] (photos, _, _) in
                guard let self = self, let selectedPhoto = photos?.first else {
                    return
                }
                ///等待审核
                SVProgressHUD.show()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) { [weak self] in
                    guard let self = self else { return }
                    // 显示成功提示
                    SVProgressHUD.showSuccess(withStatus: "等待审核，稍后在消息中心查看")
                }
            }
            
            // 显示图片选择器
            present(picker, animated: true)
        default:
            break
        }
    }
    
    
    ///修改昵称
    @IBAction func touchChangeName(_ sender: Any) {
        let alertController = UIAlertController(
            title: "请选择操作内容",
            message: "系统昵称不需要审核，上传昵称需要审核",
            preferredStyle: .actionSheet
        )
//        alertController.addTextField()
        
        // 添加举报选项
        let randomAction = UIAlertAction(title: "随机系统昵称", style: .default) { [weak self] _ in
            self?.nickNameReport(reason: "随机系统昵称", forRow: 1)
        }
        
        let cameraAction = UIAlertAction(title: "自定义昵称", style: .default) { [weak self] _ in
            self?.nickNameReport(reason: "自定义昵称", forRow: 2)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        // 将选项添加到控制器
        alertController.addAction(randomAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        // 在iPad上设置弹出位置
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        // 显示警告控制器
        present(alertController, animated: true)
    }
    
    // 处理头像
    private func nickNameReport(reason: String, forRow row: Int) {
        switch row {
        case 1:
            print("系统随机昵称")
            if let path = Bundle.main.path(forResource: "DynamicName", ofType: "plist"),
               let urlArray = NSArray(contentsOfFile: path) as? [String] {

                let randomIndex = Int.random(in: 0..<urlArray.count)
                let nameStr = urlArray[randomIndex]
                nickNameLab.text = nameStr
            }
        case 2:
            print("自定义上传昵称")
            let alertController = UIAlertController(
                title: "修改昵称",
                message: "",
                preferredStyle: .alert
            )
            alertController.addTextField()
            
            // 添加举报选项
            let editNameAction = UIAlertAction(title: "确认修改", style: .default) { [weak self] _ in
                SVProgressHUD.show()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) { [weak self] in
                    guard let self = self else { return }
                    // 显示成功提示
                    SVProgressHUD.showSuccess(withStatus: "等待审核，稍后在消息中心查看")
                }
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel)
            
            // 将选项添加到控制器
            alertController.addAction(editNameAction)
            alertController.addAction(cancelAction)

            // 显示警告控制器
            present(alertController, animated: true)
        default:
            break
        }
    }
       
    
    ///点击事件
    @IBAction func touchAction(_ sender: UIButton) {
        switch sender.tag{
        case 1:
            print("我的帖子")
            let myAccountVC =  MyAIAccountViewController()
            myAccountVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(myAccountVC, animated: true)
        case 2:
            print("联系我们")
            sendContactEmail()
        case 3:
            print("隐私政策")
            // 创建隐私政策网页控制器
            let privacyURL = URL(string: "https://www.termsfeed.com/live/632afebe-18d5-42ae-ade6-2cbad0d8c3eb")!
            let privacyVC = PrivacyPolicyViewController(url: privacyURL)
            privacyVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(privacyVC, animated: true)
        case 4:
            print("注销账号")
            signOutAccount()
        case 5:
            print("退出登录")
            quitAccount()
        default:
            break
        }
    }
    
    
    // MARK: 退出账号
    private func quitAccount(){
        let alertController = UIAlertController(
                        title: "确认退出当前账号吗？",
                        message: "",
                        preferredStyle: .alert
                    )
                    
        let nextAction = UIAlertAction(title: "退出登录", style: .default) { [weak self] _ in
            UserManager.shared.logout()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        // 将选项添加到控制器
        alertController.addAction(nextAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)

    }
    
    // MARK: 注销账号
    private func signOutAccount(){
        let alertController = UIAlertController(
                        title: "提示",
                        message: "注销账号后，我们将删除账号下所有的数据，并且不可恢复！",
                        preferredStyle: .alert
                    )
                    
        let nextAction = UIAlertAction(title: "继续注销", style: .default) { [weak self] _ in
            SVProgressHUD.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) { [weak self] in
                guard let _ = self else { return }
                UserManager.shared.logout()
                // 显示成功提示
                SVProgressHUD.showSuccess(withStatus: "注销成功")
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        // 将选项添加到控制器
        alertController.addAction(nextAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)

    }
    
    // MARK: - 发送邮件功能
    private func sendContactEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            
            // 设置收件人邮箱
            mailComposeVC.setToRecipients(["sysworker@163.com"])
            
            // 设置邮件主题
            mailComposeVC.setSubject("ToolBox用户反馈")
            
            // 设置邮件正文
            let deviceInfo = "设备型号: \(UIDevice.current.model)\n系统版本: \(UIDevice.current.systemVersion)\n应用版本: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "未知")"
            mailComposeVC.setMessageBody("请在此处描述您的问题或建议：\n\n\n\n\n\n\n\n\n----------------------\n用户设备信息：\n\(deviceInfo)", isHTML: false)
            
            // 显示邮件编辑界面
            present(mailComposeVC, animated: true)
        } else {
            // 设备无法发送邮件时的处理
            let alertController = UIAlertController(
                title: "无法发送邮件",
                message: "您的设备未设置邮件账户，请设置邮件账户后再试，或直接发送邮件至sysworker@163.com",
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "确定", style: .default)
            alertController.addAction(okAction)
            
            present(alertController, animated: true)
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension HomeMine: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // 根据发送结果显示不同提示
        switch result {
        case .cancelled:
            print("邮件取消发送")
        case .saved:
            SVProgressHUD.showSuccess(withStatus: "邮件已保存")
        case .sent:
            SVProgressHUD.showSuccess(withStatus: "邮件发送成功")
        case .failed:
            SVProgressHUD.showError(withStatus: "邮件发送失败：\(error?.localizedDescription ?? "未知错误")")
        @unknown default:
            break
        }
        
        // 关闭邮件编辑界面
        controller.dismiss(animated: true)
    }
}

// MARK: - 隐私政策视图控制器
class PrivacyPolicyViewController: BaseViewController {
    
    private let webView = WKWebView()
    private let url: URL
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navTitleLabel.text = "隐私政策"
        loadWebContent()
    }
    
    override func initUI() {
        super.initUI()
        // 设置网页视图
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.equalTo(navView.snp_bottomMargin)
            make.bottom.equalTo(self.view.snp.bottomMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        // 添加进度条
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.equalTo(navView.snp_bottomMargin).offset(5)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(4)
        }
        
        // 监听加载进度
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        // 保持对进度条的引用
        self.view.tag = 100
        progressView.tag = 101
    }
    
    private func loadWebContent() {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    override func back() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    // 监听进度变化
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress", let progress = change?[.newKey] as? Double {
            if let progressView = view.viewWithTag(101) as? UIProgressView {
                progressView.progress = Float(progress)
                progressView.isHidden = progress >= 1.0
            }
        }
    }
    
    // 移除观察者
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
}



