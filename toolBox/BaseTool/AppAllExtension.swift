//
//  AppAllExtension.swift
//  toolBox
//
//  Created by  on 2025/3/24.
//

import Foundation
import UIKit
// 定义一个枚举来表示渐变方向
enum GradientChangeDirection {
    case level              // 水平渐变
    case vertical           // 垂直渐变
    case upwardDiagonalLine // 向上的对角线渐变
    case downwardDiagonalLine // 向下的对角线渐变
}

///颜色
extension UIColor{
    
    static func hex(hexString: String, alpha:CGFloat = 1) -> UIColor {
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if cString.count < 6 { return UIColor.black }
        
        let index = cString.index(cString.endIndex, offsetBy: -6)
        let subString = cString[index...]
        if cString.hasPrefix("0x") { cString = String(subString) }
        if cString.hasPrefix("0X") { cString = String(subString) }
        if cString.hasPrefix("#") { cString = String(subString) }
        
        if cString.count != 6 { return UIColor.black }
        
        var range: NSRange = NSRange(location: 0, length: 2)
        let rString = (cString as NSString).substring(with: range)
        range.location = 2
        let gString = (cString as NSString).substring(with: range)
        range.location = 4
        let bString = (cString as NSString).substring(with: range)
        
        
        let r = UInt32(rString, radix: 16) ?? 0x0
        let g = UInt32(gString, radix: 16) ?? 0x0
        let b = UInt32(bString, radix: 16) ?? 0x0
        
        
        return UIColor(r: r, g: g, b: b).withAlphaComponent(alpha)
    }
    
    static func gradientColor(with size: CGSize,
                                    direction: GradientChangeDirection,
                                    startColor: UIColor,
                                    endColor: UIColor) -> UIColor {
        
        // 参数校验：检查尺寸是否为零，或者起始颜色或结束颜色是否为 nil
        if size == .zero {
            return .clear
        }
        
        // 创建一个渐变图层
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        // 定义渐变的起点和终点（初始化为默认值）
        var startPoint = CGPoint(x: 0.0, y: 0.0)
        var endPoint = CGPoint(x: 0.0, y: 0.0)
        
        // 根据不同的渐变方向设置起点和终点
        switch direction {
        case .level:
            // 水平渐变，起点从左到右
            startPoint = CGPoint(x: 0.0, y: 0.0)
            endPoint = CGPoint(x: 1.0, y: 0.0)
        case .vertical:
            // 垂直渐变，起点从上到下
            startPoint = CGPoint(x: 0.0, y: 0.0)
            endPoint = CGPoint(x: 0.0, y: 1.0)
        case .upwardDiagonalLine:
            // 向上的对角线渐变，起点从下左到上右
            startPoint = CGPoint(x: 0.0, y: 1.0)
            endPoint = CGPoint(x: 1.0, y: 0.0)
        case .downwardDiagonalLine:
            // 向下的对角线渐变，起点从上左到下右
            startPoint = CGPoint(x: 0.0, y: 0.0)
            endPoint = CGPoint(x: 1.0, y: 1.0)
        }
        
        // 设置渐变的起点和终点
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        // 设置渐变的颜色数组（开始颜色和结束颜色）
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        
        // 使用 UIGraphicsImageRenderer 创建图像上下文
        let renderer = UIGraphicsImageRenderer(size: size)
        
        // 渲染渐变图层到图像
        let image = renderer.image { context in
            gradientLayer.render(in: context.cgContext)
        }
        
        // 使用带有渐变的图像创建一个颜色，并返回
        return UIColor(patternImage: image)
    }
    
    convenience init(r: UInt32, g: UInt32, b: UInt32, a: CGFloat = 1.0) {
        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: a)
    }
    
}





private var disposeBagKey = "DisposeBagKey"

