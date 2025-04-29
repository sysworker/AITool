//
//  MyAIAccountViewController.swift
//  toolBox
//
//  Created by wang on 2025/3/28.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit

class MyAIAccountViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// 无数据视图
    private lazy var emptyView: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(named: "icon_no_data"))
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.width.height.equalTo(100)
        }
        
        let label = UILabel()
        label.text = "暂无数据"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        return view
    }()
    
    override func initUI() {
        super.initUI()
        navView.isHidden = false
        /// 背景渐变视图
        view.backgroundColor = .gradientColor(
            with: CGSize(width: screenW, height: screenH),
            direction: .upwardDiagonalLine,
            startColor: .hex(hexString: "#0C7BB3"),
            endColor: .hex(hexString: "#F2BAE8")
        )
        
        // 添加标题
        navTitleLabel.text = "我的帖子"
        navView.backgroundColor = .clear
        
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(200);
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
