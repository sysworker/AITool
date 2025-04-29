//
//  AvatarBrowserVC.swift
//  toolBox
//
//  Created by wang on 2024/4/15.
//  Copyright © 2024 ToolBox. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage
import SnapKit
import MJRefresh

class AvatarBrowserVC: BaseViewController {
    
    // MARK: - 属性
    
    private let disposeBag = DisposeBag()
    
    // 头像URL数组
    private var avatarURLs: [String] = []
    
    // 每行显示的头像数量
    private let columnsCount: CGFloat = 3
    
    // MARK: - UI组件
    
    // 集合视图
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (screenW - 40 - (columnsCount - 1) * 10) / columnsCount
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(AvatarCell.self, forCellWithReuseIdentifier: "AvatarCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    // 空视图
    private lazy var emptyView: UIView = {
        let view = UIView()
        view.isHidden = true
        
        let imageView = UIImageView(image: UIImage(systemName: "photo.on.rectangle"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGray
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.height.equalTo(80)
        }
        
        let label = UILabel()
        label.text = "没有找到头像资源"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        
        return view
    }()
    
    // 随机头像按钮
    private lazy var randomAvatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("随机显示", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置导航栏标题
        navTitleLabel.text = "头像浏览"
        
        // 初始化UI
        setupUI()
        
        // 加载头像URL数组
        loadAvatarURLs()
        
        // 设置绑定
        setupBindings()
    }
    
    // MARK: - 初始化UI
    
    private func setupUI() {
        // 添加集合视图
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
        }
        
        // 添加随机头像按钮
        view.addSubview(randomAvatarButton)
        randomAvatarButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        
        // 添加空视图
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(collectionView)
        }
        
        // 添加下拉刷新
        collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.shuffleAvatars()
        })
    }
    
    // MARK: - 设置绑定
    
    private func setupBindings() {
        // 随机头像按钮点击事件
        randomAvatarButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.scrollToRandomAvatar()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 数据方法
    
    // 加载头像URL数组
    private func loadAvatarURLs() {
        if let path = Bundle.main.path(forResource: "DynamicHead", ofType: "plist"),
           let urlArray = NSArray(contentsOfFile: path) as? [String] {
            avatarURLs = urlArray
            print("成功加载 \(avatarURLs.count) 个头像URL")
            
            // 更新UI
            updateUI()
        } else {
            print("加载DynamicHead.plist失败")
            emptyView.isHidden = false
        }
    }
    
    // 更新UI
    private func updateUI() {
        emptyView.isHidden = !avatarURLs.isEmpty
        collectionView.reloadData()
    }
    
    // 随机排序头像
    private func shuffleAvatars() {
        avatarURLs.shuffle()
        collectionView.reloadData()
        collectionView.mj_header?.endRefreshing()
        
        // 显示提示
        showToast(message: "已刷新头像列表")
    }
    
    // 滚动到随机头像
    private func scrollToRandomAvatar() {
        guard !avatarURLs.isEmpty else { return }
        
        // 获取随机索引
        let randomIndex = Int.random(in: 0..<avatarURLs.count)
        let indexPath = IndexPath(item: randomIndex, section: 0)
        
        // 滚动到随机头像
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        
        // 高亮显示随机头像
        highlightCell(at: indexPath)
    }
    
    // 高亮显示单元格
    private func highlightCell(at indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? AvatarCell else { return }
        
        // 创建一个闪烁动画
        let originalBackgroundColor = cell.backgroundColor
        
        UIView.animate(withDuration: 0.2, animations: {
            cell.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
            cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                cell.backgroundColor = originalBackgroundColor
                cell.transform = .identity
            })
        }
    }
    
    // 显示大图预览
    private func showFullScreenPreview(for url: String, at indexPath: IndexPath) {
        let previewVC = AvatarPreviewVC(imageURL: url)
        previewVC.modalPresentationStyle = .fullScreen
        present(previewVC, animated: true)
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

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension AvatarBrowserVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatarURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath) as? AvatarCell,
              indexPath.item < avatarURLs.count else {
            return UICollectionViewCell()
        }
        
        // 配置单元格
        let url = avatarURLs[indexPath.item]
        cell.configure(with: url)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < avatarURLs.count else { return }
        
        // 显示大图预览
        let url = avatarURLs[indexPath.item]
        showFullScreenPreview(for: url, at: indexPath)
    }
}

