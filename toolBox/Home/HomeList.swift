//
//  HomeList.swift
//  toolBox
//
//

import UIKit

class HomeList: BaseViewController {
    
    // MARK: - 属性
    /// 列表数据
    private var toolListData: [ToolItemModel] = []
    
    /// 页码，用于分页加载
    private var pageNumber = 1
    
    /// 是否正在加载数据
    private var isLoading = false
    
    /// 每页加载的数据量
    private let pageSize = 10
    
    /// 是否有更多数据
    private var hasMoreData = true
    
    // MARK: - UI组件
    /// 顶部背景渐变视图
    private lazy var gradientBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .gradientColor(
            with: CGSize(width: screenW, height: screenH),
            direction: .upwardDiagonalLine,
            startColor: .hex(hexString: "#EF96C5"),
            endColor: .hex(hexString: "#CCFBFF")
        )
        return view
    }()
    
    /// 标题标签
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "工具"
        label.font = .boldSystemFont(ofSize: 33)
        label.textColor = .white
        return label
    }()
    
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
        label.text = "暂无工具数据"
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
    
    /// 集合视图
    private lazy var toolCollectionView: UICollectionView = {
        // 创建布局
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16 // 减少垂直间距
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: screenW, height: 200) // 增加头部高度
        
        // 创建集合视图
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        let cellNib = UINib(nibName: ListItemCollectionViewCell.reuseIdentifier, bundle: nil)
        collection.register(cellNib, forCellWithReuseIdentifier: ListItemCollectionViewCell.reuseIdentifier)
        
        // 使用UINib注册头部视图
        let headerNib = UINib(nibName: AIToolPhotoHeadView.reuseIdentifier, bundle: nil)
        collection.register(headerNib,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: AIToolPhotoHeadView.reuseIdentifier)
        
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        collection.contentInsetAdjustmentBehavior = .never
        
        // 添加刷新控件
        let header = MJRefreshNormalHeader { [weak self] in
            self?.refreshData()
        }
        
        header.setTitle("下拉刷新", for: .idle)
        header.setTitle("松开刷新", for: .pulling)
        header.setTitle("正在刷新", for: .refreshing)
        collection.mj_header = header
        
        let footer = MJRefreshBackNormalFooter { [weak self] in
            self?.loadMoreData()
        }
        footer.setTitle("上拉加载更多", for: .idle)
        footer.setTitle("正在加载", for: .refreshing)
        footer.setTitle("没有更多数据了", for: .noMoreData)
        collection.mj_footer = footer
        
        return collection
    }()
    
    // MARK: - 生命周期方法
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 延迟加载数据，优化启动体验
        showLoadingView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.initialLoadData()
        }
    }
    
    override func initUI() {
        super.initUI()
//        navView.isHidden = true
        
        // 添加渐变背景
        view.addSubview(gradientBackgroundView)
        gradientBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let bgImg = UIImageView(image: .mainBackcx)
        gradientBackgroundView.addSubview(bgImg)
        bgImg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        // 添加标题
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(statusBarHeight + 10)
            make.leading.equalTo(20)
        }
        
        // 添加集合视图
        view.addSubview(toolCollectionView)
        toolCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        // 添加空数据视图
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(toolCollectionView)
        }
        
        // 添加加载指示器
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(toolCollectionView)
        }
        
        
        navView.backgroundColor = .clear
        navLeftBtn.isHidden = true
        navRightBtn.setImage(.init(named: "icon_home_message"), for: .normal)
        navRightBtn.rx.controlEvent(.touchUpInside).bind { [weak self]() in
            let vc = MessageListViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by:disBag)
        // TODO: 消息列表
    }
    
    // MARK: - 数据加载方法
    /// 初始加载数据
    private func initialLoadData() {
        pageNumber = 1
        toolListData.removeAll()
        loadData()
    }
    
    /// 刷新数据
    private func refreshData() {
        pageNumber = 1
        toolListData.removeAll()
        loadData()
    }
    
    /// 加载更多数据
    private func loadMoreData() {
        guard !isLoading && hasMoreData else {
            toolCollectionView.mj_footer?.endRefreshing()
            return
        }
        
//        pageNumber += 1
        loadData()
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
        emptyView.isHidden = !toolListData.isEmpty
        toolCollectionView.isHidden = toolListData.isEmpty
    }
    
    /// 加载数据
    private func loadData() {
        isLoading = true
        
        // 网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            // 数据请求
            var newData: [ToolItemModel] = []
            
//            // 根据页码加载不同数据
//            for i in 1...8 {
//                let itemTag = (self.pageNumber - 1) * 8 + i
//                let model = ToolItemModel(
//                    iconImg: "icon_item_head",
//                    itemTitleStr: "图片工具\(itemTag)",
//                    descriptionStr: "自定义调整用户头像，图片滤镜颜色调整",
//                    modelTag: itemTag,
//                    needVIP: itemTag % 3 == 0  // 每3个一个VIP工具
//                )
//                newData.append(model)
//            }
            

            
            newData.append(ToolItemModel(
                iconImg: "icon_Calculator",
                itemTitleStr: "计算器",
                descriptionStr: "计算器工具，快速进行简单的计算",
                modelTag: 2,
                needVIP: false
            ))
            
            newData.append(ToolItemModel(
                iconImg: "icon_item_S",
                itemTitleStr: "文字识别",
                descriptionStr: "从图片中识别文字，支持中文和英文",
                modelTag: 3,
                needVIP: false,
                isSystemIcon: false
            ))
            //
            newData.append(ToolItemModel(
                iconImg: "icon_item_P",
                itemTitleStr: "中文转五笔",
                descriptionStr: "将中文转换为对应的五笔码或拼音",
                modelTag: 4,
                needVIP: false,
                isSystemIcon: false
            ))
            
            let model = ToolItemModel(
                iconImg: "icon_item_head",
                itemTitleStr: "图片工具",
                descriptionStr: "自定义调整用户头像，图片滤镜颜色调整",
                modelTag: 1,
                needVIP: false  // 每3个一个VIP工具
            )
            newData.append(model)
            newData.append(ToolItemModel(
                iconImg: "photo.on.rectangle",
                itemTitleStr: "相册预览",
                descriptionStr: "查看和预览照片，支持缩放和手势操作",
                modelTag: 5,
                needVIP: false,
                isSystemIcon: true
            ))
            
            newData.append(ToolItemModel(
                iconImg: "scribble",
                itemTitleStr: "图片擦除",
                descriptionStr: "创意图片擦除效果，支持自选底图",
                modelTag: 6,
                needVIP: false,
                isSystemIcon: true
            ))
            
            newData.append(ToolItemModel(
                iconImg: "person.crop.circle",
                itemTitleStr: "头像浏览",
                descriptionStr: "浏览和保存精美头像图片",
                modelTag: 7,
                needVIP: false,
                isSystemIcon: true
            ))
            
            // 如果是第一页，就替换现有数据
            if self.pageNumber == 1 {
                self.toolListData = newData
            } else {
                // 否则追加数据
                self.toolListData.append(contentsOf: newData)
            }
            
            // 判断是否还有更多数据
            self.hasMoreData = self.toolListData.count < 30 // 假设最多30条数据
            
            // 刷新集合视图
            self.toolCollectionView.reloadData()
            
            // 隐藏加载视图
            self.hideLoadingView()
            
            // 结束刷新
            self.toolCollectionView.mj_header?.endRefreshing()
            
            if self.hasMoreData {
                self.toolCollectionView.mj_footer?.endRefreshing()
            } else {
                self.toolCollectionView.mj_footer?.endRefreshingWithNoMoreData()
            }
        }
    }
}

