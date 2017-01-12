//
//  JsonReader.swift
//  Matrioska
//
//  Created by Andreas Thenn on 12/01/2017.
//  Copyright © 2017 runtastic. All rights reserved.
//

import Foundation

public typealias JSONObject = [String: AnyObject]

public class JSONReader {
    class func getJSON(from data: Data) -> JSONObject? {
        do {
            let json = try JSONSerialization.jsonObject(with: data,
                                                        options: JSONSerialization.ReadingOptions()) as? JSONObject
            return json
        } catch {
            NSLog("Error > JSON-File couldn't be parsed")
            return nil
        }
    }

    public class func jsonObject(from jsonFilename: String, bundle: Bundle = Bundle.main) -> JSONObject? {
        guard let filePath = bundle.path(forResource: jsonFilename, ofType: "json") else {
            return nil
        }
        
        do {
            let data = try NSData(contentsOfFile: filePath,
                                  options: NSData.ReadingOptions.uncached)
            return getJSON(from: data as Data)
        } catch {
            NSLog("Error > JSON-File couldn't be read")
            return nil
        }
    }
}