extension NSObject {
    ///rx监听释放包
    var disBag: DisposeBag {
        get {
            guard let disBag = objc_getAssociatedObject(self, disposeBagKey.addressKey) as? DisposeBag else {
                let disBag = DisposeBag();
                self.disBag = disBag;
                return disBag;
            }
            return disBag

        }
        set {
            objc_setAssociatedObject(self, disposeBagKey.addressKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}





protocol OptionalType {
    var unsafelyUnwrapped: Any { get }
    var unsafelyFlattened: Any { get }
}
extension String{
    
    func xxsubstring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
    
    func allRanges(of string: String) -> [Range<String.Index>] {
        var rangeArray = [Range<String.Index>]()
        var searchedRange: Range<String.Index>
        guard let sr = self.range(of: self) else {
            return rangeArray
        }
        searchedRange = sr
        
        var resultRange = self.range(of: string, options: .regularExpression, range: searchedRange, locale: nil)
        while let range = resultRange {
            rangeArray.append(range)
            searchedRange = Range(uncheckedBounds: (range.upperBound, searchedRange.upperBound))
            resultRange = self.range(of: string, options: .regularExpression, range: searchedRange, locale: nil)
        }
        return rangeArray
    }
    
    func nsRange(fromRange range : Range<String.Index>) -> NSRange {
           return NSRange(range, in: self)
       }
    
    
    
    
    static func hhmmssFromSecond(_ seconds: Int) -> String{
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        
        if hours > 0 {
            // 如果大于一小时，显示 hh:mm:ss
            return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
        } else {
            // 否则，显示 mm:ss
            return String(format: "%02d:%02d", minutes, remainingSeconds)
        }
    }
    static func stringFromAny(_ value:Any?) -> String {
        switch value {
        case .some(let wrapped):
            if let notNil =  wrapped as? OptionalType, !(notNil.unsafelyFlattened is NSNull) {
                return String(describing: notNil.unsafelyFlattened)
            } else if !(wrapped is OptionalType) {
                return String(describing: wrapped)
            }
            return ""
        case .none :
            return ""
        }
    }
    
    var isWidFormater: Bool {
        let regex: String = "^[A-Za-z0-9@#$^\\-\\.~&+=_!]*$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    var isChatpterOrNum: Bool {
        let regex: String = "^[A-Za-z0-9]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    
    func isChineseWords() -> Bool {
        let regex : String = "^[\u{4e00}-\u{9fa5}]{0,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    
    func isEnglishWords() -> Bool {
        let regex : String = "^[A-Za-z]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    func isMobilePhoneNumber() -> Bool {
        let regex : String = "1[0-9][0-9]{9}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    ///去掉空格 获取第一个字符排序，中文返回拼音首字母大写，英文返回首字母大写，数字和符号返回#
    func getFirstChapter() -> String {
        let temp = self.replacingOccurrences(of: " ", with: "")
        if temp.isEmpty {
            return "#"
        }
        guard let first = temp.first else { return "#" }
        let firstStr = String(first)
        if firstStr.isChineseWords() {
            // 注意,这里一定要转换成可变字符串
            let mutableString = NSMutableString.init(string: firstStr) as CFMutableString
            CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
            // 去掉声调(用此方法大大提高遍历的速度)
            CFStringTransform(mutableString, nil, kCFStringTransformStripCombiningMarks, false)
            let pinyinString = mutableString as String
            // 将拼音首字母装换成大写
            if let char = pinyinString.first {
                // 截取大写首字母
                let firstString = String(char).uppercased()
                // 判断姓名首位是否为大写字母
                let regexA = "^[A-Z]$"
                let predA = NSPredicate.init(format: "SELF MATCHES %@", regexA)
                return predA.evaluate(with: firstString) ? firstString : "#"
            }
            
            return "#"
        } else if firstStr.isEnglishWords() {
            return firstStr.uppercased()
        } else {
            return "#"
        }
        
        
    }
    
    var addressKey: UnsafeRawPointer {
        return UnsafeRawPointer(bitPattern: abs(hashValue))!
    }
    
    func appendingPathComponent(_ path:String) -> String {
        return (self as NSString).appendingPathComponent(path)
    }
    static func emjStringForIndex(_ index:Int) -> String {
        "[\(index)_emj]"
    }
    

    
    static func cycleTimeString(_ timeStamp: Int) -> String {
        
        let now = Date()
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        let timeInterval = abs(Int(now.timeIntervalSince1970) - timeStamp)

        if timeInterval < 60 {
            return "刚刚"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)分钟前"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)小时前"
        } else if calendar.isDateInYesterday(date) { // 昨天
            formatter.dateFormat = "昨天 HH:mm"
            return formatter.string(from: date)
        } else { // 更早日期
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            return formatter.string(from: date)
        }
        
    }
    static func messageTimeString(_ timeStamp: Int, isShort:Bool = false) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        let calendar = Calendar.current
        let unit: Set<Calendar.Component> = [.day, .month, .year, .weekOfYear]
        
        let nowComponents = calendar.dateComponents(unit, from: Date())
        let myComponents = calendar.dateComponents(unit, from: date)
      
        
        
        let dateFormatter = DateFormatter()
        var timeFormat: String
        
        // 重新创建日期，只包含年、月、日，排除时间部分的影响
        // 计算两个日期之间的天数差
        // 并且不是未来的时间 betweenDays >= 0
        if  let startDate = calendar.date(from: myComponents),
            let endDate = calendar.date(from: nowComponents),
            let betweenDays = calendar.dateComponents([.day], from: startDate, to: endDate).day,
            betweenDays >= 0 {
            
            if betweenDays == 0 { //今天
                timeFormat = "HH:mm"
            } else if betweenDays == 1 { //昨天
                timeFormat = "昨天 HH:mm"
            } else if nowComponents.year == myComponents.year && abs(betweenDays) < 7 { //周
                timeFormat = isShort ? "EEEE" : "EEEE HH:mm"
            } else {
                //往年
                if myComponents.year != nowComponents.year {
                    timeFormat = isShort ? "yyyy年MM月dd日" : "yyyy年MM月dd日 HH:mm"
                } else {
                    //今年
                    timeFormat = isShort ? "MM月dd日" : "MM月dd日 HH:mm"
                }
            }
        } else {
            timeFormat = isShort ? "yyyy年MM月dd日" : "yyyy年MM月dd日 HH:mm"
        }
        
        
        

        
        // 检查当前区域设置是否使用 12 小时制
        let shortTimeFormatter = DateFormatter()
        shortTimeFormatter.timeStyle = .short
        shortTimeFormatter.locale = Locale.current
        let shortTimeStr = shortTimeFormatter.string(from: date)
        let hasAMPM = shortTimeStr.lowercased().contains("am") || shortTimeStr.lowercased().contains("pm")
        
        // 设置日期格式
        dateFormatter.dateFormat = timeFormat
        if hasAMPM {
            dateFormatter.amSymbol = "上午"
            dateFormatter.pmSymbol = "下午"
        }
        
        let str = dateFormatter.string(from: date)
        
        
        return str
    }
    
}
