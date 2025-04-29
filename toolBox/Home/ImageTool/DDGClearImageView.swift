//
//  DDGClearImageView.swift
//  DDGScreenshot
//
//  Created by dudongge on 2018/3/19.
//  Copyright © 2018年 dudongge. All rights reserved.
//

import UIKit
import TZImagePickerController
import RxSwift
import RxCocoa
import SDWebImage

class DDGClearImageView: BaseViewController {
    
    private let disposeBag = DisposeBag()
    
    // 头像URL数组
    private var avatarURLs: [String] = []
    
    //底部图片
    private lazy var bottomImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "image") ?? UIImage(systemName: "photo")
        imageView.frame = CGRect(x: 0, y: 100, width: width, height: width)
        self.view.addSubview(imageView)
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    //要擦除的图片
    private lazy var clearImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo") ?? UIImage(systemName: "scribble")
        imageView.frame = CGRect(x: 0, y: 100, width: width, height: width)
        imageView.isUserInteractionEnabled = true
        self.view.addSubview(imageView)
        return imageView
    }()
    
    // 按钮容器视图
    private lazy var buttonContainerView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 100 + width + 10, width: width, height: 120)
        self.view.addSubview(view)
        return view
    }()
    
    //选择底图按钮
    private lazy var selectBottomImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("选择底图", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        button.frame = CGRect(x: 20, y: 10, width: (width - 60) / 2, height: 40)
        buttonContainerView.addSubview(button)
        return button
    }()
    
    //随机头像按钮
    private lazy var randomAvatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("随机头像", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.layer.cornerRadius = 8
        button.frame = CGRect(x: width/2, y: 10, width: (width - 60) / 2, height: 40)
        buttonContainerView.addSubview(button)
        return button
    }()
    
    //重置按钮
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("重置", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemRed
        button.layer.cornerRadius = 8
        button.frame = CGRect(x: (width - 150) / 2, y: 60, width: 150, height: 40)
        buttonContainerView.addSubview(button)
        return button
    }()
    
    //提示标签
    private lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.text = "请在图片上滑动进行擦除"
        label.textAlignment = .center
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.frame = CGRect(x: 20, y: 110, width: width - 40, height: 20)
        self.view.addSubview(label)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.bottomImageView.isUserInteractionEnabled = false
        let pan = UIPanGestureRecognizer(target: self, action: #selector(DDGClearImageView.clearPan(pan:)))
        self.clearImageView.addGestureRecognizer(pan)
        
        // 加载头像URL数组
        loadAvatarURLs()
        
        setupBindings()
        
        // 设置导航栏标题
        navTitleLabel.text = "图片擦除"
    }
    
    private func setupBindings() {
        // 选择底图按钮点击事件
        selectBottomImageButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showImagePicker()
            })
            .disposed(by: disposeBag)
        
        // 随机头像按钮点击事件
        randomAvatarButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.loadRandomAvatar()
            })
            .disposed(by: disposeBag)
        
        // 重置按钮点击事件
        resetButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.resetClearImage()
            })
            .disposed(by: disposeBag)
    }
    
    // 加载头像URL数组
    private func loadAvatarURLs() {
        if let path = Bundle.main.path(forResource: "DynamicHead", ofType: "plist"),
           let urlArray = NSArray(contentsOfFile: path) as? [String] {
            avatarURLs = urlArray
            print("成功加载 \(avatarURLs.count) 个头像URL")
        } else {
            print("加载DynamicHead.plist失败")
        }
    }
    
    // 加载随机头像
    private func loadRandomAvatar() {
        guard !avatarURLs.isEmpty else {
            showToast(message: "未找到头像资源")
            return
        }
        
        // 获取随机URL
        let randomIndex = Int.random(in: 0..<avatarURLs.count)
        let randomURL = avatarURLs[randomIndex]
        
        // 显示加载指示器
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = bottomImageView.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        // 使用SDWebImage加载图片
        bottomImageView.sd_setImage(with: URL(string: randomURL)) { [weak self] (image, error, _, _) in
            // 移除加载指示器
            activityIndicator.removeFromSuperview()
            
            if let error = error {
                print("加载头像失败: \(error.localizedDescription)")
                self?.showToast(message: "加载头像失败")
                return
            }
            
            if image != nil {
                self?.showToast(message: "已加载随机头像")
            }
        }
    }
    
    // 显示图片选择器
    private func showImagePicker() {
        let picker = TZImagePickerController(maxImagesCount: 1, delegate: nil)!
        picker.didFinishPickingPhotosHandle = { [weak self] (photos, _, _) in
            guard let self = self, let selectedPhoto = photos?.first else { return }
            
            DispatchQueue.main.async {
                // 设置底部图片
                self.bottomImageView.image = selectedPhoto
                
                // 显示成功提示
                self.showToast(message: "已选择底图")
            }
        }
        
        // 配置选择器界面
        picker.allowPickingVideo = false
        picker.allowPickingGif = false
        picker.allowTakePicture = true
        picker.showSelectedIndex = true
        picker.allowPickingOriginalPhoto = true
        
        present(picker, animated: true)
    }
    
    // 重置擦除图片
    private func resetClearImage() {
        clearImageView.image = UIImage(named: "logo") ?? UIImage(systemName: "scribble")
        showToast(message: "已重置")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func clearPan(pan: UIPanGestureRecognizer) {
        //获取当前手指的点
        let imageView = pan.view as! UIImageView
        let clearPan = pan.location(in: imageView)
        //擦除区域的大小
        let rect = CGRect(x: clearPan.x - 15, y: clearPan.y - 15, width: 30, height: 30)
        if let newImage = DDGManage.share.clearImage(imageView: imageView, rect: rect) {
            imageView.image = newImage
        }
    }
    
    // 显示Toast消息
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        
        view.addSubview(toastLabel)
        toastLabel.frame = CGRect(x: (view.frame.width - 200) / 2, y: view.frame.height / 2, width: 200, height: 40)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            toastLabel.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        })
    }
}
