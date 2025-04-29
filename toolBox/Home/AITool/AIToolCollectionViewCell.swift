//
//  AIToolCollectionViewCell.swift
//  toolBox
//
//  Created by wang on 2025/3/26.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit
import SDWebImage
import SDCycleScrollView

class AIToolCollectionViewCell: UICollectionReusableView {
    // 重用标识符
    static let reuseIdentifier = "AIToolCollectionViewCell"

    @IBOutlet weak var aiPhotoCell: UICollectionView!
    let photoArr = ["67d0df86d2bd583","67d7e60b8b60b58","67d34f678368356","67d18594329b934","67dbb71b6120860"]
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        aiPhotoCell.delegate = self
        aiPhotoCell.dataSource = self
        // 创建集合视图
        let cellNib = UINib(nibName: AIToolPhotoCell.reuseIdentifier, bundle: nil)
        aiPhotoCell.register(cellNib, forCellWithReuseIdentifier: AIToolPhotoCell.reuseIdentifier)
        aiPhotoCell.reloadData()
    }

}

// MARK: - uicollectionViewDelegate

extension AIToolCollectionViewCell: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AIToolPhotoCell.reuseIdentifier,
            for: indexPath
        ) as? AIToolPhotoCell else {
            fatalError("无法创建ListItemCollectionViewCell")
        }
        
        // 配置单元格
        if indexPath.item < photoArr.count {
            let imgStr = photoArr[indexPath.item]
            cell.photoImg.image = .init(named: imgStr)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photoArr.count
    }
    
    
}



// MARK: - SDCycleScrollViewDelegate

extension AIToolCollectionViewCell: SDCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didScrollTo index: Int) {
     
    }
    
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        // 点击图片时的操作，可以添加全屏预览等功能
    }
}
