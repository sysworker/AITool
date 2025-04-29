//
//  LocalServiceView.swift
//  toolBox
//
//  Created by wang on 2025/3/24.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit
import SDCycleScrollView

class LocalServiceView: UIView {
    
    // 图片轮播视图
    private lazy var cycleScrollView: SDCycleScrollView = {
        let scrollView = SDCycleScrollView(frame: .zero, imageNamesGroup: nil)!
        scrollView.backgroundColor = .black
        scrollView.delegate = self
        scrollView.showPageControl = false
        scrollView.currentPageDotColor = .systemBlue
        scrollView.pageDotColor = .lightGray
        scrollView.titleLabelTextColor = .white
        scrollView.titleLabelTextFont = .systemFont(ofSize: 16)
        scrollView.autoScrollTimeInterval = 2.6
        scrollView.layer.cornerRadius = 12
        scrollView.layer.masksToBounds = true
        return scrollView
    }()
    
    ///标题
    private var titleStr: [String] = []
    ///banner
    private var bannerUrls: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func contentUI()  {
        
        self.backgroundColor = .clear
        cycleScrollView.backgroundColor = .yellow
        addSubview(cycleScrollView)
        cycleScrollView.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.top.bottom.equalToSuperview()
        }
        
        loadBannerURLs()
    }
    
    // 加载头像URL数组
    private func loadBannerURLs() {
        if let path = Bundle.main.path(forResource: "DynamicBanner", ofType: "plist"),
           let urlArray = NSArray(contentsOfFile: path) as? [String] {
            bannerUrls = urlArray
        }
        
        if let path = Bundle.main.path(forResource: "DynamicTitle", ofType: "plist"),
           let urlArray = NSArray(contentsOfFile: path) as? [String] {
            titleStr = urlArray
        }
     
        cycleScrollView.imageURLStringsGroup = bannerUrls
        cycleScrollView.titlesGroup = titleStr
    }
}


// MARK: - SDCycleScrollViewDelegate

extension LocalServiceView: SDCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didScrollTo index: Int) {
    }
    
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        // 点击图片时的操作，可以添加全屏预览等功能
    }
}
