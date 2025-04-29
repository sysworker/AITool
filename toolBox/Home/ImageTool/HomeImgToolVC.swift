//
//  HomeImgToolVC.swift
//  toolBox
//
//  Created by wang on 2025/3/24.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit

class HomeImgToolVC: BaseViewController {
   
    // MARK: - 模型
    
    /// 图像工具模型
    struct ImageTool {
        let title: String
        let description: String
        let viewController: UIViewController.Type
        let viewTag : Int
        init(title: String, description: String, viewController: UIViewController.Type, viewTag : Int) {
            self.title = title
            self.description = description
            self.viewController = viewController
            self.viewTag = viewTag
        }
    }
    
    // MARK: - 属性
    
    private var tools: [ImageTool] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(ImageToolCell.self, forCellReuseIdentifier: ImageToolCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .singleLine
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        setupUI()
    }
    
    // MARK: - 设置方法
    
    private func setupUI() {
        navTitleLabel.text = "图像工具"
        view.backgroundColor = .systemBackground
        
        // 添加表格视图
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupData() {
        tools = [
            ImageTool(title: "视图截屏", description: "截取当前界面的内容生成图片",  viewController: DDGViewShot.self, viewTag: 1),
            
            ImageTool(title: "滚动视图截屏",description: "截取滚动视图的完整内容生成长图", viewController: DDGScollViewShot.self, viewTag: 2),
            
//            ImageTool(title: "WebView截屏", description: "截取网页内容生成长图", viewController: UIViewController.self, viewTag: 3), // 暂无实现，预留
            
            ImageTool(title: "图片合成", description: "多张图片合成与在图片上添加水印", viewController: DDGImageCompose.self,viewTag: 4),
            
            ImageTool(title: "图片标记与编辑", description: "添加文字、标签、裁剪和圆角处理", viewController: DDGImageMark.self,viewTag: 5),
            
            ImageTool(title: "图片裁剪", description: "截取图片的任意部分", viewController: DDGShotImageView.self,viewTag: 6),
            
            ImageTool(title: "图片擦除", description: "局部擦除图片内容", viewController: DDGClearImageView.self,viewTag: 7),
            
//            ImageTool(title: "图片滤镜基础", description: "应用怀旧、黑白、岁月等基础滤镜效果", viewController: DDGImageFilter.self,viewTag: 8),
//            
//            ImageTool(title: "图片滤镜高级", description: "调整饱和度、高斯模糊、老电影等高级效果", viewController: DDGSeniorImageFilter.self, viewTag: 9),
        ]
    }
}

// MARK: - 表格视图代理方法
extension HomeImgToolVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tools.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImageToolCell.reuseIdentifier,
            for: indexPath
        ) as? ImageToolCell else {
            return UITableViewCell()
        }
        
        let tool = tools[indexPath.row]
        cell.configure(with: tool)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "选择要使用的图像处理工具"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.row < tools.count else { return }
        
        let tool = tools[indexPath.row]
        
        // 创建并推入对应的视图控制器
        let viewController = tool.viewController.init()
        if let baseVC = viewController as? BaseViewController {
            baseVC.navTitleLabel.text = tool.title
        } else {
            viewController.title = tool.title
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - 自定义单元格
class ImageToolCell: UITableViewCell {
    
    static let reuseIdentifier = "ImageToolCell"
    
    // MARK: - UI组件
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - 初始化
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 设置方法
    
    private func setupUI() {
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - 配置方法
    
    func configure(with tool: HomeImgToolVC.ImageTool) {
        titleLabel.text = tool.title
        descriptionLabel.text = tool.description
        
        // 根据工具类型设置图标
        let iconName: String
        switch tool.title {
        case "视图截屏", "滚动视图截屏", "WebView截屏":
            iconName = "camera.viewfinder"
        case "图片合成":
            iconName = "square.stack"
        case "图片标记与编辑":
            iconName = "pencil.and.outline"
        case "图片裁剪":
            iconName = "crop"
        case "图片擦除":
            iconName = "eraser"
        case "图片滤镜基础", "图片滤镜高级":
            iconName = "camera.filters"
        default:
            iconName = "photo"
        }
        
        if #available(iOS 13.0, *) {
            iconImageView.image = UIImage(systemName: iconName)
        } else {
            // 对于iOS 13以下版本，使用默认图标
            iconImageView.image = UIImage(named: "icon_item_head")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        descriptionLabel.text = nil
        iconImageView.image = nil
    }
}

