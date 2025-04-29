//
//  TextRecognitionVC.swift
//  toolBox
//
//  Created by wang on 2025/3/24.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit
import Vision
import TZImagePickerController
import RxSwift
import RxCocoa
import SnapKit

class TextRecognitionVC: BaseViewController {
    
    // MARK: - 属性
    
    private let disposeBag = DisposeBag()
    
    // 图像视图
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.secondarySystemBackground
        imageView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.systemGray5.cgColor
        return imageView
    }()
    
    // 识别结果文本框
    private lazy var resultTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.secondarySystemBackground
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.isEditable = false
        textView.text = "识别结果将在这里显示..."
        textView.textColor = .secondaryLabel
        return textView
    }()
    
    // 选择图片按钮
    private lazy var selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("选择照片", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(showImagePicker), for: .touchUpInside)
        return button
    }()
    
    // 开始识别按钮
    private lazy var startRecognitionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("开始识别", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(recognizeButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // 清除按钮
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("清除", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // 活动指示器
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemBlue
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // 当前选择的图片
    private var selectedImage: UIImage? {
        didSet {
            startRecognitionButton.isHidden = selectedImage == nil
            startRecognitionButton.isEnabled = selectedImage != nil
            startRecognitionButton.alpha = selectedImage != nil ? 1.0 : 0.5
        }
    }
    
    // 复制按钮
    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("复制", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // MARK: - 视图生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initUI() {
        super.initUI()
        setupUI()
        setupBindings()
        setupActions()
    }
    
    // MARK: - UI设置
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 添加说明标签
        let titleLabel = UILabel()
        titleLabel.text = "图片文字识别"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        view.addSubview(titleLabel)
        
        // 创建说明标签
        let descriptionLabel = UILabel()
        descriptionLabel.text = "选择一张图片以识别其中的文字内容"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        view.addSubview(descriptionLabel)
        
        // 创建图片视图
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.secondarySystemBackground
        imageView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.systemGray5.cgColor
        view.addSubview(imageView)
        
        // 创建选择照片按钮
        selectImageButton = UIButton(type: .system)
        selectImageButton.setTitle("选择照片", for: .normal)
        selectImageButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        selectImageButton.backgroundColor = .systemBlue
        selectImageButton.setTitleColor(.white, for: .normal)
        selectImageButton.layer.cornerRadius = 8
        selectImageButton.addTarget(self, action: #selector(showImagePicker), for: .touchUpInside)
        view.addSubview(selectImageButton)
        
        // 创建识别按钮
        startRecognitionButton = UIButton(type: .system)
        startRecognitionButton.setTitle("开始识别", for: .normal)
        startRecognitionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        startRecognitionButton.backgroundColor = .systemGreen
        startRecognitionButton.setTitleColor(.white, for: .normal)
        startRecognitionButton.layer.cornerRadius = 8
        startRecognitionButton.addTarget(self, action: #selector(recognizeButtonTapped), for: .touchUpInside)
        startRecognitionButton.isHidden = true
        view.addSubview(startRecognitionButton)
        
        // 创建清除按钮
        clearButton = UIButton(type: .system)
        clearButton.setTitle("清除", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        clearButton.backgroundColor = .systemRed
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.layer.cornerRadius = 8
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        clearButton.isHidden = true
        view.addSubview(clearButton)
        
        // 创建活动指示器
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .systemBlue
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        view.addSubview(resultTextView)
        
        // 创建复制按钮
        copyButton = UIButton(type: .system)
        copyButton.setTitle("复制", for: .normal)
        copyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        copyButton.backgroundColor = .systemBlue
        copyButton.setTitleColor(.white, for: .normal)
        copyButton.layer.cornerRadius = 8
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        copyButton.isHidden = true
        view.addSubview(copyButton)
        
        // 使用SnapKit进行约束设置
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.left.right.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        selectImageButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo((view.bounds.width - 60) / 3)
            make.height.equalTo(44)
        }
        
        startRecognitionButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.left.equalTo(selectImageButton.snp.right).offset(10)
            make.width.equalTo((view.bounds.width - 60) / 3)
            make.height.equalTo(44)
        }
        
        clearButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.left.equalTo(startRecognitionButton.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        
        copyButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.left.equalTo(clearButton.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        
        resultTextView.snp.makeConstraints { make in
            make.top.equalTo(selectImageButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-70)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(resultTextView)
        }
    }
    
    // MARK: - 绑定设置
    
    private func setupBindings() {
        // 选择图片按钮点击事件
        selectImageButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showImagePicker()
            })
            .disposed(by: disposeBag)
        
        // 开始识别按钮点击事件
        startRecognitionButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let image = self?.selectedImage else { return }
                self?.recognizeText(in: image)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 设置操作
    
    private func setupActions() {
        selectImageButton.addTarget(self, action: #selector(showImagePicker), for: .touchUpInside)
        startRecognitionButton.addTarget(self, action: #selector(recognizeButtonTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - 私有方法
    
    /// 显示图片选择器
    @objc private func showImagePicker() {
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
            
            DispatchQueue.main.async {
                // 保存并显示选中的图片
                self.selectedImage = selectedPhoto
                self.imageView.image = selectedPhoto
                self.resultTextView.text = "正在识别..."
            }
        }
        
        // 显示图片选择器
        present(picker, animated: true)
    }
    
    /// 开始识别按钮点击事件
    @objc private func recognizeButtonTapped() {
        guard let image = selectedImage else {
            showToast(message: "请先选择一张图片")
            return
        }
        recognizeText(in: image)
    }
    
    /// 识别图片中的文字
    private func recognizeText(in image: UIImage) {
        // 开始活动指示器
        activityIndicator.startAnimating()
        
        // 清空之前的结果
        resultTextView.text = "正在识别..."
        resultTextView.textColor = .label
        
        // 隐藏复制按钮，识别完成后再显示
        copyButton.isHidden = true
        
        // 转换图片为CIImage
        guard let ciImage = CIImage(image: image) else {
            DispatchQueue.main.async { [weak self] in
                self?.resultTextView.text = "无法处理所选图片"
                self?.activityIndicator.stopAnimating()
            }
            return
        }
        
        // 创建文本识别请求
        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            guard let self = self else { return }
            
            // 确保在主线程更新UI
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    self.resultTextView.text = "识别错误: \(error.localizedDescription)"
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
                    self.resultTextView.text = "未能识别出文字"
                    return
                }
                
                // 提取识别到的文字
                let recognizedTexts = observations.compactMap { observation in
                    // 获取可信度最高的候选文本
                    return observation.topCandidates(1).first?.string
                }.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                
                // 显示结果
                if recognizedTexts.isEmpty {
                    self.resultTextView.text = "未能识别出文字"
                } else {
                    let resultText = recognizedTexts.joined(separator: "\n")
                    
                    // 设置识别结果文本
                    self.resultTextView.text = resultText
                    self.resultTextView.textColor = .label
                    
                    // 显示复制按钮
                    self.copyButton.isHidden = false
                    
                    // 自动滚动到顶部
                    self.resultTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
                    
                    // 显示成功提示
                    self.showToast(message: "识别完成")
                }
            }
        }
        
        // 设置识别语言（支持中文和英文）
        request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en-US"]
        request.recognitionLevel = .accurate
        
        // 设置识别相关参数，提高识别率
        request.customWords = ["ToolBox"] // 添加自定义词汇，提高特定词汇的识别率
        request.usesLanguageCorrection = true // 使用语言纠正，提高识别准确性
        
        // 创建处理请求的处理器
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        // 执行请求
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.resultTextView.text = "识别处理失败: \(error.localizedDescription)"
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    // 复制按钮点击事件
    @objc private func copyButtonTapped() {
        guard let textToCopy = resultTextView.text, !textToCopy.isEmpty,
              textToCopy != "识别结果将在这里显示..." && textToCopy != "正在识别..." && 
              !textToCopy.contains("未能识别出文字") && !textToCopy.contains("识别错误") else {
            showToast(message: "没有可复制的文本")
            return
        }
        
        UIPasteboard.general.string = textToCopy
        showToast(message: "已复制到剪贴板")
    }
    
    // 清除按钮点击事件
    @objc private func clearButtonTapped() {
        selectedImage = nil
        imageView.image = nil
        resultTextView.text = "识别结果将在这里显示..."
        resultTextView.textColor = .secondaryLabel
        startRecognitionButton.isHidden = true
        clearButton.isHidden = true
        copyButton.isHidden = true
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
        toastLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().inset(40)
            make.height.greaterThanOrEqualTo(40)
        }
        
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
