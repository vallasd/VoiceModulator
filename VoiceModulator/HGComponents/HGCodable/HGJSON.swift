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

typealias JSON = Any
typealias HGDICT = Dictionary<String, Any>
typealias HGARRAY = [HGDICT]

class HG {
    
    /// Returns an HGDICT.  If hgdict can not be unwrapped as HGDICT, produces an error message and returns an empty HGDICT.
    static func decode<T>(hgdict: Any, decoder: T) -> HGDICT {
        if let dict = hgdict as? HGDICT { return dict }
        HGReport.shared.decodeFailed(decoder, object: hgdict)
        return HGDICT()
    }
    
    /// Returns an HGARRAY.  If hgarray can not be unwrapped as HGARRAY, produces an error message and returns an empty HGARRAY.
    static func decode<T>(hgarray: Any, decoder: T) -> HGARRAY {
        if let array = hgarray as? HGARRAY { return array }
        HGReport.shared.decodeFailed(decoder, object: hgarray)
        return HGARRAY()
    }
    
    /// Returns an Int8.  If int8 can not be unwrapped as Int8, produces an error message and returns 0.
    static func decode<T>(int8: Any, decoder: T) -> Int8 {
        if let int = int8 as? Int {
            if int < 128 && int > -129 { return Int8(int) }
        }
        HGReport.shared.decodeFailed(decoder, object: int8)
        return 0
    }
}
