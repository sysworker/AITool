//
//  DynamicList.swift
//  toolBox
//
//  Created by wang on 2025/3/24.
//  Created by wang on 2025/3/24.
//

import UIKit

import JXPagingView
import JXSegmentedView
import SDWebImage

/// 需要将JXPagingListContainerView继承JXSegmentedViewListContainer，不然会报错，开发文档中也有所提及
extension JXPagingListContainerView: @retroactive JXSegmentedViewListContainer {}


class DynamicList: UIViewController,JXSegmentedViewDelegate{

    // MARK: - UI组件
    /// 顶部背景渐变视图
    private lazy var gradientBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .gradientColor(
            with: CGSize(width: screenW, height: screenH),
            direction: .upwardDiagonalLine,
            startColor: .hex(hexString: "#E8F5C8"),
            endColor: .hex(hexString: "#9FA5D5")
        )
        return view
    }()
    
    /// 标题标签
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "交流"
        label.font = .boldSystemFont(ofSize: 33)
        label.textColor = .black
        return label
    }()
    
    ///var cityview = ZXCityView()
    var cityview = LocalServiceView()
    let tableHeaderViewHeight = 150
    let titleHead = 44
    lazy var pagingView: JXPagingView = preferredPagingView()
    let dataSource: JXSegmentedTitleDataSource = JXSegmentedTitleDataSource()

//    var segmentedView = jxse

//    let titleArr = ["优质","文字","图片"]

    let titleArr = ["优质","文字"]
    var segmentedView : JXSegmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: CGFloat(44)))
    let segmentedDataSource = JXSegmentedTitleDataSource() //segmentedDataSource一定要通过属性强持有，不然会被释放掉

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        // 添加渐变背景
        view.addSubview(gradientBackgroundView)
        gradientBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 添加标题
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(statusBarHeight + 10)
            make.leading.equalTo(20)
        }
        
        //配置数据源相关配置属性
        segmentedDataSource.titles = titleArr
        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource.titleSelectedColor = .hex(hexString: "#282828")
        segmentedDataSource.titleNormalColor = .hex(hexString: "#989898")
        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource.titleNormalFont = .systemFont(ofSize: 16)
        segmentedDataSource.titleSelectedFont = .boldSystemFont(ofSize: 20)
        segmentedView.dataSource = segmentedDataSource
        segmentedView.backgroundColor = .clear
        segmentedView.delegate = self
        segmentedView.layer.cornerRadius = 12
        segmentedView.layer.masksToBounds = true
        view.addSubview(self.segmentedView)

        let lineView = JXSegmentedIndicatorLineView()
        lineView.indicatorColor = .hex(hexString: "#EE7200")
        lineView.indicatorWidth = 22
        lineView.indicatorHeight = 4
        lineView.indicatorCornerRadius = 2
        segmentedView.indicators = [lineView]
        
        pagingView.mainTableView.backgroundColor = .clear
        pagingView.listContainerView.listCellBackgroundColor = .clear
        pagingView.mainTableView.gestureDelegate = self
        self.view.addSubview(pagingView)
        pagingView.snp.makeConstraints { make in
            make.top.equalTo(statusBarAndNavigationBarHeight+20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        segmentedView.listContainer = pagingView.listContainerView
        //扣边返回处理，下面的代码要加上
        pagingView.listContainerView.scrollView.panGestureRecognizer.require(toFail: self.navigationController!.interactivePopGestureRecognizer!)
        pagingView.mainTableView.panGestureRecognizer.require(toFail: self.navigationController!.interactivePopGestureRecognizer!)
        ///AI数据
        
        let sendDynamic = UIButton(type: .custom)
        sendDynamic.rx.controlEvent(.touchUpInside).bind { [weak self]() in
            // 检查用户是否已登录
            if !UserManager.shared.isLoggedIn {
                // 未登录，跳转到登录页面
                let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
                
                // 添加登录完成回调
                loginVC.loginCompletionHandler = { success in
                    if success {
                        // 登录成功，继续跳转到发布动态页面
                        DispatchQueue.main.async {
                            let vc = SendDynamicViewController()
                            vc.hidesBottomBarWhenPushed = true
                            self?.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                    // 登录失败或取消，不做处理，让用户留在当前页面
                }
                
                // 使用present方式展示登录页面
                loginVC.modalPresentationStyle = .fullScreen
                self?.present(loginVC, animated: true)
            } else {
                // 已登录，跳转到发布动态页面
                let vc = SendDynamicViewController()
                vc.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }.disposed(by:disBag)
        sendDynamic.setImage(.iconAddDynamic, for: .normal)
        self.view.addSubview(sendDynamic)
        sendDynamic.snp.makeConstraints { make in
            make.trailing.equalTo(-20)
//            make.top.equalTo(self.view.snp_topMargin)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(40)
        }
    }
    
    func preferredPagingView() -> JXPagingView {
        return JXPagingListRefreshView(delegate: self)
    }
    
}

extension DynamicList: JXPagingViewDelegate {
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        let vc = ContentListController()
        return vc
    }

    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        return tableHeaderViewHeight
    }

    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return cityview
    }

    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return titleHead
    }

    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        return segmentedView
    }

    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return titleArr.count
    }
    
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidScroll scrollView: UIScrollView) {
            
    }
}


extension DynamicList: JXPagingMainTableViewGestureDelegate {
    func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //禁止segmentedView左右滑动的时候，上下和左右都可以滚动
        if otherGestureRecognizer == segmentedView.collectionView.panGestureRecognizer {
            return false
        }
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
    }
}
