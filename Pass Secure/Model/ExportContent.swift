//
//  ExportContent.swift
//  Pass Secure
//
//  

import Foundation

class ExportContent {
    var ExportRecord: String = ""
    var RecordCount: Int = 0
    static let myshare = ExportContent(ExportRecord: "NAME, LOGIN, PASS\n", RecordCount: 0)
    
    init(ExportRecord: String, RecordCount: Int) {
        self.ExportRecord = ExportRecord
        self.RecordCount = RecordCount
    }
}

