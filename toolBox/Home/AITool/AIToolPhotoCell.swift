//
//  AIToolPhotoCell.swift
//  toolBox
//
//  Created by wang on 2025/3/26.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit

class AIToolPhotoCell: UICollectionViewCell {
    // 重用标识符
    static let reuseIdentifier = "AIToolPhotoCell"

    @IBOutlet weak var photoImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImg.layer.cornerRadius = 40
        photoImg.layer.masksToBounds = true
        photoImg.layer.borderWidth = 3.5
        photoImg.layer.borderColor = UIColor.hex(hexString: "0xFFFFFF", alpha: 0.6).cgColor
    }

}
