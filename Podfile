platform :ios, '15.0'
inhibit_all_warnings!
target 'toolBox' do

use_frameworks!

#链式语法
pod 'RxSwift'
pod 'RxCocoa'
pod 'RxGesture'
#网络请求
pod 'Alamofire'
#UItableview注册
pod 'Reusable'
##图片加载
#pod 'Kingfisher'
#pod "KingfisherWebP"
#
pod 'SnapKit'
#上拉加载下拉刷新
pod 'MJRefresh'
#聊天框的实现
pod 'BSText', :git => 'https://github.com/Metaverse-ltd/BSText.git', :commit => '61eec98'
#吐丝
pod 'Toast-Swift'
# 轮播图
pod 'SDCycleScrollView'

pod 'SDWebImage'
#滑动segment
pod 'JXSegmentedView'
pod 'JXPagingView/Paging'

pod 'IQKeyboardManagerSwift'
#照片选择
pod 'TZImagePickerController'
#空视图
pod 'DZNEmptyDataSet'
pod 'UITextView+Placeholder'

pod 'SVProgressHUD'
#菜单
pod 'PanModal'

#pod 'STBeautify', :git => 'http://git2.hzshuyu.com/iOS/st_camera.git', :branch => 'st_SkyLive'

# https://github.com/facebook/SocketRocket
pod 'SocketRocket'
# 阿里云
pod 'AliyunOSSiOS'
# SVGA播放器
pod 'SVGAPlayer-iOS'
end


post_install do |installer|

    ## Fix for XCode 12.5
    find_and_replace("Pods/FBRetainCycleDetector/FBRetainCycleDetector/Layout/Classes/FBClassStrongLayout.mm",
      "layoutCache[currentClass] = ivars;", "layoutCache[(id<NSCopying>)currentClass] = ivars;")
      
      # 修复fishhook.c 运行Bug
      find_and_replace("Pods/FBRetainCycleDetector/fishhook/fishhook.c",
                       "indirect_symbol_bindings[i] = cur->rebindings[j].replacement;",
                       "if (i < (sizeof(indirect_symbol_bindings) / sizeof(indirect_symbol_bindings[0]))) { \n indirect_symbol_bindings[i]=cur->rebindings[j].replacement; \n }")

     #BUILD_LIBRARY_FOR_DISTRIBUTION 设置为 YES，确保库可以被分发。•IPHONEOS_DEPLOYMENT_TARGET 设置为 14.0，确保所有 Pod 库的最低支持版本为 iOS 14.0。
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      #config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'      
    end
  end

end

def find_and_replace(dir, findstr, replacestr)
  Dir[dir].each do |name|
      FileUtils.chmod("+w", name) #add
      text = File.read(name)
      replace = text.gsub(findstr,replacestr)
      if text != replace
          puts "Fix: " + name
          File.open(name, "w") { |file| file.puts replace }
          STDOUT.flush
      end
  end
  Dir[dir + '*/'].each(&method(:find_and_replace))
end



