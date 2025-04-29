//
//  UserDynamicInfoCell.swift
//  toolBox
//
//  Created by wang on 2025/3/25.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit

class UserDynamicInfoCell: UITableViewCell {
    ///用户头像
    @IBOutlet weak var headImgV: UIImageView!
    ///用户昵称
    @IBOutlet weak var nameLab: UILabel!
    ///用户内容
    @IBOutlet weak var contentLab: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    /// 举报回调闭包
    var reportActionHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // 圆角头像设置
        headImgV.layer.cornerRadius = 25 // 设置为宽度/高度的一半
        headImgV.layer.masksToBounds = true
        headImgV.contentMode = .scaleAspectFill
    
        bgView.layer.cornerRadius  = 12
        bgView.layer.masksToBounds = true
        
        // 视图背景透明
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    ///点击举报
    @IBAction func reportAction(_ sender: UIButton) {
        reportActionHandler?()
    }
}