// MARK: - 头像单元格

class AvatarCell: UICollectionViewCell {
    
    // 头像图片视图
    private let imageView = UIImageView()
    
    // 加载指示器
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 设置圆角和阴影
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        // 添加图片视图
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 添加加载指示器
        activityIndicator.hidesWhenStopped = true
        contentView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 配置单元格
    func configure(with urlString: String) {
        // 开始加载
        activityIndicator.startAnimating()
        
        // 清除之前的图片
        imageView.image = nil
        
        // 加载图片
        imageView.sd_setImage(with: URL(string: urlString)) { [weak self] (_, error, _, _) in
            // 停止加载指示器
            self?.activityIndicator.stopAnimating()
            
            if error != nil {
                // 加载失败时显示占位图
                self?.imageView.image = UIImage(systemName: "photo.fill")
                self?.imageView.tintColor = .lightGray
            }
        }
    }
}

// MARK: - 头像预览视图控制器

class AvatarPreviewVC: UIViewController {
    
    private let imageURL: String
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    init(imageURL: String) {
        self.imageURL = imageURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        // 设置滚动视图
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        // 设置图片视图
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        
        // 添加加载指示器
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        
        // 加载图片
        loadImage()
        
        // 添加关闭按钮
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.frame = CGRect(x: 20, y: 40, width: 30, height: 30)
        
        // 添加保存按钮
        let saveButton = UIButton(type: .system)
        saveButton.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        saveButton.tintColor = .white
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        view.addSubview(saveButton)
        saveButton.frame = CGRect(x: view.bounds.width - 50, y: 40, width: 30, height: 30)
        
        // 添加轻触手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        // 添加双击手势
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
        
        // 单击手势不应该与双击手势冲突
        tapGesture.require(toFail: doubleTapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 调整滚动视图大小
        scrollView.frame = view.bounds
        
        // 调整图片视图大小
        if let image = imageView.image {
            let imageSize = image.size
            let screenSize = view.bounds.size
            
            // 计算适合屏幕的图片大小
            let widthRatio = screenSize.width / imageSize.width
            let heightRatio = screenSize.height / imageSize.height
            let minRatio = min(widthRatio, heightRatio)
            
            let scaledWidth = imageSize.width * minRatio
            let scaledHeight = imageSize.height * minRatio
            
            // 设置图片视图大小
            imageView.frame = CGRect(
                x: (screenSize.width - scaledWidth) / 2,
                y: (screenSize.height - scaledHeight) / 2,
                width: scaledWidth,
                height: scaledHeight
            )
            
            // 设置滚动视图内容大小
            scrollView.contentSize = CGSize(width: scaledWidth, height: scaledHeight)
        }
    }
    
    // 加载图片
    private func loadImage() {
        imageView.sd_setImage(with: URL(string: imageURL)) { [weak self] (image, error, _, _) in
            self?.activityIndicator.stopAnimating()
            
            if let error = error {
                print("加载头像失败: \(error.localizedDescription)")
                self?.showToast(message: "加载头像失败")
                return
            }
            
            self?.viewDidLayoutSubviews()
        }
    }
    
    // 关闭按钮点击事件
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    // 保存按钮点击事件
    @objc private func saveButtonTapped() {
        guard let image = imageView.image else {
            showToast(message: "没有可保存的图片")
            return
        }
        
        // 保存图片到相册
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // 保存图片完成回调
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showToast(message: "保存失败: \(error.localizedDescription)")
        } else {
            showToast(message: "图片已保存到相册")
        }
    }
    
    // 轻触手势处理
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    // 双击手势处理
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            // 如果已经放大，则恢复原始大小
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            // 否则放大到最大比例
            let location = gesture.location(in: imageView)
            let rect = CGRect(
                x: location.x - 50,
                y: location.y - 50,
                width: 100,
                height: 100
            )
            scrollView.zoom(to: rect, animated: true)
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
        toastLabel.frame = CGRect(x: (view.bounds.width - 200) / 2, y: view.bounds.height - 100, width: 200, height: 40)
        
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

// MARK: - UIScrollViewDelegate

extension AvatarPreviewVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // 调整图片位置，确保缩放后图片依然居中
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        
        imageView.center = CGPoint(
            x: scrollView.contentSize.width * 0.5 + offsetX,
            y: scrollView.contentSize.height * 0.5 + offsetY
        )
    }
} 
