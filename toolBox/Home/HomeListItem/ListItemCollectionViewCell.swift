//
//  ListItemCollectionViewCell.swift
//  toolBox
//
//  Created by wang on 2025/3/24.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit

class ListItemCollectionViewCell: UICollectionViewCell {
    ///图片
    @IBOutlet weak var iconImgV: UIImageView!
    ///标题
    @IBOutlet weak var titleStr: UILabel!
    ///描述
    @IBOutlet weak var contentStr: UILabel!
    
    // 重用标识符
    static let reuseIdentifier = "ListItemCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 重置状态，避免复用问题
        iconImgV.image = nil
        titleStr.text = nil
        contentStr.text = nil
    }
    
    // MARK: - UI设置
    private func setupUI() {
        // 设置卡片样式
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        // 设置阴影效果
        layer.shadowColor = UIColor.black.withAlphaComponent(0.7).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
        
        // 设置图片圆角
        iconImgV.layer.cornerRadius = 4
        iconImgV.layer.masksToBounds = true
        iconImgV.contentMode = .scaleAspectFill
        
        // 设置标题样式
        titleStr.textColor = .black
        titleStr.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        
        // 设置描述样式
        contentStr.textColor = UIColor.hex(hexString: "#8C8C8C")
        contentStr.font = UIFont.systemFont(ofSize: 14)
        contentStr.numberOfLines = 2
    }
    
    // MARK: - 公共方法
    /// 配置单元格
    func configure(with model: ToolItemModel) {
        // 加载图片（支持缓存和SF Symbol）
        if model.isSystemIcon {
            // 使用SF Symbol
            if #available(iOS 13.0, *) {
                iconImgV.image = UIImage(systemName: model.iconImg)?.withRenderingMode(.alwaysTemplate)
                iconImgV.tintColor = .systemBlue
            } else {
                // iOS 13以下不支持SF Symbol，使用默认图标
                iconImgV.image = UIImage(named: "icon_item_head")
            }
        } else if let image = UIImage(named: model.iconImg) {
            // 使用命名图片
            iconImgV.image = image
        } else {
            // 设置默认图片
            iconImgV.image = UIImage(named: "icon_item_head")
        }
        
        // 设置文本内容
        titleStr.text = model.itemTitleStr
        contentStr.text = model.descriptionStr
        
        // 高亮VIP工具
        if model.needVIP {
            titleStr.textColor = UIColor.hex(hexString: "#EE7200")  // 使用橙色标识VIP工具
        } else {
            titleStr.textColor = .black
        }
    }
}
