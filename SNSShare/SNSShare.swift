//
//  SNSShare.swift

import Foundation
import UIKit
import Social

public enum SNSType {
    
    case Twitter, Facebook, LINE
    
    public static var list: [SNSType] {
        return [.Twitter, .Facebook, .LINE]
    }
    
    public var serviceType: String {
        switch self {
        case .Twitter: return SLServiceTypeTwitter
        case .Facebook: return SLServiceTypeFacebook
        default: return ""
        }
    }
    
    private func useSocialFramework() -> Bool {
        switch self {
        case .Twitter, .Facebook: return true
        default: return false
        }
    }
    
    private func available() -> Bool {
        if useSocialFramework() {
            return SLComposeViewController.isAvailableForServiceType(serviceType)
        } else if case .LINE = self {
            return UIApplication.sharedApplication().canOpenURL(NSURL(string: "line://")!)
        }
        return false
    }
    
}

public enum SNSShareResult {
    case Success(Bool)
    case Failure(SNSShareErrorType)
    
    public var done: Bool {
        if case .Success(let done) = self {
            return done
        } else {
            return false
        }
    }
}

public enum SNSShareErrorType: ErrorType {
    case NotAvailable(SNSType)
    case EmptyData
    case Cancelled
    case URIEncodingError
    case UnknownError
}

public typealias SNSSharePostCompletion = SNSShareResult -> Void

public class SNSShareData {
    
    public var text: String = ""
    public var images: [UIImage] = [UIImage]()
    public var urls: [NSURL] = [NSURL]()
    
    public typealias BuilderClosure = SNSShareData -> Void
    
    public init() {}
    
    public init(@noescape builder: BuilderClosure) {
        builder(self)
    }    
    
    public var isEmpty: Bool {
        return text.isEmpty && images.isEmpty && urls.isEmpty
    }
}

public class SNSShare {
    
    public class func available(type: SNSType) -> Bool {
        return type.available()
    }
    
    public class func availableSNSList() -> [SNSType] {
        return SNSType.list.filter(available)
    }
    
    public class func post(
        type type: SNSType,
        data: SNSShareData,
        controller: UIViewController,
        completion: SNSSharePostCompletion = { _ in })
    {
        guard available(type) else {
            completion(.Failure(.NotAvailable(type)))
            return
        }
        
        guard !data.isEmpty else {
            completion(.Failure(.EmptyData))
            return
        }
        
        if type.useSocialFramework() {
            postToSocial(type.serviceType, data: data, controller: controller, completion: completion)
        } else {
            if case .LINE = type {
                postToLINE(data, completion: completion)
            } else {
                completion(.Failure(.UnknownError))
            }
        }
    }
    
    private class func postToSocial(
        serviceType: String,
        data: SNSShareData,
        controller: UIViewController,
        completion: SNSSharePostCompletion)
    {
        let sheet = SLComposeViewController(forServiceType: serviceType)
        sheet.completionHandler = { completion(.Success($0 == .Done)) }
        sheet.setInitialText(data.text)
        data.images.forEach {sheet.addImage($0) }
        data.urls.forEach { sheet.addURL($0) }
        controller.presentViewController(sheet, animated: true, completion: nil)
    }
    
    
    private class func postToLINE(data: SNSShareData, completion: SNSSharePostCompletion) {
        
        var scheme = "line://msg/"
        if let image = data.images.first, imageData = UIImagePNGRepresentation(image) {
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.setData(imageData, forPasteboardType: "public.png")
            scheme += "image/\(pasteboard.name)"
        } else {
            var texts = [String]()
            texts.append(data.text)
            data.urls.forEach{ texts.append($0.absoluteString) }
            let set = NSCharacterSet.alphanumericCharacterSet()
            guard let text = texts
                .joinWithSeparator("\n")
                .stringByAddingPercentEncodingWithAllowedCharacters(set) else
            {
                completion(.Failure(.URIEncodingError))
                return
            }
            scheme += "text/\(text)"
        }
        
        guard let url = NSURL(string: scheme) else {
            completion(.Failure(.UnknownError))
            return
        }
        
        UIApplication.sharedApplication().openURL(url)
        completion(.Success(true))
    }
    
}
