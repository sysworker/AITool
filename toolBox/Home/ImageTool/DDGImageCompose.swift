//
//  DDGImageCompose.swift
//  DDGScreenshot
//
//  Created by dudongge on 2018/3/19.
//  Copyright © 2018年 dudongge. All rights reserved.
//

import UIKit

/// 图片合成工具控制器
class DDGImageCompose: BaseViewController {
    
    // MARK: - 常量
    
    private let bottomPadding: CGFloat = 16
    private let buttonHeight: CGFloat = 44
    
    // MARK: - UI组件
    
    /// 显示合成后图片的视图
    private lazy var imagePreviewView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// 操作按钮容器
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /// 添加水印按钮
    private lazy var addLogoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("添加水印", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addLogoTapped), for: .touchUpInside)
        return button
    }()
    
    /// 多图合成按钮
    private lazy var composeImagesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("多图合成", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(composeImagesTapped), for: .touchUpInside)
        return button
    }()
    
    /// 保存结果按钮
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("保存图片", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(saveImageTapped), for: .touchUpInside)
        button.isHidden = true // 初始隐藏，当有图片时显示
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadInitialImage()
    }
    
    // MARK: - 设置方法
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 添加图片预览视图
        view.addSubview(imagePreviewView)
        
        // 添加按钮容器和按钮
        buttonsStackView.addArrangedSubview(addLogoButton)
        buttonsStackView.addArrangedSubview(composeImagesButton)
        view.addSubview(buttonsStackView)
        
        // 添加保存按钮
        view.addSubview(saveButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            // 图片预览视图约束
            imagePreviewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imagePreviewView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            imagePreviewView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            // 按钮容器约束
            buttonsStackView.topAnchor.constraint(equalTo: imagePreviewView.bottomAnchor, constant: 20),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            // 保存按钮约束
            saveButton.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            saveButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // 计算并设置图片预览视图高度
        let availableHeight = view.bounds.height - 2 * 20 - 2 * buttonHeight - 2 * 20 - view.safeAreaInsets.top - view.safeAreaInsets.bottom
        imagePreviewView.heightAnchor.constraint(equalToConstant: availableHeight).isActive = true
    }
    
    private func loadInitialImage() {
        if let image = UIImage(named: "1") {
            imagePreviewView.image = image
        }
    }
    
    // MARK: - 按钮事件
    
    @objc private func addLogoTapped() {
        // 获取原始图片，如果不存在则显示提示
        guard let originalImage = imagePreviewView.image ?? UIImage(named: "1") else {
            showErrorAlert(message: "无法加载原始图片")
            return
        }
        
        // 获取Logo图片，如果不存在则显示提示
        guard let logoImage = UIImage(named: "logo") else {
            showErrorAlert(message: "无法加载Logo图片")
            return
        }
        
        // 添加水印
        let composedImage = originalImage.composeImageWithLogo(
            logo: logoImage,
            logoOrigin: CGPoint(x: 100, y: 50),
            logoSize: CGSize(width: 120, height: 60)
        )
        
        // 更新UI
        imagePreviewView.image = composedImage
        saveButton.isHidden = false
    }
    
    @objc private func composeImagesTapped() {
        guard let bgImage = UIImage(named: "bgGreen") else {
            showErrorAlert(message: "无法加载背景图片")
            return
        }
        
        // 准备需要合成的图片
        var images: [UIImage] = []
        for i in 0...2 {
            if let image = UIImage(named: "\(i)") {
                images.append(image)
            }
        }
        
        if let logoImage = UIImage(named: "logo") {
            images.append(logoImage)
        }
        
        // 如果没有足够的图片则显示提示
        if images.count < 4 {
            showErrorAlert(message: "无法加载所有需要的图片")
            return
        }
        
        // 定义每个图片的位置和大小
        let imageRects = [
            CGRect(x: 10, y: 10, width: 200, height: 100),
            CGRect(x: 30, y: 150, width: 300, height: 100),
            CGRect(x: 21, y: 280, width: 200, height: 100),
            CGRect(x: 280, y: 280, width: 200, height: 100)
        ]
        
        // 执行图片合成
        let composedImage = DDGManage.share.composeImageWithLogo(
            bgImage: bgImage,
            imageRect: imageRects,
            images: images
        )
        
        // 更新UI
        imagePreviewView.image = composedImage
        saveButton.isHidden = false
    }
    
    @objc private func saveImageTapped() {
        guard let image = imagePreviewView.image else {
            showErrorAlert(message: "没有可保存的图片")
            return
        }
        
        // 保存图片到相册
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // MARK: - 辅助方法
    
    /// 显示错误提示
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "操作失败",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    /// 图片保存回调
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showErrorAlert(message: "保存失败: \(error.localizedDescription)")
        } else {
            let alert = UIAlertController(
                title: "保存成功",
                message: "图片已保存到相册",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "好的", style: .default))
            present(alert, animated: true)
        }
    }
}
