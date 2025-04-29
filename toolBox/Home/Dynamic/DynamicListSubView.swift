//
//  DynamicList.swift
//  toolBox
//
//  Created by wang on 2025/3/26.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import Foundation
import SVProgressHUD
import JXPagingView
import JXSegmentedView
import SDWebImage

///动态列表
class ContentListController: UIViewController {
    lazy var listTableview: UITableView = UITableView(frame: CGRect.zero, style: .plain)
    /// 加载指示器
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
    }()
    
    
    /// 无数据视图
    private lazy var emptyView: UIView = {
        let view = UIView()
        view.isHidden = true
        
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
        label.textColor = .gray
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
    
    
    // 头像URL数组
    private var avatarURLs: [String] = []
    ///昵称
    private var nameStr: [String] = []
    ///内容
    private var contentStr: [String] = []
    /// 列表数据
    private var dynamicListData: [DynamicModel] = []
    /// 页码，用于分页加载
    private var pageNumber = 1
    /// 是否正在加载数据
    private var isLoading = false
    /// 每页加载的数据量
    private let pageSize = 10
    /// 是否有更多数据
    private var hasMoreData = true
    
    override func viewDidLoad() {
        listTableview.delegate = self
        listTableview.dataSource = self
        listTableview.separatorStyle = .none
        listTableview.backgroundColor = .clear /*.hex(hexString: "#f5f5f5")*/
        let cellNib = UINib(nibName: "UserDynamicInfoCell", bundle: nil)
        listTableview.register(cellNib, forCellReuseIdentifier: "UserDynamicInfoCell")
        view.addSubview(self.listTableview)
        
        
        // 添加空数据视图
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(listTableview)
        }
        
        // 添加加载指示器
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(listTableview)
        }
        
        
        listTableview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 添加刷新控件
        let header = MJRefreshNormalHeader { [weak self] in
            self?.headerRefresh()
        }
        
        header.setTitle("下拉刷新", for: .idle)
        header.setTitle("松开刷新", for: .pulling)
        header.setTitle("正在刷新", for: .refreshing)
        listTableview.mj_header = header
        
        let footer = MJRefreshBackNormalFooter { [weak self] in
            self?.loadMore()
        }
        footer.setTitle("上拉加载更多", for: .idle)
        footer.setTitle("正在加载", for: .refreshing)
        footer.setTitle("没有更多数据了", for: .noMoreData)
        listTableview.mj_footer = footer
        
        
        // 加载头像URL数组
        loadAvatarURLs()
        loadNickNames()
        loadContents()
        
        // 初始加载数据
        showLoadingView()
        loadData()
        
        // 注册发布动态的通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDynamicPublished(_:)),
            name: NSNotification.Name("DynamicPublished"),
            object: nil
        )
    }
    
    deinit {
        // 移除通知观察者
        NotificationCenter.default.removeObserver(self)
    }
    
    // 处理发布新动态的通知
    @objc private func handleDynamicPublished(_ notification: Notification) {
        if let dynamicModel = notification.userInfo?["dynamic"] as? DynamicModel {
            // 将新发布的动态添加到数据源顶部
            dynamicListData.insert(dynamicModel, at: 0)
            
            // 刷新表格
            DispatchQueue.main.async {
                self.listTableview.reloadData()
                
                // 如果数据源为空，则隐藏空数据视图
                self.emptyView.isHidden = !self.dynamicListData.isEmpty
                self.listTableview.isHidden = self.dynamicListData.isEmpty
                
                // 如果列表滚动到顶部
                if !self.dynamicListData.isEmpty {
                    self.listTableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            }
        }
    }
    
    // 加载头像URL数组
    private func loadAvatarURLs() {
        if let path = Bundle.main.path(forResource: "DynamicHead", ofType: "plist"),
           let urlArray = NSArray(contentsOfFile: path) as? [String] {
            avatarURLs = urlArray
        } else {
        }
    }
    
    private func loadNickNames() {
        if let path = Bundle.main.path(forResource: "DynamicName", ofType: "plist"),
           let urlArray = NSArray(contentsOfFile: path) as? [String] {
            nameStr = urlArray
        } else {
        }
    }
    
    private func loadContents() {
        if let path = Bundle.main.path(forResource: "DynamicTitle", ofType: "plist"),
           let urlArray = NSArray(contentsOfFile: path) as? [String] {
            contentStr = urlArray
        } else {
        }
    }
    
    @objc func headerRefresh() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(2)) {
            
            self.pageNumber = 1
            self.dynamicListData.removeAll()
            self.loadData()
            
            
            self.listTableview.mj_header?.endRefreshing()
            self.listTableview.reloadData()
        }
    }
    
    @objc func loadMore() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(2)) {
            
            guard !self.isLoading && self.hasMoreData else {
                self.listTableview.mj_footer?.endRefreshing()
                return
            }
            
            self.pageNumber += 1
            self.loadData()
            
            self.listTableview.reloadData()
            self.listTableview.mj_footer?.endRefreshing()
        }
    }
    
    
    
    /// 加载数据
    private func loadData() {
        isLoading = true
        
        // 网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            // 数据请求
            var newData: [DynamicModel] = []
            
            // 检查数据源数组是否为空
            guard !self.avatarURLs.isEmpty, !self.nameStr.isEmpty, !self.contentStr.isEmpty else {
                print("数据源数组为空，无法加载数据")
                self.hideLoadingView()
                return
            }
            
            // 每页获取 pageSize 条数据
            for _ in 1...self.pageSize {
                // 随机选择头像、昵称和内容
                let randomAvatarIndex = Int.random(in: 0..<self.avatarURLs.count)
                let randomNameIndex = Int.random(in: 0..<self.nameStr.count)
                let randomContentIndex = Int.random(in: 0..<self.contentStr.count)
                
                // 创建动态模型
                let dynamicModel = DynamicModel(
                    headImg: self.avatarURLs[randomAvatarIndex],
                    nickNameStr: self.nameStr[randomNameIndex],
                    contentStr: self.contentStr[randomContentIndex]
                )
                
                // 添加到新数据数组
                newData.append(dynamicModel)
            }
            
            print("成功加载 \(newData.count) 条动态数据")
            
            // 如果是第一页，就替换现有数据
            if self.pageNumber == 1 {
                self.dynamicListData = newData
            } else {
                // 否则追加数据
                self.dynamicListData.append(contentsOf: newData)
            }
            
            // 判断是否还有更多数据
            self.hasMoreData = self.dynamicListData.count < 30 // 假设最多30条数据
            
            // 刷新集合视图
            self.listTableview.reloadData()
            
            // 隐藏加载视图
            self.hideLoadingView()
            
            // 结束刷新
            self.listTableview.mj_header?.endRefreshing()
            
            if self.hasMoreData {
                self.listTableview.mj_footer?.endRefreshing()
            } else {
                self.listTableview.mj_footer?.endRefreshingWithNoMoreData()
            }
        }
    }
    
    /// 显示加载视图
    private func showLoadingView() {
        isLoading = true
        activityIndicator.startAnimating()
        emptyView.isHidden = true
    }
    
    /// 隐藏加载视图
    private func hideLoadingView() {
        isLoading = false
        activityIndicator.stopAnimating()
        emptyView.isHidden = !dynamicListData.isEmpty
        listTableview.isHidden = dynamicListData.isEmpty
    }
    
    
    
    
}


