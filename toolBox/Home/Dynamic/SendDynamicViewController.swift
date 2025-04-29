//
//  SendDynamicViewController.swift
//  toolBox
//
//  Created by joyo on 2025/3/28.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit
import Photos
import TZImagePickerController
import SVProgressHUD

class SendDynamicViewController: BaseViewController {
    
    // MARK: - 属性
    
    /// 文本编辑视图
    private lazy var contentTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .black
        textView.backgroundColor = .white.withAlphaComponent(0.8)
        textView.layer.cornerRadius = 10
        textView.layer.masksToBounds = true
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.returnKeyType = .done
        textView.placeholder = "分享你的想法..."
        return textView
    }()
    
    /// 添加图片按钮
    private lazy var addPhotoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "icon_add_dynamic") ?? UIImage(systemName: "plus.square.fill.on.square.fill"), for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.backgroundColor = .white.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(addPhotoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// 图片预览视图
    private lazy var imagePreviewView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    /// 选择的图片
    private lazy var selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    /// 删除图片按钮
    private lazy var deleteImageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(deleteImageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// 发布按钮
    private lazy var publishButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("发布", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(publishButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// 选中的图片
    private var selectedImage: UIImage?
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 检查用户登录状态
        checkLoginStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI设置
    
    override func initUI() {
        super.initUI()
        navView.isHidden = false
        /// 背景渐变视图
        view.backgroundColor = .gradientColor(
            with: CGSize(width: screenW, height: screenH),
            direction: .upwardDiagonalLine,
            startColor: .hex(hexString: "#E8F5C8"),
            endColor: .hex(hexString: "#9FA5D5")
        )
        
        navView.backgroundColor = .clear
        navTitleLabel.text = "发布动态"
    }
    
    private func setupViews() {
        // 添加内容输入框
        view.addSubview(contentTextView)
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(navView.snp.bottom).offset(20)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(150)
        }
        
        // 添加图片按钮
        view.addSubview(addPhotoButton)
        addPhotoButton.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(16)
            make.left.equalTo(16)
            make.width.height.equalTo(80)
        }
        
        // 图片预览视图
        view.addSubview(imagePreviewView)
        imagePreviewView.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(16)
            make.left.equalTo(16)
            make.width.height.equalTo(120)
        }
        
        // 选中的图片显示
        imagePreviewView.addSubview(selectedImageView)
        selectedImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 删除图片按钮
        imagePreviewView.addSubview(deleteImageButton)
        deleteImageButton.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.right.equalTo(-5)
            make.width.height.equalTo(30)
        }
        
        // 发布按钮
        view.addSubview(publishButton)
        publishButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.left.equalTo(50)
            make.right.equalTo(-50)
            make.height.equalTo(44)
        }
        
        // 设置文本视图代理
        contentTextView.delegate = self
    }
    
    // MARK: - 键盘处理
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            UIView.animate(withDuration: 0.3) {
                self.publishButton.snp.updateConstraints { make in
                    make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-keyboardHeight - 10)
                }
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.publishButton.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - 按钮事件
    
    @objc private func addPhotoButtonTapped() {
        let alertController = UIAlertController(title: "选择图片", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "拍照", style: .default) { [weak self] _ in
            self?.openCamera()
        }
        
        let photoLibraryAction = UIAlertAction(title: "从相册选择", style: .default) { [weak self] _ in
            self?.openPhotoLibrary()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        
        // 确保在iPad上也能正常展示
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = addPhotoButton
            popoverController.sourceRect = addPhotoButton.bounds
        }
        
        present(alertController, animated: true)
    }
    
    @objc private func deleteImageButtonTapped() {
        selectedImage = nil
        imagePreviewView.isHidden = true
        addPhotoButton.isHidden = false
    }
    
    @objc private func publishButtonTapped() {
        // 验证内容不为空
        guard let content = contentTextView.text, !content.isEmpty, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            SVProgressHUD.showError(withStatus: "请输入内容")
            return
        }
        
        // 显示加载提示
        SVProgressHUD.show(withStatus: "正在发布...")
        
        // 网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // 创建动态数据模型
            let dynamicModel = DynamicModel(
                headImg: self.getRandomAvatar(),
                nickNameStr: "我的动态",
                contentStr: content
            )
            
            // 发布成功
            SVProgressHUD.showSuccess(withStatus: "发布成功")
            
            // 发送通知，通知列表页刷新
            NotificationCenter.default.post(
                name: NSNotification.Name("DynamicPublished"),
                object: nil,
                userInfo: ["dynamic": dynamicModel]
            )
            
            // 延迟返回前一页
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - 辅助方法
    
    private func openCamera() {
        // 检查相机权限
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        } else {
            SVProgressHUD.showError(withStatus: "无法访问相机")
        }
    }
    
    private func openPhotoLibrary() {
        // 使用TZImagePickerController选择图片
        let imagePicker = TZImagePickerController(maxImagesCount: 1, delegate: nil)!
        imagePicker.allowPickingVideo = false
        imagePicker.allowTakeVideo = false
        imagePicker.allowTakePicture = true
        imagePicker.allowPickingOriginalPhoto = true
        imagePicker.showSelectBtn = false
        imagePicker.didFinishPickingPhotosHandle = { [weak self] photos, assets, _ in
            guard let self = self, let photo = photos?.first else { return }
            
            DispatchQueue.main.async {
                self.selectedImage = photo
                self.selectedImageView.image = photo
                self.imagePreviewView.isHidden = false
                self.addPhotoButton.isHidden = true
            }
        }
        
        present(imagePicker, animated: true)
    }
    
    /// 获取随机头像URL
    private func getRandomAvatar() -> String {
        var avatarURLs: [String] = []
        
        if let path = Bundle.main.path(forResource: "DynamicHead", ofType: "plist"),
           let urlArray = NSArray(contentsOfFile: path) as? [String] {
            avatarURLs = urlArray
        }
        
        // 如果头像数组为空，返回默认头像
        guard !avatarURLs.isEmpty else {
            return "https://picsum.photos/100/100"
        }
        
        // 随机选择头像
        let randomIndex = Int.random(in: 0..<avatarURLs.count)
        return avatarURLs[randomIndex]
    }
    
    // MARK: - 登录状态检查
    
    private func checkLoginStatus() {
        if !UserManager.shared.isLoggedIn {
            // 显示登录页面
            let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
            
            // 添加登录完成回调
            loginVC.loginCompletionHandler = { [weak self] success in
                if !success {
                    // 如果用户取消登录，返回到上一个页面
                    DispatchQueue.main.async {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
                // 登录成功的情况不需要特殊处理，保持在当前发布页面
            }
            
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
        }
    }
}

// MARK: - UITextViewDelegate
extension SendDynamicViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

// MARK: - UIImagePickerControllerDelegate
extension SendDynamicViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            selectedImageView.image = editedImage
            imagePreviewView.isHidden = false
            addPhotoButton.isHidden = true
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            selectedImageView.image = originalImage
            imagePreviewView.isHidden = false
            addPhotoButton.isHidden = true
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - 占位符扩展
extension UITextView {
    /// 占位符标签的关联键
    private struct AssociatedKeys {
        static var placeholderLabel = "placeholderLabel"
    }
    
    /// 占位符文本
    var placeholder: String? {
        get {
            return placeholderLabel.text
        }
        set {
            // 如果占位符文本为空，则隐藏占位符标签
            if let placeholderText = newValue, !placeholderText.isEmpty {
                placeholderLabel.text = placeholderText
                placeholderLabel.isHidden = !text.isEmpty
            } else {
                placeholderLabel.isHidden = true
            }
        }
    }
    
    /// 懒加载占位符标签
    private var placeholderLabel: UILabel {
        // 从关联对象中获取占位符标签
        if let label = objc_getAssociatedObject(self, &AssociatedKeys.placeholderLabel) as? UILabel {
            return label
        }
        
        // 创建并配置占位符标签
        let label = UILabel()
        label.font = font ?? .systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        // 设置占位符标签的约束
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: textContainer.lineFragmentPadding == 0 ? leadingAnchor : leadingAnchor, constant: textContainerInset.left + textContainer.lineFragmentPadding),
            label.topAnchor.constraint(equalTo: topAnchor, constant: textContainerInset.top),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -textContainerInset.right)
        ])
        
        // 添加文本变化的观察
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
        
        // 存储占位符标签作为关联对象
        objc_setAssociatedObject(self, &AssociatedKeys.placeholderLabel, label, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return label
    }
    
    /// 文本变化时的处理
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
}
