//
//  PhotoPreviewVC.swift
//  toolBox
//
//  Created by wang on 2025/4/5.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import TZImagePickerController
import SDWebImage
import SDCycleScrollView

class PhotoPreviewVC: BaseViewController {
    
    // MARK: - 属性
    
    private let disposeBag = DisposeBag()
    
    // 默认图片数组
    private var previewImages: [UIImage] = []
    
    // 当前选中图片索引
    private var currentIndex: Int = 0
    
    // MARK: - UI组件
    
    // 图片轮播视图
    private lazy var cycleScrollView: SDCycleScrollView = {
        let scrollView = SDCycleScrollView(frame: .zero, imageNamesGroup: nil)!
        scrollView.backgroundColor = .black
        scrollView.delegate = self
        scrollView.showPageControl = true
        scrollView.currentPageDotColor = .systemBlue
        scrollView.pageDotColor = .lightGray
//        scrollView.autoScroll = false // 禁用自动滚动
//        scrollView.infiniteLoop = false // 禁用无限循环
        scrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic
        scrollView.pageControlDotSize = CGSize(width: 8, height: 8)
        scrollView.pageControlBottomOffset = 30
        return scrollView
    }()
    
    // 按钮容器视图
    private lazy var buttonContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()
    
    // 选择照片按钮
    private lazy var selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("选择照片", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        return button
    }()
    
    // 缩略图集合视图
    private lazy var thumbnailCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ThumbnailCell.self, forCellWithReuseIdentifier: "ThumbnailCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDefaultImages()
    }
    
    override func initUI() {
        super.initUI()
        setupUI()
        setupBindings()
    }
    
    // MARK: - 设置UI
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // 添加轮播视图
        view.addSubview(cycleScrollView)
        cycleScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 添加按钮容器视图
        view.addSubview(buttonContainerView)
        buttonContainerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(150)
        }
        
        // 添加选择照片按钮
        buttonContainerView.addSubview(selectPhotoButton)
        selectPhotoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
            make.width.equalTo(150)
            make.height.equalTo(44)
        }
        
        // 添加缩略图集合视图
        buttonContainerView.addSubview(thumbnailCollectionView)
        thumbnailCollectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(selectPhotoButton.snp.top).offset(-20)
            make.height.equalTo(70)
        }
        
        // 设置初始图片
        updateImagePreview()
    }
    
    // MARK: - 设置绑定
    
    private func setupBindings() {
        // 选择照片按钮点击事件
        selectPhotoButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showImagePicker()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 私有方法
    
    /// 加载默认图片
    private func loadDefaultImages() {
        // 加载默认的示例图片
        if let image1 = UIImage(named: "sample_image_1") {
            previewImages.append(image1)
        } else if let image1 = UIImage(systemName: "photo.fill") {
            previewImages.append(image1)
        }
        
        if let image2 = UIImage(named: "sample_image_2") {
            previewImages.append(image2)
        } else if let image2 = UIImage(systemName: "photo.fill.on.rectangle.fill") {
            previewImages.append(image2)
        }
        
        if let image3 = UIImage(named: "sample_image_3") {
            previewImages.append(image3)
        } else if let image3 = UIImage(systemName: "photo.on.rectangle.angled") {
            previewImages.append(image3)
        }
        
        updateImagePreview()
    }
    
    /// 更新图片预览
    private func updateImagePreview() {
        // 设置轮播图片
        cycleScrollView.localizationImageNamesGroup = nil
        cycleScrollView.imageURLStringsGroup = nil
//        cycleScrollView.imageURLsGroup = nil
        
        if !previewImages.isEmpty {
//            cycleScrollView.imageURLsGroup = nil
//            cycleScrollView.imageNamesGroup = nil
//            cycleScrollView.imageGroupCount = previewImages.count
//            cycleScrollView.customImageBlock = 
        }
        
        // 设置当前页
//        if !previewImages.isEmpty && currentIndex < previewImages.count {
//            cycleScrollView.currentIndex = currentIndex
//        }
        
        // 刷新缩略图
        thumbnailCollectionView.reloadData()
        scrollToSelectedThumbnail()
    }
    
    /// 滚动到选中的缩略图
    private func scrollToSelectedThumbnail() {
        if !previewImages.isEmpty && currentIndex < previewImages.count {
            thumbnailCollectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    /// 显示图片选择器
    private func showImagePicker() {
        let picker = TZImagePickerController(maxImagesCount: 9, delegate: nil)!
        picker.didFinishPickingPhotosHandle = { [weak self] (photos, _, _) in
            guard let self = self, let selectedPhotos = photos, !selectedPhotos.isEmpty else { return }
            
            // 添加选中的照片到预览数组
            self.previewImages.append(contentsOf: selectedPhotos)
            
            // 更新当前索引为第一张新添加的照片
            self.currentIndex = self.previewImages.count - selectedPhotos.count
            
            // 更新图片预览
            self.updateImagePreview()
            
            // 显示成功提示
            self.showToast(message: "已添加\(selectedPhotos.count)张新照片")
        }
        
        // 配置选择器界面
        picker.allowPickingVideo = false
        picker.allowPickingGif = false
        picker.allowTakePicture = true
        picker.showSelectedIndex = true
        picker.allowPickingOriginalPhoto = true
        
        present(picker, animated: true)
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

// MARK: - SDCycleScrollViewDelegate

extension PhotoPreviewVC: SDCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didScrollTo index: Int) {
        currentIndex = index
        thumbnailCollectionView.reloadData()
        scrollToSelectedThumbnail()
    }
    
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        // 点击图片时的操作，可以添加全屏预览等功能
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension PhotoPreviewVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return previewImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCell", for: indexPath) as! ThumbnailCell
        
        cell.imageView.image = previewImages[indexPath.item]
        cell.isSelected = indexPath.item == currentIndex
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        currentIndex = indexPath.item
//        cycleScrollView.currentIndex = currentIndex
//        thumbnailCollectionView.reloadData()
//    }
}

// MARK: - 缩略图Cell

class ThumbnailCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    override var isSelected: Bool {
        didSet {
            contentView.layer.borderWidth = isSelected ? 2 : 0
            contentView.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
} 
