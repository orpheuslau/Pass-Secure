//
//
//
//
//  


import Foundation
import SwiftData

@Model
class PCRecord {
    var name = ""
    var login = ""
    var pass = ""
    
    init(name: String, login: String, pass: String) {
        self.name = name
        self.login = login
        self.pass = pass
    }
}
