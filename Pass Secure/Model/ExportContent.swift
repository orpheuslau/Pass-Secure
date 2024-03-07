//
//  ExportContent.swift
//  Pass Secure
//
//  Created by Omon 3 on 6/3/2024.
//

import Foundation

class ExportContent {
       
    var ExportRecord: String = ""
    
    static let myshare = ExportContent(ExportRecord: "NAME, LOGIN, PASS\n")
    
    init(ExportRecord: String) {
        self.ExportRecord = ExportRecord
    }
    
    
}

