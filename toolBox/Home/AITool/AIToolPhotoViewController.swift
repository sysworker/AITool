//
//  AIToolPhotoViewController.swift
//  toolBox
//
//  Created by wang on 2025/3/26.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit
import TZImagePickerController
import SVProgressHUD

class AIToolPhotoViewController: BaseViewController {
     @IBOutlet weak private var bottomImageView: UIImageView!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "AIToolPhotoViewController", bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func initUI() {
        navView.isHidden = true
    }
    
    
    
    @IBAction func backAction(_ sender: Any) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    ///AI
    @IBAction func toucchAIPhotoAction(_ sender: Any) {
        let picker = TZImagePickerController(maxImagesCount: 1, delegate: nil)!
        picker.didFinishPickingPhotosHandle = { [weak self] (photos, _, _) in
            guard let self = self, let selectedPhoto = photos?.first else { return }
            
            DispatchQueue.main.async {
                // 设置底部图片
                self.bottomImageView.image = selectedPhoto
            }
        }
        
        // 配置选择器界面
        picker.allowPickingVideo = false
        picker.allowPickingGif = false
        picker.allowTakePicture = true
        picker.showSelectedIndex = true
        picker.allowPickingOriginalPhoto = true
        
        present(picker, animated: true)
    }
    
    
    @IBAction func touchAction(_ sender: Any) {
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) { [weak self] in
            guard let _ = self else { return }
            // 显示成功提示
            SVProgressHUD.showSuccess(withStatus: "等待生成，稍后在消息中心查看")

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
