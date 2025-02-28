//
//  APIManager.swift
//  ProductMVVM
//
//  Created by Nishant Chauhan on 22/01/24.
//
import UIKit

fileprivate struct NilCodable: Codable {
}

public enum HttpMethods: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
}


public enum TaskAnswer<T> {
    case result(T)
    case error(Error)
}

@objc public final class APIManager: NSObject {
    
    private static func createRequest(url: String, method: HttpMethods) -> NSMutableURLRequest? {
        
        var urlString = url
        let customCharacterset = CharacterSet(charactersIn: "+").inverted
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: customCharacterset)!
        
//        let urlString = url.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        guard let URL = URL(string: urlString) else {
            return nil
        }
        let request = NSMutableURLRequest(url: URL)
        request.httpMethod = method.rawValue
        return request
    }

    @objc public static func getRequestCommon(url: String, header: [String: String]? = nil, loaderShow: Bool, appendToken:Bool,  params: [String: Any]? ,loaderInView : UIViewController, completion: @escaping (_ response: NSDictionary) -> Void) {
        
        
       
        // HTTPHeaderField
        let headerDict: [String: String] = [:]
        
        var urlStr:String
        urlStr = String(format: "%@", url)
        print("url:\(urlStr)")
        getRequest(url: urlStr, loaderShow: loaderShow, decodableType: NilCodable.self, header: header != nil ? header: headerDict, params: params, loaderInView: loaderInView) { (result) in
            print(result.self)
            switch result {
            case .result(let eresult):
                let resultDic = eresult as! NSDictionary
                completion(resultDic)
            case .error(let e):
                print(e )
            }
        }
    }
 
    fileprivate static func getRequest<T: Decodable>(
        url: String,
        loaderShow:Bool,
        decodableType: T.Type,
        header: [String: String]? = nil,
        params: [String: Any]?,
        loaderInView : UIViewController,
        completion: ((TaskAnswer<Any>) -> Void)? = nil ) {
        
        
        //Creating a request and making sure it exists.
        guard let request = createRequest(url: url, method: HttpMethods.get) else {
            completion?(TaskAnswer.error(NotURLError(title: "Map", description: "Couldn't parse argument to URL")))
            loaderInView.popupAlert(title: "Map", message: "Couldn't parse argument to URL" , actionTitles: ["OK"], actions:[{action1 in
            },{action2 in

            }, nil])
            return
        }

            //Adding each header parameter to the request.
            for headerParam in header ?? [:] {
                request.setValue(headerParam.key, forHTTPHeaderField: headerParam.value)
            }
            
            print("getrequest Url 1\(url)")
            print("headerParam \(request.allHTTPHeaderFields)")
//            print("getrequest Url 1\(url)")
            
        //Creating the get task with the request, and executing it.
            createTask(request: request as URLRequest, loaderShow: loaderShow, decodableType: decodableType,loaderInView: loaderInView, completion: completion).resume()
    }

    @objc public static func postRequestCommon(url: String, header: [String: String]? = nil, loaderShow: Bool,  params: Dictionary<String,Any>? ,loaderInView : UIViewController, completion: @escaping (_ response: NSDictionary) -> Void) {
        
        print(params as Any)
        
        // HTTPHeaderField
        let headerDict: [String: String] = [:]
        
        
        postRequestCommon(url: url,loaderShow:loaderShow, method: HttpMethods.post, header: header != nil ? header : headerDict, params: params!, loaderInView: loaderInView) { (result) in
            print(result.self)
            switch result {
            case .result(let eresult):
                let resultDic = eresult as! NSDictionary
                completion(resultDic)
            case .error(let e):
                print(e )
            }
        }
        
    }
    
    
    @objc public static func postRequestNested(url: String, header: [String: String]? = nil, loaderShow: Bool,  params: Dictionary<String,Any>? ,loaderInView : UIViewController, completion: @escaping (_ response: NSDictionary) -> Void) {
        
        print(params as Any)
      
        
        // HTTPHeaderField
        let headerDict: [String: String] = [:]
     
        postRequestNested(url: url,loaderShow:loaderShow, method: HttpMethods.post, header: header != nil ? header : headerDict, params: params!, loaderInView: loaderInView) { (result) in
            print(result.self)
            switch result {
            case .result(let eresult):
                let resultDic = eresult as! NSDictionary
                completion(resultDic)
            case .error(let e):
                print(e )
            }
        }
        
    }
    
    public static func postRequestCommon(
        url: String,
        loaderShow:Bool,
        method: HttpMethods = .post,
        header: [String: String]? = nil,
        params: [String: Any],
        loaderInView : UIViewController,
        completion: ((TaskAnswer<Any>) -> Void)? = nil) {
            postRequestCommon(url: url, loaderShow: loaderShow,header: header != nil ? header : header, params: params, loaderInView: loaderInView, decodableType: NilCodable.self,  completion: completion)
    }
    
    public static func postRequestNested(
        url: String,
        loaderShow:Bool,
        method: HttpMethods = .post,
        header: [String: String]? = nil,
        params: [String: Any],
        loaderInView : UIViewController,
        completion: ((TaskAnswer<Any>) -> Void)? = nil) {
            postRequestNested(url: url, loaderShow: loaderShow,header: header != nil ? header : header, params: params, loaderInView: loaderInView, decodableType: NilCodable.self,  completion: completion)
           
    }
    
    fileprivate static func postRequestCommon<T: Decodable>(
        url: String,
        loaderShow:Bool,
        method: HttpMethods = .post,
        header: [String: String]? = nil,
        params: [String: Any],
        loaderInView : UIViewController,
        decodableType: T.Type,
        completion: ((TaskAnswer<Any>) -> Void)? = nil) {
        print("getrequest Url 2\(url)")
        //Creating a request and making sure it exists.
        guard let request = createRequest(url: url, method: method) else {
            completion?(TaskAnswer.error(NotURLError(title: nil, description: "Couldn't parse argument to URL")))
            if(loaderShow == true){
                loaderInView.popupAlert(title: "Map", message: "Couldn't parse argument to URL" , actionTitles: ["OK"], actions:[{action1 in
                },{action2 in
                    
                }, nil])
            }
            return
        }

            //Adding each header parameter to the request.
            for headerParam in header ?? [:] {
                request.setValue(headerParam.key, forHTTPHeaderField: headerParam.value)
            }

        //Transforming the parameters into a string and putting into the httpBody.
        let postString = params.percentEscaped()
        print(postString)
        //let postString = params.percentEscaped()
        request.httpBody = postString.data(using: String.Encoding.utf8)

        //Creating the post task with the request, and executing it.
            createTask(request: request as URLRequest, loaderShow: loaderShow, decodableType: decodableType, loaderInView: loaderInView, completion: completion).resume()
    }
    
    
    
    fileprivate static func postRequestNested<T: Decodable>(
        url: String,
        loaderShow:Bool,
        method: HttpMethods = .post,
        header: [String: String]? = nil,
        params: [String: Any],
        loaderInView : UIViewController,
        decodableType: T.Type,
        completion: ((TaskAnswer<Any>) -> Void)? = nil) {
        print("getrequest Url 2\(url)")
        //Creating a request and making sure it exists.
        guard let request = createRequest(url: url, method: method) else {
            completion?(TaskAnswer.error(NotURLError(title: nil, description: "Couldn't parse argument to URL")))
            if(loaderShow == true){
                loaderInView.popupAlert(title: "Map", message: "Couldn't parse argument to URL" , actionTitles: ["OK"], actions:[{action1 in
                },{action2 in
                    
                }, nil])
            }
            return
        }

            //Adding each header parameter to the request.
            for headerParam in header ?? [:] {
                request.setValue(headerParam.key, forHTTPHeaderField: headerParam.value)
            }
            guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
                print("Error converting dictionary to JSON data")
                if(loaderShow == true){
                    loaderInView.popupAlert(title: "Map", message: "Couldn't parse argument" , actionTitles: ["OK"], actions:[{action1 in
                    },{action2 in
                        
                    }, nil])
                }
                return
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody

        //Creating the post task with the request, and executing it.
            createTask(request: request as URLRequest, loaderShow: loaderShow, decodableType: decodableType, loaderInView: loaderInView, completion: completion).resume()
    }

    fileprivate static func postRequest<P: Encodable>(
        url:String,
        loaderShow:Bool,
        method: HttpMethods = .post,
        header: [String: String]? = nil,
        loaderInView : UIViewController,
        params: P,
        completion: ((TaskAnswer<Any>) -> Void)? = nil) {
        print("getrequest Url 3\(url)")
        guard let request = createRequest(url: url, method: method) else {
            completion?(TaskAnswer.error(NotURLError(title: nil, description: "Couldn't parse argument to URL")))
            if(loaderShow == true){
                loaderInView.popupAlert(title: "Map", message: "Couldn't parse argument to URL" , actionTitles: ["OK"], actions:[{action1 in
                },{action2 in
                    
                }, nil])
            }
            return
        }

            for headerParam in header ?? [:] {
                request.setValue(headerParam.key, forHTTPHeaderField: headerParam.value)
            }

        //Encoding the parameter to the httpBody.
        do {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(params)
        } catch {
            completion?(TaskAnswer.error(InvalidCodableError(title: nil, description: "Couldn't encode object to JSON")))
            loaderInView.popupAlert(title: "Map", message: "Couldn't encode object to JSON" , actionTitles: ["OK"], actions:[{action1 in
            },{action2 in

            }, nil])
        }

        //Creating the post task with the request, and executing it.
            createTask(request: request as URLRequest, loaderShow: loaderShow, decodableType: NilCodable.self, loaderInView: loaderInView, completion: completion).resume()
    }

    fileprivate static func postRequest<T: Decodable, P: Encodable>(
        url:String,
        loaderShow:Bool,
        method: HttpMethods = .post,
        header: [String: String]? = nil,
        params: P,
        loaderInView : UIViewController,
        decodableType: T.Type,
        completion: ((TaskAnswer<Any>) -> Void)? = nil) {
        print("getrequest Url 4\(url)")
        //Creating a request and making sure it exists.
        guard let request = createRequest(url: url, method: method) else {
            completion?(TaskAnswer.error(NotURLError(title: nil, description: "Couldn't parse argument to URL")))
            if(loaderShow == true){
                loaderInView.popupAlert(title: "Map", message: "Couldn't parse argument to URL" , actionTitles: ["OK"], actions:[{action1 in
                },{action2 in
                    
                }, nil])
            }
            return
        }

            //Adding each header parameter to the request.
            for headerParam in header ?? [:] {
                request.setValue(headerParam.key, forHTTPHeaderField: headerParam.value)
            }

        //Encoding the parameter to the httpBody.
        do {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(params)
        } catch {
            completion?(TaskAnswer.error(InvalidCodableError(title: nil, description: "Couldn't encode object to JSON")))
            
            if(loaderShow == true){
                loaderInView.popupAlert(title: "Map", message: "Couldn't encode object to JSON" , actionTitles: ["OK"], actions:[{action1 in
                },{action2 in
                    
                }, nil])
            }
            
        }

        //Creating the post task with the request, and executing it.
            createTask(request: request as URLRequest, loaderShow: loaderShow, decodableType: decodableType, loaderInView: loaderInView, completion: completion).resume()
    }
    
    /**
     This function performs a delete request, triggers a completion handler with its answer.

     - Warning: This method is asyncronous.

     - Parameter url: The url address to make the requisition.
     - Parameter header: The request's header, separated by key and values.
     - Parameter loaderShow: The loader you want to show or not.
     - Parameter params: The request's body, which conforms to the encodable protocol.
     - Parameter decodableType: The decodable type that conforms to the get request answer.
     - Parameter completion: The block of code that will execute after the get request is executed.
     */
    
    @objc public static func deleteRequestCommon(url: String, header: [String: String]? = nil, loaderShow: Bool,  params: [String: Any]? ,loaderInView : UIViewController, completion: @escaping (_ response: NSDictionary) -> Void) {
    
        
    }
    
    fileprivate static func deleteRequest<P: Encodable>(
        url:String,
        method: HttpMethods = .delete,
        header: [String: String]? = nil,
        loaderInView : UIViewController,
        params: P,
        completion: ((TaskAnswer<Any>) -> Void)? = nil) {
        print("getrequest Url 3\(url)")
        guard let request = createRequest(url: url, method: method) else {
            completion?(TaskAnswer.error(NotURLError(title: nil, description: "Couldn't parse argument to URL")))
            loaderInView.popupAlert(title: "Map", message: "Couldn't parse argument to URL" , actionTitles: ["OK"], actions:[{action1 in
            },{action2 in

            }, nil])
            return
        }

            //Adding each header parameter to the request.
            for headerParam in header ?? [:] {
                request.setValue(headerParam.key, forHTTPHeaderField: headerParam.value)
            }

        //Encoding the parameter to the httpBody.
        do {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(params)
        } catch {
            
            completion?(TaskAnswer.error(InvalidCodableError(title: nil, description: "Couldn't encode object to JSON")))
            loaderInView.popupAlert(title: "Map", message: "Couldn't encode object to JSON" , actionTitles: ["OK"], actions:[{action1 in
            },{action2 in

            }, nil])
        }

        //Creating the post task with the request, and executing it.
            createTask(request: request as URLRequest, loaderShow: true, decodableType: NilCodable.self, loaderInView: loaderInView, completion: completion).resume()
    }
    
    
    fileprivate static func createTask<T: Decodable>(request: URLRequest,loaderShow:Bool, decodableType: T.Type,loaderInView : UIViewController, completion:
        ((TaskAnswer<Any>) -> Void)? = nil) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            mainThread {
                
            guard let data = data, error == nil else {
                completion?(TaskAnswer.error(error!))
                if(loaderShow == true){
                    loaderInView.popupAlert(title: "Map", message: error?.localizedDescription , actionTitles: ["OK"], actions:[{action1 in
                    },{action2 in
                        
                    }, nil])
                }
                return
                    
            }
            do {
                if decodableType != NilCodable.self {
                    let response = try JSONDecoder().decode(decodableType, from: data)
                    completion?(TaskAnswer.result(response))
                } else {
                    if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                        print("Json2\(convertedJsonIntoDict)")
                        let successStr = convertedJsonIntoDict["code"] as? String
                        if successStr == "success"
                        {
                            completion?(TaskAnswer.result(convertedJsonIntoDict))
                            if(loaderShow == true){
                            }
                        }
                        else
                        {
                            
                            
                            
                                let delegate = UIApplication.shared.delegate as! AppDelegate
                                var errorString : String = ""
                                if delegate.validateResponse(convertedJsonIntoDict)
                            {
                                    if convertedJsonIntoDict["errors"] is NSArray
                                    {
                                        let error = convertedJsonIntoDict["errors"] as! NSArray
                                        errorString = (error[0] as? String)!
                                    }
                                    else if convertedJsonIntoDict["errors"] is NSDictionary
                                    {
                                        let errorDic = convertedJsonIntoDict["errors"] as! NSDictionary
                                        let errorArray = errorDic.allValues
                                        if errorArray.count > 0 {
                                            if let errorArrayObj = errorArray.first  as? Array<Any>
                                            {
                                                errorString = (errorArrayObj.first as? String)!
                                            }
                                            else
                                            {
                                                if  (errorArray.first  is String)
                                                {
                                                    errorString = (errorArray.first as? String)!
                                                }
                                                else
                                                {
                                                    errorString = "Sone Error Occurred"
                                                }
                                        }
                                            
                                        }
                                    }
                                    else if (convertedJsonIntoDict["errors"] is String) {
                                        errorString = (convertedJsonIntoDict["errors"] as? String)!
                                        
                                    }
                                    else if (convertedJsonIntoDict["message"] is String) {
                                        errorString = (convertedJsonIntoDict["message"] as? String)!
                                    }
                                    else if (convertedJsonIntoDict["error"] is String) {
                                        errorString = (convertedJsonIntoDict["error"] as? String)!
                                    }
                                    else
                                    {
                                        errorString = (convertedJsonIntoDict["errors"] as? String)!
                                    }
                                    
                                    
                                    if(loaderShow == true){
                                        
                                        
                                        loaderInView.popupAlert(title: "Map", message: errorString, actionTitles: ["OK"], actions:[{action1 in
                                        },{action2 in
                                            
                                        }, nil])
                                        
                                        
                                    }
                                }
                            
                        }
                        
                    }
                    if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Any] {
                            completion?(TaskAnswer.result(convertedJsonIntoDict))
                     
                    }
                }
            } catch let error as NSError {
                completion?(TaskAnswer.error(error))
                
                if(loaderShow == true){
                    loaderInView.popupAlert(title: "Map", message: error.localizedDescription , actionTitles: ["OK"], actions:[{action1 in
                    },{action2 in
    
                    }, nil])
                }
            }
            }
        }
        return task
    }
    
    
}

fileprivate func mainThread(_ completion: @escaping () -> ()) {
    DispatchQueue.main.async {
        completion()
    }
}

extension UIViewController {
    func popupAlert(title: String?, message: String?, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
//        self.present(alert, animated: true, completion: nil)
    }
}
