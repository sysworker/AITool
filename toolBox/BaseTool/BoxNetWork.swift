//
//  BoxNetWork.swift
//  toolBox
//
//  Created by wang on 2025/3/26.
//  Copyright © 2025 ToolBox. All rights reserved.
//

import Foundation
import Alamofire
import SVProgressHUD

// MARK: - 数据类型枚举
enum RequestDataType {
    case dataWithDictionary
    case dataWithDirectObject// 直接返回解析好的对象，不需要再处理 data 字段
}


// MARK: - 网络配置
struct NetworkConfig {
    static let baseURL = "https://api.szy.cn/score/task/sendTask/v2.0"
    static let timeoutInterval: TimeInterval = 15.0
    static let maxRetryCount = 2
    static let cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
}

// MARK: - 错误类型
enum NetworkError: Error {
    case invalidURL
    case responseError(code: Int, message: String)
    case noData
    case parseError
    case requestFailed(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .responseError(let code, let message):
            return "请求错误(\(code)): \(message)"
        case .noData:
            return "服务器未返回数据"
        case .parseError:
            return "数据解析失败"
        case .requestFailed(let error):
            return "请求失败: \(error.localizedDescription)"
        }
    }
}

// 网络响应模型 - 字典数据
class DictionaryNetWorkMode: Codable {
    var code: Int?
    var message: String?
    var data: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case code, message, data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decodeIfPresent(Int.self, forKey: .code)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        
        // 对于 data，我们简单地尝试解析为 [String: Any]
        if let dataDict = try? container.decodeIfPresent([String: AnyCodable].self, forKey: .data) {
            data = dataDict.mapValues { $0.value }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(code, forKey: .code)
        try container.encodeIfPresent(message, forKey: .message)
        
        // 对于 data，我们需要转换为 [String: AnyCodable]
        if let data = data {
            let encodableDict = data.mapValues { AnyCodable($0) }
            try container.encodeIfPresent(encodableDict, forKey: .data)
        }
    }
    
    // 便于初始化的构造函数
    init() {
        code = nil
        message = nil
        data = nil
    }
}

// 辅助类，用于解码任意值
struct AnyCodable: Codable {
    var value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode value")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self.value {
        case is NSNull, is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "Cannot encode value")
            throw EncodingError.invalidValue(self.value, context)
        }
    }
}

// MARK: - 网络请求记录器
class NetworkLogger {
    static func log(request: URLRequest) {
        #if DEBUG
        let requestInfo = """
        ✅ 开始请求 [\(request.httpMethod ?? "未知")] \(request.url?.absoluteString ?? "未知URL")
        请求头: \(request.allHTTPHeaderFields ?? [:])
        """
        print(requestInfo)
        
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("请求体: \(bodyString)")
        }
        #endif
    }
    
    static func log(response: HTTPURLResponse, data: Data?, error: Error?) {
        #if DEBUG
        let responseInfo = """
        ⬅️ 收到响应 [\(response.statusCode)] \(response.url?.absoluteString ?? "未知URL")        
        """//响应头: \(response.allHeaderFields)
        print(responseInfo)
        
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
            print("响应体: \(dataString)")
        }
        
        if let error = error {
            print("❌ 错误: \(error.localizedDescription)")
        }
        #endif
    }
}

// MARK: - 网络请求方法 - 通用
private func performNetworkRequest<T: Codable>(url: String, parameters: [String: Any], retryCount: Int = 0, completion: @escaping (Result<T, Error>) -> Void) {
    let requestUrl = "\(NetworkConfig.baseURL)\(url)"
    // 创建请求配置
    let request = AF.request(requestUrl,
                             method: .post,
                             parameters: parameters,
                             encoding: JSONEncoding.default,
                             requestModifier: { urlRequest in
                                urlRequest.timeoutInterval = NetworkConfig.timeoutInterval
                                urlRequest.cachePolicy = NetworkConfig.cachePolicy
                                NetworkLogger.log(request: urlRequest)
                             })
    
    // 发送请求并处理响应
    request.validate()
           .responseDecodable(of: T.self) { response in

                // 记录响应日志
                if let httpResponse = response.response {
                    NetworkLogger.log(response: httpResponse, data: response.data, error: response.error)
                }
                
                
                switch response.result {
                case .success(let networkMode):
                    completion(.success(networkMode))
                    
                case .failure(let error):
                    // 实现请求重试逻辑
                    if let urlError = error.underlyingError as? URLError,
                       (urlError.code == .timedOut || urlError.code == .notConnectedToInternet),
                       retryCount < NetworkConfig.maxRetryCount {
                        
                        // 网络超时或连接问题，进行重试
                        #if DEBUG
                        print("网络问题，准备第\(retryCount + 1)次重试...")
                        #endif
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            performNetworkRequest(url: url, parameters: parameters, retryCount: retryCount + 1, completion: completion)
                        }
                        return
                    }
                    
                    // 尝试解析服务器返回的错误信息
                    if let data = response.data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let code = json["code"] as? Int, let message = json["message"] as? String {
                        let responseError = NetworkError.responseError(code: code, message: message)
                        completion(.failure(responseError))
                    } else {
                        // 无法解析的错误，直接返回原始错误
                        completion(.failure(NetworkError.requestFailed(error)))
                    }
                }
           }
}

