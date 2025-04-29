//
//  ChineseTextConverter.swift
//  toolBox
//
//  Created by wang on 2025/4/5.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import UIKit

class ChineseTextConverter {
    
    /// 转换中文文本为拼音
    ///
    /// - Parameters:
    ///   - text: 要转换的中文文本
    ///   - separator: 拼音之间的分隔符，默认为空格
    ///   - withTone: 是否包含声调，默认为true
    /// - Returns: 转换后的拼音文本
    static func convertToPinyin(_ text: String, separator: String = " ", withTone: Bool = true) -> String {
        // 创建中文字符串引用
        let mutableString = NSMutableString(string: text) as CFMutableString
        
        // 转换为带声调的拼音
        let transform = withTone ? kCFStringTransformMandarinLatin : kCFStringTransformToLatin
        CFStringTransform(mutableString, nil, transform, false)
        
        // 如果不需要声调，去掉声调
        if !withTone {
            CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        }
        
        // 获取转换后的字符串
        var result = mutableString as String
        
        // 替换分隔符
        if separator != " " {
            result = result.replacingOccurrences(of: " ", with: separator)
        }
        
        return result
    }
    
    /// 获取中文文本的五笔编码（简化实现，仅支持常用字）
    ///
    /// - Parameters:
    ///   - text: 要转换的中文文本
    ///   - separator: 五笔码之间的分隔符，默认为空格
    /// - Returns: 转换后的五笔编码文本
    static func convertToWubi(_ text: String, separator: String = " ") -> String {
        // 由于无法实际编码五笔，我们使用一个简化的实现方法
        // 实际应用中，应该使用完整的五笔编码词典
        
        var result = ""
        let dict = commonWubiDict()
        
        // 处理每个字符
        for (index, char) in text.enumerated() {
            let charString = String(char)
            if let wubi = dict[charString] {
                if index > 0 {
                    result += separator
                }
                result += wubi
            } else {
                // 如果字典中没有对应的五笔码，则保留原字符
                if index > 0 {
                    result += separator
                }
                result += charString
            }
        }
        
        return result
    }
    
    /// 常用汉字的五笔编码词典（简化版）
    private static func commonWubiDict() -> [String: String] {
        return [
            "我": "trnt",
            "你": "wvty",
            "他": "wpey",
            "她": "vty",
            "们": "wrt",
            "的": "udi",
            "地": "fayi",
            "在": "dhcy",
            "有": "det",
            "是": "jghm",
            "这": "yvey",
            "那": "mey",
            "个": "wtu",
            "和": "trk",
            "上": "higq",
            "下": "ghi",
            "中": "khk",
            "大": "ddd",
            "小": "iiii",
            "年": "dhk",
            "月": "eee",
            "日": "jjjj",
            "时": "jfk",
            "分": "wvt",
            "秒": "tiy",
            "天": "gdi",
            "来": "gipi",
            "去": "fpi",
            "做": "wtw",
            "学": "ipbf",
            "习": "xyxt",
            "爱": "epdc",
            "家": "pffg",
            "工": "aaa",
            "作": "wtf",
            "生": "tgd",
            "活": "ipk",
            "开": "gkh",
            "关": "uwl",
            "门": "uh",
            "想": "ynt",
            "看": "rhjh",
            "听": "bhv",
            "说": "yiy",
            "写": "twi",
            "读": "ybty",
            "谢": "ydk",
            "对": "ymcy",
            "错": "qyni",
            "好": "vbg",
            "坏": "fwfy",
            "快": "nuk",
            "慢": "nymk",
            "高": "ymk",
            "低": "wxmu",
            "朋": "gey",
            "友": "def",
            "同": "maw",
            "事": "fht",
            "情": "nulk",
            "人": "ww",
            "心": "nyy",
            "明": "jeu",
            "白": "rrrr",
            "黑": "lfoe",
            "红": "xte",
            "绿": "xev",
            "蓝": "amyy",
            "黄": "amgu",
            "水": "iiii",
            "火": "ooo",
            "山": "mmm",
            "电": "jnv",
            "脑": "emeg",
            "手": "rtth",
            "机": "sksy",
            "汉": "idui",
            "字": "bcy",
            "五": "gghg",
            "笔": "tdnt",
            "拼": "rwbn",
            "音": "ukcf",
            "转": "xln",
            "换": "rqky",
            "法": "iyiy",
            "工具": "aasjxx",
            "具": "sjxx",
            "软": "xtdx",
            "件": "wglg"
        ]
    }
} 
