//
//  ExportContent.swift
//  Pass Secure
//
//  

import Foundation

class ExportContent {
    var ExportRecord: String = ""
    static let myshare = ExportContent(ExportRecord: "NAME, LOGIN, PASS\n")
    
    init(ExportRecord: String) {
        self.ExportRecord = ExportRecord
    }        
}

