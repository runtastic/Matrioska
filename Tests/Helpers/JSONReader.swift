//
//  JSONReader.swift
//  Matrioska
//
//  Created by Andreas Thenn on 12/01/2017.
//  Copyright © 2017 runtastic. All rights reserved.
//

import Foundation
@testable import Matrioska

/// A JSONReader used to convert to JSONObject
final class JSONReader {
    
    /// Serializes from a given JSON Data into JSONObject
    ///
    /// - Parameter data: the Data object used in serialization
    /// - Returns: an optional serialized JSONObject
    /// - Throws: throws an error in case of failure or invalid JSON data
    class func jsonObject(from data: Data) throws -> JSONObject? {
        let json = try JSONSerialization.jsonObject(with: data) as? JSONObject
        
        return json
    }

    /// Serializes from a given JSON file into JSONObject
    ///
    /// - Parameters:
    ///   - jsonFilename: the file name
    ///   - bundle: the bundle where the file is located
    /// - Returns: an optional serialized JSONObject
    /// - Throws: throws an error in case of failure or invalid JSON data
    class func jsonObject(from jsonFilename: String, bundle: Bundle = .main) throws -> JSONObject? {
        guard let filePath = bundle.path(forResource: jsonFilename, ofType: "json") else {
            return nil
        }
        
        let url = URL(fileURLWithPath: filePath)
        
        return try jsonObject(from: Data(contentsOf: url, options: .uncached))
    }
}
