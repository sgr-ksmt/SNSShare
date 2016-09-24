//
//  SNSShare.swift

import Foundation
import UIKit
import Social
import Accounts

public enum SNS {
    
    case twitter, facebook, line
    
    public static var list: [SNS] {
        return [.twitter, .facebook, .line]
    }
    
    public var serviceType: String {
        switch self {
        case .twitter: return SLServiceTypeTwitter
        case .facebook: return SLServiceTypeFacebook
        default: return ""
        }
    }
}

public enum SNSShareResult {
    case success
    case failure(SNSShareErrorType)
}

public enum SNSShareErrorType: Error {
    case notAvailable(SNS)
    case emptyData
    case cancelled
    case uriEncodingError
    case unknownError
}

public typealias SNSSharePostCompletion = (SNSShareResult) -> Void

open class SNSShareData {
    
    open var text: String = ""
    open var images: [UIImage] = [UIImage]()
    open var urls: [URL] = [URL]()
    
    public init() {
    }
    
    public init(_ text: String) {
        self.text = text
    }
    
    public init(_ images: [UIImage]) {
        self.images = images
    }
    
    public init(_ urls: [URL]) {
        self.urls = urls
    }
    
    public init(text: String, images: [UIImage], urls: [URL]) {
        self.text = text
        self.images = images
        self.urls = urls
    }
    
    public typealias BuilderClosure = (SNSShareData) -> Void
    public init(builder: BuilderClosure) {
        builder(self)
    }    
    
    open var isEmpty: Bool {
        return text.characters.isEmpty && images.isEmpty && urls.isEmpty
    }
}

extension SNSShareData {
    public func post(to type: SNS, completion: @escaping SNSSharePostCompletion = { _ in }) {
        guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
            completion(.failure(.unknownError))
            return
        }
        SNSShare.post(self, to: type, viewController: viewController, completion: completion)
    }
    public func post(to type: SNS, viewController: UIViewController, completion: @escaping SNSSharePostCompletion = { _ in }) {
        SNSShare.post(self, to: type, viewController: viewController, completion: completion)
    }
}

public class SNSShare {
    
    private init() {
    }
    
    public class func available(_ type: SNS) -> Bool {
        switch type {
        case .twitter:
            return SLComposeViewController.isAvailable(forServiceType: SNS.twitter.serviceType)
        case .facebook:
            return SLComposeViewController.isAvailable(forServiceType: SNS.facebook.serviceType)
        case .line:
            return UIApplication.shared.canOpenURL(URL(string: "line://")!)
        }
    }
    
    public class func availableSNSList() -> [SNS] {
        return SNS.list.filter { available($0) }
    }
    
    public class func post(_ data: SNSShareData, to type: SNS, viewController: UIViewController, completion: @escaping SNSSharePostCompletion = { _ in }) {
        guard available(type) else {
            completion(.failure(.notAvailable(type)))
            return
        }
        
        guard !data.isEmpty else {
            completion(.failure(.emptyData))
            return
        }
        
        switch type {
        case .twitter, .facebook:
            postToSocial(type.serviceType, data: data, viewController: viewController, completion: completion)
        case .line:
            postToLINE(data, completion: completion)
        }
    }
    
    fileprivate class func postToSocial(_ serviceType: String, data: SNSShareData, viewController: UIViewController, completion: @escaping SNSSharePostCompletion) {
        guard let sheet = SLComposeViewController(forServiceType: serviceType) else {
            completion(.failure(.unknownError))
            return
        }
        sheet.completionHandler = { result in
            switch result {
            case .done: completion(.success)
            case .cancelled: completion(.failure(.cancelled))
            }
        }
        sheet.setInitialText(data.text)
        data.images.forEach {sheet.add($0) }
        data.urls.forEach { sheet.add($0) }
        viewController.present(sheet, animated: true, completion: nil)
    }
    
    fileprivate class func postToLINE(_ data: SNSShareData, completion: SNSSharePostCompletion) {
        
        var scheme = "line://msg/"
        if let image = data.images.first, let imageData = UIImagePNGRepresentation(image) {
            let pasteboard = UIPasteboard.general
            pasteboard.setData(imageData, forPasteboardType: "public.png")
            scheme += "image/\(pasteboard.name)"
        } else {
            var texts = [String]()
            texts.append(data.text)
            data.urls.forEach{ texts.append($0.absoluteString) }
            let set = CharacterSet.alphanumerics
            guard let text = texts
                .joined(separator: "\n")
                .addingPercentEncoding(withAllowedCharacters: set) else
            {
                completion(.failure(.uriEncodingError))
                return
            }
            scheme += "text/\(text)"
        }
        
        guard let url = URL(string: scheme) else {
            completion(.failure(.unknownError))
            return
        }
        
        UIApplication.shared.openURL(url)
        completion(.success)
    }
}
