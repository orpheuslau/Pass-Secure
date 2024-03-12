//
//  ExportContent.swift
//  Pass Secure
//
//  

import Foundation

class ExportContent {
    var ExportRecord: String = ""
    var RecordCount: Int = 0
    var Encrypass: String = ""
    static let myshare = ExportContent(ExportRecord: "NAME, LOGIN, PASS\n", RecordCount: 0, Encrypass: "")
    
    init(ExportRecord: String, RecordCount: Int, Encrypass: String) {
        self.ExportRecord = ExportRecord
        self.RecordCount = RecordCount
        self.Encrypass = Encrypass
    }
}

