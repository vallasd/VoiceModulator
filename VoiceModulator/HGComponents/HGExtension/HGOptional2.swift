
import Foundation
import CoreData

//extension Optional where .Some == HGPrimitiveEncodable {
//    
//}

extension Optional {
    
    var importFileType: ImportFileType {
        if let int = self as? Int { return ImportFileType.create(int: int) }
        HGReport.shared.report("optional: |\(String(describing: self))| is not an ImportFileType mapable, using .XCODE_XML", type: .error)
        return .xcode_XML
    }
    
    var interval: TimeInterval {
        if let interval = self as? Double { return interval }
        HGReport.shared.report("optional: |\(String(describing: self))| is not NSTimeInterval mapable, using 0", type: .error)
        return 0
    }
    
    var int16: Int16 {
        if let int = self as? Int {
            if abs(int) > Int(Int16.max) { return Int16(int) }
        }
        HGReport.shared.report("optional: |\(String(describing: self))| is not Int16 mapable, using 0", type: .error)
        return 0
    }
    
    var int32: Int32 {
        if let int = self as? Int {
            if abs(int) > Int(Int32.max) { return Int32(int) }
        }
        HGReport.shared.report("optional: |\(String(describing: self))| is not Int32 mapable, using 0", type: .error)
        return 0
    }
    
    var stringArray: [String] {
        if let array = self as? [String] { return array }
        if let string = self as? String {
            if string == "" { return [] }
            let strings = string.components(separatedBy: " ")
            return strings
        }
        HGReport.shared.report("optional: |\(String(describing: self))| is not [String] mapable, using Empty [String]", type: .error)
        return []
    }
    
    var stringSet: Set<String> {
        if let set = self as? Set<String> { return set }
        if let array = self as? [String] {
            var set: Set<String> = []
            for a in array {
                set.insert(a)
            }
            return set
        }
        HGReport.shared.report("optional: |\(String(describing: self))| is not Set<String> mapable, using Empty [String]", type: .error)
        return []
    }
    
    var intArray: [Int] {
        if let array = self as? [Int] { return array }
        HGReport.shared.report("optional: |\(String(describing: self))| is not [Int] String mapable, using Empty [Int]", type: .error)
        return []
    }
}
