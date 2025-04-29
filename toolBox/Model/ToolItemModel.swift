//
//  ToolItemModel.swift
//  toolBox
//
//  Created by wang on 2025/3/24.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit

struct ToolItemModel {
    var iconImg: String
    var itemTitleStr: String
    var descriptionStr: String
    var modelTag: Int
    var needVIP: Bool
    var isSystemIcon: Bool // 标识是否是系统SF Symbol图标
    
    // 添加支持SF Symbol的初始化方法
    init(iconImg: String, itemTitleStr: String, descriptionStr: String, modelTag: Int, needVIP: Bool, isSystemIcon: Bool = false) {
        self.iconImg = iconImg
        self.itemTitleStr = itemTitleStr
        self.descriptionStr = descriptionStr
        self.modelTag = modelTag
        self.needVIP = needVIP
        self.isSystemIcon = isSystemIcon
    }
}

struct DynamicModel {
    var headImg: String
    var nickNameStr: String
    var contentStr: String
      
    init(headImg: String, nickNameStr: String, contentStr: String) {
        self.headImg = headImg
        self.nickNameStr = nickNameStr
        self.contentStr = contentStr
    }
}
