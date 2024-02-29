//
//
//
//
//  swiftdata related code is inspired by example "SwiftDataExample" by Sean Allen on 9/27/23


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
