//
//    HuckleberryNetwork  (framework for making Network requests)
//
//    Allows user to easily make Network requests (with pagination)
//
//    The MIT License (MIT)
//
//    Copyright (c) 2018 David C. Vallas (david_vallas@yahoo.com) (dcvallas@twitter)
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE

import Foundation

extension Error {
    
    /// Prints the Error to log in specific format
    func display() {
        print("Error: code: \((self as NSError).code) info: \(self.localizedDescription)")
    }
    
    static var decodeData: Error {
        let msg = "Unable to decode JSON from data"
        return NSError(domain: "", code: 501, userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    static func decodeObject<T>(_ type: T) -> Error {
        let msg = "Unable to decode |\(type)| from JSON"
        return NSError(domain: "", code: 502, userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    static func decodeObjectArray<T>(_ type: T) -> Error {
        let msg = "Unable to decode |[\(type)]| from JSON"
        return NSError(domain: "", code: 502, userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    static func createURL(_ urlString: String) -> Error {
        let msg = "Unable to create url with string \(urlString)"
        return NSError(domain: "", code: 503, userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    static var dataError: Error {
        let msg = "Did not receive data from request"
        return NSError(domain: "", code: 504, userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    static var pagingDataError: Error {
        let msg = "Unable to retrieve paging information for request"
        return NSError(domain: "", code: 505, userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    static func error(message msg: String, code: Int) -> Error {
        return NSError(domain: "", code: code, userInfo: [NSLocalizedDescriptionKey: msg])
    }
}
