//
//  Macro.swift
//  toolBox
//
//  Created by wang on 2025/3/24.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import Foundation
import UIKit

/// 屏幕宽高
let screenW = UIScreen.main.bounds.size.width
let screenH = UIScreen.main.bounds.size.height

var isPhoneX: Bool {
    if #available(iOS 11.0, *) {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0 > 0
    }
    return false
}

/// 状态栏高度
let statusBarHeight: CGFloat = isPhoneX ? 44.0 : 20.0

/// 导航栏高度
let navigationBarHeight: CGFloat = 44.0

/// Tab栏高度
let tabbarHeight: CGFloat = isPhoneX ? 49.0 + 34.0 : 49.0

let bottomMargint : CGFloat = isPhoneX ? 34.0 : 0
/// Tab栏安全底部间距
let tabbarSafeBottomMargin: CGFloat = isPhoneX ? 34.0 : 0.0

/// 状态栏和导航栏总高度
let statusBarAndNavigationBarHeight: CGFloat = isPhoneX ? 88.0 : 64.0

/// 获取应用名称
let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""

// 获取应用版本号
let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

// 获取应用构建版本号
let appBuildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""


@_exported import SnapKit
@_exported import RxSwift
@_exported import RxCocoa
@_exported import RxRelay
@_exported import RxGesture
@_exported import MJRefresh
@_exported import IQKeyboardManagerSwift
@_exported import Reusable
@_exported import BSText
@_exported import Toast_Swift
@_exported import DZNEmptyDataSet
@_exported import UITextView_Placeholder
@_exported import PanModal
@_exported import MJRefresh
@_exported import SDWebImage
@_exported import SDCycleScrollView
