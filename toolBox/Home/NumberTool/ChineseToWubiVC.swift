//
//  ChineseToWubiVC.swift
//  toolBox
//
//  Created by wang on 2025/4/5.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ChineseToWubiVC: BaseViewController {
    
    // MARK: - 属性
    
    private let disposeBag = DisposeBag()
    
    // 输入框
    private lazy var inputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.secondarySystemBackground
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.placeholder = "请输入要转换的中文..."
        return textView
    }()
    
    // 结果文本框
    private lazy var resultTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.secondarySystemBackground
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.isEditable = false
        textView.text = "转换结果将在这里显示..."
        textView.textColor = .secondaryLabel
        return textView
    }()
    
    // 转换为五笔按钮
    private lazy var convertToWubiButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("转换为五笔", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // 转换为拼音按钮
    private lazy var convertToPinyinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("转换为拼音", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // 复制按钮
    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("复制结果", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
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
        return button
    }()
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initUI() {
        super.initUI()
        setupUI()
        setupBindings()
    }
    
    // MARK: - UI设置
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 添加说明标签
        let titleLabel = UILabel()
        titleLabel.text = "中文转五笔/拼音"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        view.addSubview(titleLabel)
        
        // 创建说明标签
        let descriptionLabel = UILabel()
        descriptionLabel.text = "输入中文文字，转换为对应的五笔码或拼音"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        view.addSubview(descriptionLabel)
        
        // 添加输入框
        view.addSubview(inputTextView)
        
        // 添加按钮
        view.addSubview(convertToWubiButton)
        view.addSubview(convertToPinyinButton)
        view.addSubview(clearButton)
        
        // 添加结果文本框
        view.addSubview(resultTextView)
        
        // 添加复制按钮
        view.addSubview(copyButton)
        
        // 设置约束
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.left.right.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        
        inputTextView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        convertToWubiButton.snp.makeConstraints { make in
            make.top.equalTo(inputTextView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo((view.bounds.width - 60) / 3)
            make.height.equalTo(44)
        }
        
        convertToPinyinButton.snp.makeConstraints { make in
            make.top.equalTo(inputTextView.snp.bottom).offset(20)
            make.left.equalTo(convertToWubiButton.snp.right).offset(10)
            make.width.equalTo((view.bounds.width - 60) / 3)
            make.height.equalTo(44)
        }
        
        clearButton.snp.makeConstraints { make in
            make.top.equalTo(inputTextView.snp.bottom).offset(20)
            make.left.equalTo(convertToPinyinButton.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        
        resultTextView.snp.makeConstraints { make in
            make.top.equalTo(convertToWubiButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(copyButton.snp.top).offset(-20)
        }
        
        copyButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(44)
        }
    }
    
    // MARK: - 绑定设置
    
    private func setupBindings() {
        // 转换为五笔按钮点击事件
        convertToWubiButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.convertToWubi()
            })
            .disposed(by: disposeBag)
        
        // 转换为拼音按钮点击事件
        convertToPinyinButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.convertToPinyin()
            })
            .disposed(by: disposeBag)
        
        // 复制按钮点击事件
        copyButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.copyResultText()
            })
            .disposed(by: disposeBag)
        
        // 清除按钮点击事件
        clearButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.clearAll()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 私有方法
    
    /// 转换为五笔
    private func convertToWubi() {
        guard let inputText = inputTextView.text, !inputText.isEmpty else {
            showToast(message: "请输入要转换的中文")
            return
        }
        
        // 自己实现的转换为五笔方法
        let wubiText = ChineseTextConverter.convertToWubi(inputText)
        
        // 显示结果
        resultTextView.text = wubiText
        resultTextView.textColor = .label
        
        // 显示复制按钮
        copyButton.isHidden = false
    }
    
    /// 转换为拼音
    private func convertToPinyin() {
        guard let inputText = inputTextView.text, !inputText.isEmpty else {
            showToast(message: "请输入要转换的中文")
            return
        }
        
        // 自己实现的转换为拼音方法
        let pinyinText = ChineseTextConverter.convertToPinyin(inputText)
        
        // 显示结果
        resultTextView.text = pinyinText
        resultTextView.textColor = .label
        
        // 显示复制按钮
        copyButton.isHidden = false
    }
    
    /// 复制结果文本
    private func copyResultText() {
        guard let resultText = resultTextView.text, 
              resultText != "转换结果将在这里显示..." else {
            showToast(message: "没有可复制的内容")
            return
        }
        
        UIPasteboard.general.string = resultText
        showToast(message: "已复制到剪贴板")
    }
    
    /// 清除所有内容
    private func clearAll() {
        inputTextView.text = ""
        resultTextView.text = "转换结果将在这里显示..."
        resultTextView.textColor = .secondaryLabel
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
    
    // MARK: - 本地工具方法
    
    /// 本地转换中文文本为拼音
    private func localConvertToPinyin(_ text: String, separator: String = " ", withTone: Bool = true) -> String {
        // 创建中文字符串引用
        let mutableString = NSMutableString(string: text) as CFMutableString
        
        // 转换为带声调的拼音
        let transform = withTone ? kCFStringTransformMandarinLatin : kCFStringTransformToLatin
        CFStringTransform(mutableString, nil, transform, false)
        
        // 如果不需要声调，去掉声调
        if !withTone {
            CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        }
        
        // 获取转换后的字符串
        var result = mutableString as String
        
        // 替换分隔符
        if separator != " " {
            result = result.replacingOccurrences(of: " ", with: separator)
        }
        
        return result
    }
    
    /// 本地获取中文文本的五笔编码
    private func localConvertToWubi(_ text: String, separator: String = " ") -> String {
        var result = ""
        let dict = localWubiDict()
        
        // 处理每个字符
        for (index, char) in text.enumerated() {
            let charString = String(char)
            if let wubi = dict[charString] {
                if index > 0 {
                    result += separator
                }
                result += wubi
            } else {
                // 如果字典中没有对应的五笔码，则保留原字符
                if index > 0 {
                    result += separator
                }
                result += charString
            }
        }
        
        return result
    }
    
    /// 本地常用汉字的五笔编码词典
    private func localWubiDict() -> [String: String] {
        return [
            "我": "trnt",
            "你": "wvty",
            "他": "wpey",
            "她": "vty",
            "们": "wrt",
            "的": "udi",
            "地": "fayi",
            "在": "dhcy",
            "有": "det",
            "是": "jghm",
            "这": "yvey",
            "那": "mey",
            "个": "wtu",
            "和": "trk",
            "上": "higq",
            "下": "ghi",
            "中": "khk",
            "大": "ddd",
            "小": "iiii",
            "年": "dhk",
            "月": "eee",
            "日": "jjjj",
            "时": "jfk",
            "分": "wvt",
            "秒": "tiy",
            "天": "gdi",
            "来": "gipi",
            "去": "fpi",
            "做": "wtw",
            "学": "ipbf",
            "习": "xyxt",
            "爱": "epdc",
            "家": "pffg",
            "工": "aaa",
            "作": "wtf",
            "生": "tgd",
            "活": "ipk",
            "开": "gkh",
            "关": "uwl",
            "门": "uh",
            "想": "ynt",
            "看": "rhjh",
            "听": "bhv",
            "说": "yiy",
            "写": "twi",
            "读": "ybty",
            "谢": "ydk",
            "对": "ymcy",
            "错": "qyni",
            "好": "vbg",
            "坏": "fwfy",
            "快": "nuk",
            "慢": "nymk",
            "高": "ymk",
            "低": "wxmu",
            "朋": "gey",
            "友": "def",
            "同": "maw",
            "事": "fht",
            "情": "nulk",
            "人": "ww",
            "心": "nyy",
            "明": "jeu",
            "白": "rrrr",
            "黑": "lfoe",
            "红": "xte",
            "绿": "xev",
            "蓝": "amyy",
            "黄": "amgu",
            "水": "iiii",
            "火": "ooo",
            "山": "mmm",
            "电": "jnv",
            "脑": "emeg",
            "手": "rtth",
            "机": "sksy",
            "汉": "idui",
            "字": "bcy",
            "五": "gghg",
            "笔": "tdnt",
            "拼": "rwbn",
            "音": "ukcf",
            "转": "xln",
            "换": "rqky",
            "法": "iyiy",
            "工具": "aasjxx",
            "具": "sjxx",
            "软": "xtdx",
            "件": "wglg"
        ]
    }
} 
