//
//  AIToolPhotoHeadView.swift
//  toolBox
//
//  Created by wang on 2025/3/26.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit

class AIToolPhotoHeadView: UICollectionReusableView {
    // 重用标识符
    static let reuseIdentifier = "AIToolPhotoHeadView"
    var onTapHandler: (() -> Void)?

    @IBOutlet weak var aiPhotoCell: UICollectionView!
    let photoArr = ["67d0df86d2bd583","67d7e60b8b60b58","67d34f678368356","67d18594329b934","67dbb71b6120860"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // 设置透明背景，以便显示底层的渐变背景
        self.backgroundColor = .clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerViewTapped))
        self.addGestureRecognizer(tapGesture)
        setupCollectionView()
    }
    
    @objc private func headerViewTapped() {
        onTapHandler?()
    }
    
    private func setupCollectionView() {
        // 设置透明背景
        aiPhotoCell.backgroundColor = .clear
        
        // 确保有delegate和dataSource
        aiPhotoCell.delegate = self
        aiPhotoCell.dataSource = self
        
        // 创建集合视图Cell
        let cellNib = UINib(nibName: AIToolPhotoCell.reuseIdentifier, bundle: nil)
        aiPhotoCell.register(cellNib, forCellWithReuseIdentifier: AIToolPhotoCell.reuseIdentifier)
        
        // 调整布局以确保正确显示
        if let layout = aiPhotoCell.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 15
            layout.minimumInteritemSpacing = 15
            layout.itemSize = CGSize(width: 80, height: 80)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
        
        // 刷新数据
        aiPhotoCell.reloadData()
        
        print("AIToolPhotoHeadView 已设置，photoArr.count = \(photoArr.count)")
    }
}


// MARK: - uicollectionViewDelegate

extension AIToolPhotoHeadView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AIToolPhotoCell.reuseIdentifier,
            for: indexPath
        ) as? AIToolPhotoCell else {
            fatalError("无法创建AIToolPhotoCell")
        }
        
        // 配置单元格
        if indexPath.item < photoArr.count {
            let imgStr = photoArr[indexPath.item]
            // 从正确的路径加载图片
            if let image = UIImage(named: "AI/\(imgStr)") ?? UIImage(named: imgStr) {
                cell.photoImg.image = image
            } else {
                cell.photoImg.image = UIImage(named: "67d0df86d2bd583") // 使用默认图片
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("返回照片数量: \(photoArr.count)")
        return photoArr.count
    }
}



// MARK: - SDCycleScrollViewDelegate

extension AIToolPhotoHeadView: SDCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didScrollTo index: Int) {
     
    }
    
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        // 点击图片时的操作，可以添加全屏预览等功能
    }
}

