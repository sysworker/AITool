import UIKit
import RxSwift
import RxCocoa

class HomeTabbar: UITabBarController {
    
    // 用于管理RxSwift订阅的DisposeBag
    private let disposeBag = DisposeBag()
    
    // 记录之前选中的标签索引
    private var previousSelectedIndex: Int = 0
    
    // 标志变量，表示正在进行登录操作
    private var isHandlingLogin: Bool = false
    
    // 重写 selectedIndex 属性，添加登录检查
    override var selectedIndex: Int {
        didSet {
            // 如果尝试选择第三个标签（索引为2）但用户未登录
            if selectedIndex == 2 && !UserManager.shared.isLoggedIn {
                print("⚠️ 拦截未授权的标签选择：\(selectedIndex)，回退到：\(previousSelectedIndex)")
                // 如果不是在登录过程中，则返回到之前的标签
                if !isHandlingLogin {
                    super.selectedIndex = previousSelectedIndex
                }
            }
        }
    }
    
    // MARK: - 重写点击tab的代理方法
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // 获取点击的索引
        if let index = tabBar.items?.firstIndex(of: item) {
            print("点击了标签: \(index)")
            
            // 如果点击的是第三个标签且用户未登录
            if index == 2 && !UserManager.shared.isLoggedIn && !isHandlingLogin {
                // 不执行默认行为，保持在当前标签
                self.selectedIndex = self.previousSelectedIndex
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置 TabBar 样式
        setupTabBarAppearance()
        
        // 添加两个首页列表控制器
        setupViewControllers()
        
        // 设置标签栏点击事件监听
        setupTabBarSelectedEvents()
        
        // 添加登出通知监听
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserLogout), name: NSNotification.Name("UserDidLogout"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 设置标签栏选择事件
    private func setupTabBarSelectedEvents() {
        // 使用RxCocoa监听标签栏选择事件
        self.rx.didSelect
            .subscribe(onNext: { [weak self] viewController in
                guard let self = self, !self.isHandlingLogin else { return }
                
                // 获取选中的控制器索引
                if let index = self.viewControllers?.firstIndex(of: viewController) {
                    print("选中控制器索引: \(index)")
                    
                    // 如果是第三个标签(我的)且用户未登录
                    if index == 2 && !UserManager.shared.isLoggedIn {
                        // 标记正在处理登录
                        self.isHandlingLogin = true
                        
                        // 显示登录页面
                        if let navController = viewController as? UINavigationController {
                            let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
                            loginVC.hidesBottomBarWhenPushed = true
                            
                            // 设置登录页面的完成回调
                            loginVC.loginCompletionHandler = { [weak self] success in
                                guard let self = self else { return }
                                print("登录回调 - 成功: \(success)")
                                
                                // 完成登录处理，重置标志
                                self.isHandlingLogin = false
                                
                                if success {
                                    // 登录成功，切换到"我的"标签
                                    DispatchQueue.main.async {
                                        self.selectedIndex = 2
                                    }
                                } else {
                                    // 登录失败或取消，确保保持在之前的标签
                                    DispatchQueue.main.async {
                                        self.selectedIndex = self.previousSelectedIndex
                                    }
                                }
                            }
                            
                            // 推出登录控制器
                            navController.pushViewController(loginVC, animated: true)
                        }
                    } else {
                        // 记录当前选中的索引(只有当不是第三个标签或已登录时)
                        self.previousSelectedIndex = index
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 处理用户登出事件
    @objc private func handleUserLogout() {
        // 用户登出后，切换到第一个标签
        // 立即切换到第一个标签，避免用户看到需要登录的内容
        self.selectedIndex = 0
    }
    
    // MARK: - 设置 TabBar 样式
    private func setupTabBarAppearance() {
        
        // 设置 TabBar 高斯模糊效果
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            
            // 配置高斯模糊效果
            appearance.configureWithDefaultBackground() // 使用默认背景而不是不透明背景
            
            // 设置模糊效果
            let blurEffect = UIBlurEffect(style: .regular)
            appearance.backgroundEffect = blurEffect
            
            // 设置轻微的背景色，使模糊效果更加明显
            appearance.backgroundColor = UIColor.white.withAlphaComponent(0.7)
            
            // 添加细微的分割线
            appearance.shadowColor = UIColor.lightGray.withAlphaComponent(0.3)
            
            // 设置选中和未选中的文本颜色
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.hex(hexString: "#989898")
            ]
            let selectedAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.hex(hexString: "#EE7200")
            ]
            
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        } else {
            // 旧版 iOS 的高斯模糊效果实现
            tabBar.barTintColor = UIColor.clear
            tabBar.backgroundColor = UIColor.clear
            tabBar.backgroundImage = UIImage()
            
            // 创建并添加模糊效果视图
            let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = tabBar.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // 确保模糊视图在最底层
            tabBar.insertSubview(blurEffectView, at: 0)
            
            // 设置 TabBar 颜色
            tabBar.tintColor = UIColor.hex(hexString: "#EE7200")
            tabBar.unselectedItemTintColor = UIColor.hex(hexString: "#989898")
        }
        
        // 设置 TabBar 背景颜色
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            
            // 设置选中和未选中的文本颜色
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.hex(hexString: "#dbdbdb")
            ]
            let selectedAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.hex(hexString: "#2c2c2c")
            ]
            
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        } else {
            // 旧版 iOS
            tabBar.barTintColor = .white
            tabBar.tintColor = UIColor.hex(hexString: "#EE7200")
            tabBar.unselectedItemTintColor = UIColor.hex(hexString: "#989898")
        }
    }
    
    // MARK: - 设置视图控制器
    private func setupViewControllers() {
        // 创建两个直播列表控制器
        let discoverListVC = HomeList()
        let dynamicListVC = DynamicList()
        
        var mineVc = BaseViewController()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeMineVC = storyboard.instantiateViewController(withIdentifier: "HomeMine") as? HomeMine {
            mineVc = homeMineVC
        } else {
            mineVc = HomeMine()
        }

        let discoverNavVC = UINavigationController(rootViewController: discoverListVC)
        let followingNavVC = UINavigationController(rootViewController: dynamicListVC)
        let mineNavVC = UINavigationController(rootViewController: mineVc)

        // 设置标题和图标
        discoverNavVC.tabBarItem = UITabBarItem(
            title: "工具",
            image: UIImage(named: "icon_home_tool")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "icon_home_tool_select")?.withRenderingMode(.alwaysOriginal)
        )
        
        followingNavVC.tabBarItem = UITabBarItem(
            title: "交流",
            image: UIImage(named: "icon_home_dynamic")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "icon_home_dynamic_select")?.withRenderingMode(.alwaysOriginal)
        )
        
        mineNavVC.tabBarItem = UITabBarItem(
            title: "我的",
            image: UIImage(named: "icon_home_mine")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "icon_home_mine_select")?.withRenderingMode(.alwaysOriginal)
        )
        
        // 设置视图控制器数组
        viewControllers = [discoverNavVC, followingNavVC, mineNavVC]
        
        // 默认选中第一个
        selectedIndex = 0
        previousSelectedIndex = 0
    }
}