// MARK: - 网络请求方法 - 处理不同数据类型
func makePostRequest<T: Codable>(url: String, parameters: [String: Any], dataType: RequestDataType, retryCount: Int = 0, completion: @escaping (Result<T, Error>) -> Void) {
    switch dataType {
    case .dataWithDictionary:
        performNetworkRequest(url: url, parameters: parameters, retryCount: retryCount) { (result: Result<DictionaryNetWorkMode, Error>) in
            switch result {
            case .success(let dictMode):
                if let castValue = dictMode as? T {
                    completion(.success(castValue))
                } else {
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    case .dataWithDirectObject:
        // 在这个模式下，我们假设响应是标准的 {code:0, message:"", data:{...}} 格式
        // 但我们只关心 data 字段，而且希望直接解析为指定的类型 T
        performNetworkRequest(url: url, parameters: parameters, retryCount: retryCount) { (result: Result<ApiResponse<T>, Error>) in
            switch result {
            case .success(let response):
                if response.code == 0, let data = response.data {
                    completion(.success(data))
                } else {
                    let message = response.message ?? "未知错误"
                    completion(.failure(NetworkError.responseError(code: response.code, message: message)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - 标准 API 响应模型
struct ApiResponse<T: Codable>: Codable {
    let code: Int
    let message: String?
    let data: T?
}

// MARK: - 取消所有网络请求
func cancelAllRequests() {
    Alamofire.Session.default.session.getAllTasks { tasks in
        tasks.forEach { $0.cancel() }
    }
}






// 修改配置部分为多用户数组
let users = [
    [
        "userId": "b29a83a856e946b8ab0d",
        "schoolId": "cxfjzfJ6EVtl6xpzORk",
        "childId": "1ecf88ac549818ab43fe",
        "classId": "9f04033bdb107b29bfe6",
        "studentId": "e507742d68c0b19a4242",
//        "taskNumbers": ["jzrw010016", "jzrw010042", "jzrw000028"],
        "taskNumbers": ["jzrw010042"],
        "tag": "dt5s043Onp5N6mKIT0g6iCMRVAf1bICrC3/pEQsrsmBtlo4V/oDr/P5QveEsjJS+YFlH50Sv5D/Vqqgeni4mIl8xATnPTVkXafyzRkGXl7eSLOwHvO5e/gVnXxJ9lcEBAMuP9cgvz0VylDLBAU9cELpguQUsW383a9a+qfgKXrw="
    ],
    [
        "userId": "3ae7b3927ca4b57adba4",
        "schoolId": "cxfjzfJ6EVtl6xpzORk",
        "childId": "1ecf88ac549818ab43fe",
        "classId": "9f04033bdb107b29bfe6",
        "studentId": "e507742d68c0b19a4242",
        "taskNumbers": ["jzrw010042"],
//        "taskNumbers": ["jzrw010016", "jzrw010042", "jzrw000028", "jzrw000004"],
        "taskToken" : "BLH+PgRIWL6T8pH+R1HY6ll2XbmwbLPIW80KQRacAXFgGQ18bsVunPrqKVri3Oy8WiHhjJiInolNxZZ\\/wUgTWXWRvv5HfmyOJlvIub7AZDpHgUAcipCsKJRWQGAyGLmfHg4FMMG09qeNutquEw3XKg==",
        "tag": "dt5s043Onp5N6mKIT0g6iCMRVAf1bICrC3/pEQsrsmBtlo4V/oDr/P5QveEsjJS+YFlH50Sv5D/Vqqgeni4mIl8xATnPTVkXafyzRkGXl7eSLOwHvO5e/gVnXxJ9lcEBAMuP9cgvz0VylDLBAU9cELpguQUsW383a9a+qfgKXrw="
    ]
]

// MARK: - 网络请求封装 (异步方式)
func sendRequestAsync(url: String, method: String, parameters: [String: Any]?, completion: @escaping (Data?, Error?) -> Void) {
    guard let urlObj = URL(string: url) else {
        completion(nil, NSError(domain: "InvalidURL", code: 400, userInfo: [NSLocalizedDescriptionKey: "无效的URL"]))
        return
    }
    
    var request = URLRequest(url: urlObj)
    request.httpMethod = method
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if method == "POST" {
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters ?? [:])
        } catch {
            completion(nil, error)
            return
        }
    }
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        completion(data, error)
    }.resume()
}

// 原有的同步方法保留，但标记为弃用
@available(*, deprecated, message: "请使用 sendRequestAsync 替代，避免主线程阻塞")
func sendRequest(url: String, method: String, parameters: [String: Any]?) -> (Data?, Error?) {
    var result: (Data?, Error?) = (nil, nil)
    let semaphore = DispatchSemaphore(value: 0)
    
    guard let urlObj = URL(string: url) else {
        return (nil, NSError(domain: "Invalid URL", code: 400))
    }
    
    var request = URLRequest(url: urlObj)
    request.httpMethod = method
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if method == "POST" {
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters ?? [:])
        } catch {
            return (nil, error)
        }
    }
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        result = (data, error)
        semaphore.signal()
    }.resume()
    
    semaphore.wait()
    return result
}

// MARK: - 签到接口 (异步版本)
func dailySignAsync(for user: [String: Any], completion: @escaping (Bool) -> Void) {
    let baseURL = "https://api.szy.cn/score/module/getSignInInfo/v1.0"
    let queryParams = [
        "appType": "parent",
        "userId": user["userId"] as! String,
        "schoolId": user["schoolId"] as! String,
        "childId": user["childId"] as! String,
        "classId": user["classId"] as! String
    ]
    
    let urlString = baseURL + "?" + queryParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
    
    sendRequestAsync(url: urlString, method: "GET", parameters: nil) { data, error in
        
        if let error = error {
            print("[签到错误] \(error.localizedDescription)")
            completion(false)
            return
        }
        
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("签到响应解析失败")
            completion(false)
            return
        }
        
        if json["code"] as? Int == 10000 {
            print("✅ 签到成功！")
            completion(true)
        } else {
            print("❌ 签到失败：\(json["message"] ?? "未知错误")")
            completion(false)
        }
    }
}

// 旧的签到接口保留，但重构为调用异步版本
@available(*, deprecated, message: "请使用 dailySignAsync 替代，避免主线程阻塞")
func dailySign(for user: [String: Any]) -> Bool {
    var success = false
    let semaphore = DispatchSemaphore(value: 0)
    
    dailySignAsync(for: user) { result in
        success = result
        semaphore.signal()
    }
    
    semaphore.wait()
    return success
}

// MARK: - 执行任务接口 (异步版本)
func executeTasksAsync(for user: [String: Any], completion: @escaping (Int, Int) -> Void) {
    let taskNumbers = user["taskNumbers"] as! [String]
    var completedTasks = 0
    var successCount = 0
    
    // 如果没有任务，直接返回
    if taskNumbers.isEmpty {
        completion(0, 0)
        return
    }
    
    // 对每个任务进行处理
    for taskNumber in taskNumbers {
        let url = "https://api.szy.cn/score/task/sendTask/v2.0"
        
        var parameters: [String: Any] = [
            "userId": user["userId"] as! String,
            "schoolId": user["schoolId"] as! String,
            "childId": user["childId"] as! String,
            "actionType": 51,
            "studentId": user["studentId"] as! String,
            "taskNumber": taskNumber,
            "tag": user["tag"] as! String,
            "appType": "parent",
            "repeatData": "",
            "classId": user["classId"] as! String
        ]
        
        if taskNumber == "jzrw000004" {
            parameters["taskToken"] = #"BLH+PgRIWL6T8pH+R1HY6ll2XbmwbLPIW80KQRacAXFgGQ18bsVunPrqKVri3Oy8WiHhjJiInolNxZZ\/wUgTWXWRvv5HfmyOJlvIub7AZDpHgUAcipCsKJRWQGAyGLmfHg4FMMG09qeNutquEw3XKg=="#
        }
        
        if taskNumber == "jzrw010016" {
            // 需要多次执行的特殊任务
            var repeatedSuccessCount = 0
            var repeatedCompletedCount = 0
            
            for r in 1...3 {
                sendRequestAsync(url: url, method: "POST", parameters: parameters) { data, error in
                    DispatchQueue.main.async {
                        repeatedCompletedCount += 1
                        
                        if let error = error {
                            print("[任务\(taskNumber)第\(r)次] 请求失败: \(error.localizedDescription)")
                        } else if let data = data,
                                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            
                            if json["code"] as? Int == 10000 {
                                print("🎯 任务\(taskNumber)第\(r)次执行成功！")
                                repeatedSuccessCount += 1
                            } else {
                                print("❌ 任务\(taskNumber)第\(r)次失败：\(json["message"] ?? "未知错误")")
                            }
                        } else {
                            print("[任务\(taskNumber)第\(r)次] 响应解析失败")
                        }
                        
                        // 当所有重复请求完成时
                        if repeatedCompletedCount == 3 {
                            completedTasks += 1
                            if repeatedSuccessCount > 0 {
                                successCount += 1
                            }
                            
                            // 检查是否所有任务都已完成
                            if completedTasks == taskNumbers.count {
                                completion(successCount, taskNumbers.count)
                            }
                        }
                    }
                }
            }
        } else {
            // 普通任务，只执行一次
            sendRequestAsync(url: url, method: "POST", parameters: parameters) { data, error in
                DispatchQueue.main.async {
                    completedTasks += 1
                    
                    if let error = error {
                        print("[任务\(taskNumber)] 请求失败: \(error.localizedDescription)")
                    } else if let data = data,
                              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        
                        if json["code"] as? Int == 10000 {
                            print("🎯 任务\(taskNumber)执行成功！")
                            successCount += 1
                        } else {
                            print("❌ 任务\(taskNumber)失败：\(json["message"] ?? "未知错误")")
                        }
                    } else {
                        print("[任务\(taskNumber)] 响应解析失败")
                    }
                    
                    // 检查是否所有任务都已完成
                    if completedTasks == taskNumbers.count {
                        completion(successCount, taskNumbers.count)
                    }
                }
            }
        }
    }
}

// 旧的执行任务接口保留，但重构为调用异步版本
@available(*, deprecated, message: "请使用 executeTasksAsync 替代，避免主线程阻塞")
func executeTasks(for user: [String: Any]) -> (successCount: Int, total: Int) {
    var result: (Int, Int) = (0, 0)
    let semaphore = DispatchSemaphore(value: 0)
    
    executeTasksAsync(for: user) { successCount, total in
        result = (successCount, total)
        semaphore.signal()
    }
    
    semaphore.wait()
    return (result.0, result.1)
}

// MARK: - 网络管理器
class NetworkManager {
    // 单例实例
    static let shared = NetworkManager()
    
    // 私有初始化器，防止外部创建实例
    private init() {}
    
    // MARK: - 用户API
    
    /// 执行用户签到（异步）
    /// - Parameters:
    ///   - user: 用户信息
    ///   - showHUD: 是否显示加载指示器
    ///   - completion: 完成回调，返回签到是否成功
    func signInAsync(for user: [String: Any], showHUD: Bool = true, completion: @escaping (Bool) -> Void) {
        if showHUD {
            DispatchQueue.main.async {
                SVProgressHUD.show()
            }
        }
        
        dailySignAsync(for: user) { success in
            if showHUD {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            }
            completion(success)
        }
    }
    
    /// 执行任务（异步）
    /// - Parameters:
    ///   - user: 用户信息
    ///   - showHUD: 是否显示加载指示器
    ///   - completion: 完成回调，返回成功任务数和总任务数
    func executeTasksAsync(for user: [String: Any], showHUD: Bool = true, completion: @escaping (Int, Int) -> Void) {
        if showHUD {
            DispatchQueue.main.async {
                SVProgressHUD.show()
            }
        }
        
        executeTasksAsync(for: user) { successCount, totalCount in
            if showHUD {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
            }
            completion(successCount, totalCount)
        }
    }
    
    /// 批量处理所有用户的所有任务（异步）
    /// - Parameters:
    ///   - showHUD: 是否显示加载指示器
    ///   - completion: 完成回调，返回总体处理结果
    func processAllUsersAsync(showHUD: Bool = true, completion: @escaping (Int, Int, Int, Int) -> Void) {
        if showHUD {
            DispatchQueue.main.async {
                SVProgressHUD.show(withStatus: "正在处理所有用户...")
            }
        }
        
        var totalSignSuccess = 0
        var totalSignAttempts = 0
        var totalTaskSuccess = 0
        var totalTasks = 0
        
        let userGroup = DispatchGroup()
        
        for user in users {
            // 将每个用户的处理添加到组中
            userGroup.enter()
            
            // 先执行签到
            self.signInAsync(for: user, showHUD: false) { signSuccess in
                totalSignAttempts += 1
                totalSignSuccess += signSuccess ? 1 : 0
                
                // 然后执行任务
                self.executeTasksAsync(for: user, showHUD: false) { taskSuccess, taskTotal in
                    totalTaskSuccess += taskSuccess
                    totalTasks += taskTotal
                    
                    // 标记该用户的处理已完成
                    userGroup.leave()
                }
            }
        }
        
        // 当所有用户处理完成后调用
        userGroup.notify(queue: .main) {
            if showHUD {
                SVProgressHUD.dismiss()
            }
            
            // 返回总体结果
            completion(totalSignSuccess, totalSignAttempts, totalTaskSuccess, totalTasks)
        }
    }
}
