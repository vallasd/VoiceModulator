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

/// HGReport is used to create generic error messaging throughout the app.  User may turn on or off specific message types.  Used to create uniformity in message reporting.
struct HGReport {
    
    static var shared = HGReport()
    
    var isOn = true
    let hgReportHandlerInfo = true
    let hgReportHandlerWarn = true
    let hgReportHandlerError = true
    let hgReportHandlerAlert = true
    let hgReportHandlerAssert = true
    
    func report(_ msg: String, type: HGErrorType) {
        if !isOn { return }
        switch (type) {
        case .info:    if hgReportHandlerInfo == false { return }
        case .warn:    if hgReportHandlerWarn == false { return }
        case .error:   if hgReportHandlerError == false { return }
        case .alert:   if hgReportHandlerAlert == false { return }
        case .assert:
            if hgReportHandlerAssert == false { return }
            let report = "[\(type.string)] " + msg
            assert(true, report)
        }
        let report = "[\(type.string)] " + msg
        print(report)
    }
    
    func optionalFailed<T>(_ decoder: T, object: Any?, returning: Any?) {
        HGReport.shared.report("Optional: |\(String(describing: object))| is not |\(decoder)| mapable, returning: |\(String(describing: returning))|", type: .error)
    }
    
    func mappingFailed<T>(_ decoder: T, object: Any?, returning: Any?) {
        HGReport.shared.report("|\(decoder)| |MAPPING FAILED| object: |\(String(describing: object))|, returning: |\(String(describing: returning))|", type: .error)
    }
    
    func defaultsFailed<T>(_ decoder: T, key: String) {
        HGReport.shared.report("|\(decoder)| |DEFAULTS RETRIEVAL FAILED| invalid key: |\(key)|", type: .error)
    }
    
    func decodeFailed<T>(_ decoder: T, object: Any) {
        HGReport.shared.report("|\(decoder)| |DECODING FAILED| not mapable object: |\(object)|", type: .error)
    }
    
    func setDecodeFailed<T>(_ decoder: T, object: Any) {
        HGReport.shared.report("|\(decoder)| |DECODING FAILED| not inserted object: |\(object)|", type: .error)
    }
    
    func notMatching(_ object: Any, object2: Any) {
        HGReport.shared.report("|\(object)| is does not match |\(object2)|", type: .error)
    }
    
    func insertFailed<T>(set: T, object: Any) {
        HGReport.shared.report("|\(set)| |INSERT FAILED| object: \(object)", type: .error)
    }
    
    func deleteFailed<T>(set: T, object: Any) {
        HGReport.shared.report("|\(set)| |DELETE FAILED| object: \(object)", type: .error)
    }
    
    func getFailed<T>(set: T, keys: [Any], values: [Any]) {
        HGReport.shared.report("|\(set)| |GET FAILED| for keys: |\(keys)| values: |\(values)|", type: .error)
    }
    
    func updateFailed<T>(set: T, key: Any, value: Any) {
        HGReport.shared.report("|\(set)| |UPDATE FAILED| for key: |\(key)| not valid value: |\(value)|", type: .error)
    }
    
    func updateFailedGeneric<T>(set: T) {
        HGReport.shared.report("|\(set)| |UPDATE FAILED| nil object returned, possible stale objects", type: .error)
    }
    
    func usedName<T>(decoder: T, name: String) {
        HGReport.shared.report("|\(decoder)| |USED NAME| name: |\(name)| already used", type: .error)
    }
    
    func noEntities<T>(decoder: T) {
        HGReport.shared.report("|\(decoder)| |NO ENTITIES|", type: .error)
    }
    
    func validateFailed<T,U>(decoder: T, value: Any, key: Any, expectedType: U) {
        HGReport.shared.report("|\(decoder)| |VALIDATION FAILED| for key: |\(key)| value: |\(value)| expected type: |\(expectedType)|", type: .error)
    }
}