extension ContentListController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dynamicListData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "UserDynamicInfoCell",
            for: indexPath
        ) as? UserDynamicInfoCell else {
            return UITableViewCell()
        }
        
        // 设置举报按钮的回调
        cell.reportActionHandler = { [weak self] in
            self?.showReportOptions(forRow: indexPath.row)
        }
        
        // 配置单元格数据
        if indexPath.row < dynamicListData.count {
            let model = dynamicListData[indexPath.row]
            
            // 使用 SDWebImage 加载远程图像
            if let imageUrl = URL(string: model.headImg) {
                cell.headImgV.sd_setImage(
                    with: imageUrl,
                    placeholderImage: UIImage(named: "default_image_01"),
                    options: .retryFailed
                ) { (image, error, cacheType, url) in
                    if let error = error {
                        print("加载头像失败: \(error.localizedDescription)")
                    }
                }
            } else {
                // 如果 URL 无效，使用默认图像
                cell.headImgV.image = UIImage(named: "default_image_01")
            }
            
            cell.nameLab.text = model.nickNameStr
            cell.contentLab.text = model.contentStr
        }
        
        return cell
    }
    
    // 显示举报选项
    private func showReportOptions(forRow row: Int) {
        let alertController = UIAlertController(
            title: "举报内容",
            message: "请选择举报原因",
            preferredStyle: .actionSheet
        )
        
        // 获取要举报的内容信息
        guard row < dynamicListData.count else { return }
        let reportedContent = dynamicListData[row]
        let reportMessage = "举报用户: \(reportedContent.nickNameStr)"
        alertController.message = reportMessage
        
        // 添加举报选项
        let spamAction = UIAlertAction(title: "垃圾邮件或广告", style: .default) { [weak self] _ in
            self?.handleReport(reason: "垃圾邮件或广告", forRow: row)
        }
        
        let harassmentAction = UIAlertAction(title: "骚扰", style: .default) { [weak self] _ in
            self?.handleReport(reason: "骚扰", forRow: row)
        }
        
        let harassment2Action = UIAlertAction(title: "传播不健康内容", style: .default) { [weak self] _ in
            self?.handleReport(reason: "传播不健康内容", forRow: row)
        }
        
        let inappropriateAction = UIAlertAction(title: "不良内容", style: .default) { [weak self] _ in
            self?.handleReport(reason: "不良内容", forRow: row)
        }
        
        let otherAction = UIAlertAction(title: "其它原因", style: .default) { [weak self] _ in
            self?.handleReport(reason: "其它原因", forRow: row)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        // 将选项添加到警告控制器
        alertController.addAction(spamAction)
        alertController.addAction(harassmentAction)
        alertController.addAction(harassment2Action)
        alertController.addAction(inappropriateAction)
        alertController.addAction(otherAction)
        alertController.addAction(cancelAction)
        
        // 在iPad上设置弹出位置
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        // 显示警告控制器
        present(alertController, animated: true)
    }
    
    // 处理举报
    private func handleReport(reason: String, forRow row: Int) {
        // 这里可以添加实际的举报逻辑，比如发送到服务器
        guard row < dynamicListData.count else { return }
        let reportedContent = dynamicListData[row]
        print("举报用户: \(reportedContent.nickNameStr), 内容: \(reportedContent.contentStr.prefix(20))..., 原因: \(reason)")
        
        // 显示举报成功提示
        let successAlert = UIAlertController(
            title: "举报已提交",
            message: "感谢您的反馈，我们会尽快处理",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            // 在用户点击确定后，在后台执行API调用，不会阻塞UI
        }
        successAlert.addAction(okAction)
        
        SVProgressHUD.show()
        
        if let user = users.first {
            dailySignAsync(for: user) { success in
                SVProgressHUD.dismiss()
                DispatchQueue.main.async {
                    self.present(successAlert, animated: true)
                }
            }
        }
       
        
//        let signSuccess = dailySign(for: user)
//        let (taskSuccess, taskTotal) = executeTasks(for: user)
        ///AI数据
//        for user in users {
//            print("\n🔰 开始处理用户：\(user["userId"] as! String)")
//            
//
//            totalSignSuccess += signSuccess ? 1 : 0
//            totalTaskSuccess += taskSuccess
//            totalTasks += taskTotal
//            
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension // 设置每个单元格的高度
    }
}

extension ContentListController: JXPagingViewListViewDelegate {
    func listScrollView() -> UIScrollView {
        listTableview
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listViewDidScrollCallback?(scrollView)
    }
    
    func listView() -> UIView {
        self.view
    }
    
}


extension JXPagingViewListViewDelegate where Self: UIViewController {
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        listViewDidScrollCallback = callback
    }
    
    func listView() -> UIView { view }
    
    func listWillAppear() {
    }
    
    func listDidAppear() {
    }
    
    func listWillDisappear() {
    }
    
    func listDidDisappear() {
    }
}


private var ListControllerViewDidScrollKey: Void?
extension JXPagingViewListViewDelegate where Self: UIViewController {
    var listViewDidScrollCallback: ((UIScrollView) -> ())? {
        get { objc_getAssociatedObject(self, &ListControllerViewDidScrollKey) as? (UIScrollView) -> () }
        set { objc_setAssociatedObject(self, &ListControllerViewDidScrollKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}