// MARK: - 集合视图代理方法
extension HomeList: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.bounds.size.width, height: 250) // 与 layout.headerReferenceSize 保持一致
    }

    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: AIToolPhotoHeadView.reuseIdentifier,
                                                                             for: indexPath) as! AIToolPhotoHeadView
            // 设置闭包来处理点击事件
            headerView.onTapHandler = { [weak self] in
                // 在这里处理点击事件
                let AIToolVC = AIToolPhotoViewController()
                AIToolVC.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(AIToolVC, animated: true)
            }
                    
            headerView.backgroundColor = .clear  // 设置透明背景以便于调试
            return headerView
        }
        
        return UICollectionReusableView()
    }

    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return toolListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ListItemCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? ListItemCollectionViewCell else {
            fatalError("无法创建ListItemCollectionViewCell")
        }
        
        // 配置单元格
        if indexPath.item < toolListData.count {
            let model = toolListData[indexPath.item]
            cell.configure(with: model)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 获取布局对象
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 150, height: 100) // 默认尺寸
        }
        
        // 计算单元格宽度
        let sectionInset = layout.sectionInset
        let contentWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        let minInteritemSpacing = layout.minimumInteritemSpacing
        let numberOfItemsPerRow: CGFloat = 2 // 每行展示2个单元格
        
        // 宽度 = (总宽度 - 所有间距) / 单元格数量
        let width = (contentWidth - minInteritemSpacing * (numberOfItemsPerRow - 1)) / numberOfItemsPerRow
        
        // 比例计算高度 (可以根据需要调整，这里使用1:1的宽高比)
        let height = width * 0.67 // 或者保持固定高度100
        
        return CGSize(width: floor(width), height: floor(height))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard indexPath.item < toolListData.count else { return }
        
        let model = toolListData[indexPath.item]
        
        // 处理VIP工具点击
        if model.needVIP {
            // TODO: 检查用户VIP状态并处理
            print("点击了VIP工具: \(model.itemTitleStr)")
            // 可以弹出提示或跳转到VIP购买页面
            return
        }
        
        // 普通工具点击处理
        print("点击了工具: \(model.itemTitleStr), Tag: \(model.modelTag)")
        
        // 根据工具类型执行不同的跳转逻辑
        var vc = BaseViewController()
        
        if model.modelTag == 2 {
            // 从Storyboard加载CalculatorToolVC
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // CalculatorToolVC是Main.storyboard的初始视图控制器
            if let calculatorVC = storyboard.instantiateInitialViewController() as? CalculatorToolVC {
                vc = calculatorVC
            } else {
                // 如果无法从Storyboard加载，则使用默认初始化方法作为备选
                print("无法从Storyboard加载CalculatorToolVC，使用默认初始化")
                vc = CalculatorToolVC()
            }
        } else if model.modelTag == 3 {
            // 导航到文字识别视图控制器
            vc = TextRecognitionVC()
        } else if model.modelTag == 4 {
            // 导航到中文转五笔视图控制器
            vc = ChineseToWubiVC()
        } else if model.modelTag == 5 {
            // 导航到相册预览视图控制器
            vc = PhotoPreviewVC()
        } else if model.modelTag == 6 {
            // 导航到图片擦除视图控制器
            vc = DDGClearImageView()
        } else if model.modelTag == 7 {
            // 导航到头像浏览器视图控制器
            vc = AvatarBrowserVC()
        } else {
            vc = HomeImgToolVC()
        }
        
        // 设置标题
        if let baseVC = vc as? BaseViewController {
            baseVC.navTitleLabel.text = model.itemTitleStr
        }
        
        // 设置hidesBottomBarWhenPushed属性为true，这样在跳转时会隐藏底部TabBar
        vc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
