//
//  ContentView.swift
//
//

import SwiftUI
import SwiftData
import LocalAuthentication
import PDFKit

struct ContentView: View {
    @State private var timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    @State private var loginTime: Date?
    @Environment(\.modelContext) var context
    @State private var isShowingItemSheet = false
    @Query(sort: \PCRecord.name, order: .forward)var pcrecords: [PCRecord]
    @State private var pcrecordToEdit: PCRecord?
    @State private var pcrecordToExport: PCRecord?
    @State private var text = "" //for error message
    @State private var isUnlocked = false //indicate authentication status
    @State private var showAlert = false //user aleart for unsucessful authentication
    @State private var showTimeOut = false //user aleart for unsucessful authentication
    @State private var failMsg = false //reminder message to user
    @State private var isExportcsv = false //indicate export request
    @State private var isExportConfirmcsv = false //indicate export confirmation status
    @State private var isExportpdf = false //indicate export request
    @State private var isExportConfirmpdf = false //indicate export confirmation status
    @State private var BCount = 0
    private let fnamecsv = NSHomeDirectory() + "/Documents/PassSecureExport.csv"
    private let fnamepdf = NSHomeDirectory() + "/Documents/PassSecureExport.pdf"
   
    
    
    init() { //configure navigation bar title style
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(red: 0.86, green: 0.24, blue: 0.00, alpha: 1.00), .font: UIFont(name: "ArialRoundedMTBold", size: 30)!]
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(red: 0.86, green: 0.24, blue: 0.00, alpha: 1.00), .
                                                            font: UIFont(name: "ArialRoundedMTBold", size: 20)!]
        navBarAppearance.backgroundColor = .clear
        navBarAppearance.backgroundEffect = .none
        navBarAppearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
    }
    
    var body: some View {
        
        NavigationStack {
            if isUnlocked {
                
             /*   let filePath = NSHomeDirectory() + "/Documents/PassSecureExport.pdf"
                let success = write(toFile: filePath)

                if success {
                    Text("PDF document successfully written to file: \(filePath)")
                } else {
                    Text("Failed to write PDF document to file: \(filePath)")
                }
            */
                
                List {
                    if !pcrecords.isEmpty {
                        HStack{
                            Text("Name")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.86, green: 0.24, blue: 0.00))
                            Spacer()
                            Spacer()
                            
                            Text ("Login")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.86, green: 0.24, blue: 0.00))
                        }
                    }
                    
                    ForEach(pcrecords) { pcrecord in //MARK: for loop
                        if pcrecord.name.contains(text) || text.isEmpty
                        {
                            PCRecordCell(pcrecord: pcrecord)
                                .onTapGesture {
                                    pcrecordToEdit = pcrecord
                                }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            context.delete(pcrecords[index])
                        }
                    }
                }
                .searchable(text: $text, prompt: "Search Name")
                
            /*   .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            // Perform action for the button
                            print("Button tapped")
                        }) {
                            Image(systemName: "gear")
                                .imageScale(.large)
                        }
                    }
                } */
                .navigationTitle("Pass Secure")
                .navigationBarTitleDisplayMode(.large)
                .sheet(isPresented: $isShowingItemSheet) { AddPCRecordSheet() }
                .sheet(isPresented: $isExportConfirmpdf) //MARK: activity sheet pop up
                {
                    ActivityView(activityItems: [URL(filePath: fnamepdf)]) //user to select how to save/handle the exported file
                }
                .sheet(item: $pcrecordToEdit) { pcrecord in
                    UpdatePCRecordSheet(pcrecord: pcrecord, originalName: pcrecord.name, originalLogin: pcrecord.login, originalPass: pcrecord.pass)
                }
                .toolbar {
                    if !pcrecords.isEmpty {
                        
                    /*    Button("Add Password", systemImage: "plus", role: .destructive) {
                            isShowingItemSheet = true
                        }*/
                        
                    /*    Button(role: .destructive, action: {isShowingItemSheet = true})
                        {
                            Image(systemName: "gear")
                                .imageScale(.large)
                                .foregroundColor(.red) // Set the color to red
                        } */
                        
                        
                       // ToolbarItem(placement: .navigationBarLeading) {
                                                Menu {
                                                    
                                                    Button{
                                                            //MARK: push content to txt file
                                                            for pcrecord in pcrecords {
                                                                let temp = ExportToTxT(pcrecord: pcrecord)
                                                                _=temp
                                                            }
                                                            
                                                            do {
                                                                try
                                                                String(ExportContent.myshare.ExportRecord).write( //convert the consolidated string content into a txt file
                                                                    toFile: fnamepdf,
                                                                    atomically: true,
                                                                    encoding: .utf8
                                                                )
                                                                print ("file created successfully")
                                                            }
                                                            catch {
                                                                print (error)
                                                            }
                                                            // ExportContent.myshare.ExportRecord = "NAME, LOGIN, PASS\n"  //re-initailize value
                                                            isExportpdf = true
                                                        
                                                    } label: { Label("Export (Plain CSV)", systemImage: "doc")}
                                                    
                                                    Button{
                                                            //MARK: push content to txt file
                                                            for pcrecord in pcrecords {
                                                                let temp = ExportToTxT(pcrecord: pcrecord)
                                                                _=temp
                                                            }
                                                            
                                                            do {
                                                                try
                                                                String(ExportContent.myshare.ExportRecord).write( //convert the consolidated string content into a txt file
                                                                    toFile: fnamepdf,
                                                                    atomically: true,
                                                                    encoding: .utf8
                                                                )
                                                                print ("file created successfully")
                                                            }
                                                            catch {
                                                                print (error)
                                                            }
                                                        // ExportContent.myshare.ExportRecord = "NAME, LOGIN, PASS\n"  //re-initailize value
                                                        isExportpdf = true
                                                        
                                                    } label: { Label("Export (Encrypted PDF)", systemImage: "lock.doc")}
                                                    Button{
                                                        BCount += 5
                                                    }
                                                label: {Label("About", systemImage: "info.square")}.symbolEffect(.bounce, value: BCount).font(.largeTitle)
                                                }
                    label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                            .foregroundColor(.red)
                    }
                    }
                
                }
                .overlay {
                    if pcrecords.isEmpty {
                        ContentUnavailableView(label: {
                            Label("No record", systemImage: "list.bullet.rectangle.portrait")
                        }, description: {
                            Text("Start adding Password record to see your list.")
                        }, actions: {
                            Button("Add Password") { isShowingItemSheet = true }
                        })
                        .offset(y: -60)
                    }
                }
                HStack
                {
                    Button{
                        BCount += 5
                    }
                label: {Label("About", systemImage: "info.square")}.symbolEffect(.bounce, value: BCount)
                    
                    if !pcrecords.isEmpty {
                        Button(role: .destructive, action: {isShowingItemSheet = true})
                        {
                            Text("Add")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        } }
                }
            } // the end of content protected by authentication
            
            else
            {
                if failMsg
                {
                    Spacer()
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    Text("Unable to authenticate")
                        .font(.title)
                        .foregroundColor(Color(red: 0.86, green: 0.24, blue: 0.00))
                    Text("\nPlease close the app and try again")
                        .font(.system(size: 12, weight: .light, design: .monospaced))
                        .foregroundColor(Color.gray)
                    Spacer()
                    Spacer()
                }
                if showTimeOut
                {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    Text("Session TimeOut")
                        .font(.title)
                        .foregroundColor(Color(red: 0.86, green: 0.24, blue: 0.00))
                    Text("\nPlease remember to close the app")
                        .font(.system(size: 12, weight: .light, design: .monospaced))
                        .foregroundColor(Color.gray)
                }
            }
        }
        .onReceive(timer) { _ in calculateUsageTime()}
        .onAppear(perform: authenticate) //authentication once view is loaded
        .alert(isPresented: $showAlert) {
            Alert( //user alert of failed authentication
                title: Text("Authentication Failed"),
                message: Text("Biometric or Passcode authentication failed."),
                dismissButton: .default(Text("OK"))
            )
        }
        
        .alert(isPresented: $isExportpdf) {
            Alert(title: Text("Alert"), message: Text("Content will be exported to a plain CSV file"),
                  primaryButton: .cancel(Text("Cancel")) {
                ExportContent.myshare.ExportRecord = "NAME, LOGIN, PASS\n"
            },
                  secondaryButton: .default(Text("OK")) {
                
                
                let filePath = NSHomeDirectory() + "/Documents/PassSecureExport.pdf"
                  let success = write(toFile: filePath)

                  if success {
                      Text("PDF document successfully written to file: \(filePath)")
                  } else {
                      Text("Failed to write PDF document to file: \(filePath)")
                  }
                ExportContent.myshare.ExportRecord = "NAME, LOGIN, PASS\n"
                ExportContent.myshare.RecordCount = 0
                isExportConfirmpdf = true
            }
            )
        }
    }
    
    //func createPasswordProtectedPDF() {

    func write(toFile path: String, withOptions options: [PDFDocumentWriteOption: Any]? = nil) -> Bool {
        // Create a new PDF document
        
        // let temp = ExportContent.myshare.ExportRecord
        let newlineCount = (ExportContent.myshare.ExportRecord+ExportContent.myshare.ExportRecord+ExportContent.myshare.ExportRecord+ExportContent.myshare.ExportRecord+ExportContent.myshare.ExportRecord+ExportContent.myshare.ExportRecord).reduce(0) { count, character in
            character == "\n" ? count + 1 : count
        }
        //print("number of line \(newlineCount)"
  
        var height: Int = 842
        if newlineCount>=50{ height = newlineCount*20 }
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: height)) // A4 paper size
   
        
        
        let data = pdfRenderer.pdfData { context in
            
            context.beginPage()
            
            
            let attributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)
            ]
            // adding text to pdf
            
            let text = ExportContent.myshare.ExportRecord+ExportContent.myshare.ExportRecord+ExportContent.myshare.ExportRecord+ExportContent.myshare.ExportRecord+ExportContent.myshare.ExportRecord+ExportContent.myshare.ExportRecord
            text.draw(at: CGPoint(x: 20, y: 50), withAttributes: attributes)
        
            // print("Number of newlines: \(newlineCount)")
        }
        
        guard let pdfDocument = PDFDocument(data: data)
        else {
            print("Failed to create PDF document")
            return false
        }
    
            // Add content to the PDF document (e.g., pages, annotations, etc.)
        
        // Write the PDF document to the specified file path
        do {
            try pdfDocument.write(to: URL(fileURLWithPath: path), withOptions: [PDFDocumentWriteOption.userPasswordOption : "pwd", PDFDocumentWriteOption.ownerPasswordOption : "pwd"])
            return true
        } catch {
            print("Error writing PDF document: \(error.localizedDescription)")
            return false
        }
        }
        
      
  //  }
    
    
    func authenticate() { //perform biometric authentication
        let context = LAContext()
        var error: NSError?
        
        // Check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            // Biometric authentication is possible, so go ahead and use it
            let reason = "For user authentication"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                // Authentication has now completed
                if success {
                    // Authenticated successfully
                    isUnlocked = true
                    loginTime = Date() // record login time
                } else {
                    // Check for fallback mechanism (passcode authentication)
                    if let error = authenticationError as NSError?,
                       error.code == LAError.userFallback.rawValue { //user passcode instead of biometric method
                        // Fallback to passcode authentication
                        authenticateWithPasscode()
                    } else if let error = authenticationError as NSError?,
                              error.code == LAError.userCancel.rawValue {
                        // Authentication cancelled by the user
                        // Handle cancellation here (e.g., show a message or perform an action)
                        print("Authentication cancelled by the user")
                        showAlert = true
                        failMsg = true
                    } else {
                        // Authentication failed
                        showAlert = true
                        failMsg = true
                    }
                }
            }
        } else if let error = error {
            // Handle error from canEvaluatePolicy(_:error:)
            print("Biometric authentication not available: \(error.localizedDescription)")
        } else {
            // Fallback to passcode authentication
            authenticateWithPasscode()
        }
    }
    
    func calculateUsageTime() {
        guard let loginTime = loginTime else { return }
        
        let now = Date()
        let useageTime = loginTime.distance(to: now) //calculate the time of use
        if Int(useageTime) > 300 //set session time of 5 mins, in second
        {
            showTimeOut = true //pop up the alert message
            isUnlocked = false // remove protected content and reset authentication status
            timer.upstream.connect().cancel() // stop the timer
        }
    }
    
    func authenticateWithPasscode() {
        // Prompt the user to enter their device passcode
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Enter your passcode") { success, authenticationError in
                if success {
                    // Authenticated successfully
                    isUnlocked = true
                    loginTime = Date()
                } else {
                    // Check for cancellation
                    if let error = authenticationError as NSError?,
                       error.code == LAError.userCancel.rawValue {
                        // Authentication cancelled by the user
                        // Handle cancellation here (e.g., show a message or perform an action)
                        print("Authentication cancelled by the user")
                        showAlert = true
                        failMsg = true
                    } else {
                        // Authentication failed
                        showAlert = true
                        failMsg = true
                    }
                }
            }
        } else if let error = error {
            // Handle error from canEvaluatePolicy(_:error:)
            print("Passcode authentication not available: \(error.localizedDescription)")
        } else {
            // Passcode authentication not possible
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PCRecord.self)
}

struct ExportToTxT
{
    let pcrecord: PCRecord
    init(pcrecord: PCRecord){
        self.pcrecord = pcrecord
        exporting()
    }
    
    func exporting() -> Void{ //consolidate stored data into a string
        ExportContent.myshare.ExportRecord += pcrecord.name + ", "
        ExportContent.myshare.ExportRecord += pcrecord.login + ", "
        ExportContent.myshare.ExportRecord += pcrecord.pass + "\n"
        ExportContent.myshare.RecordCount += 1
    }
}

struct PCRecordCell: View {
    let pcrecord: PCRecord
    var body: some View {
        HStack {
            Text(pcrecord.name)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(Color.gray)
            Spacer()
            Text(pcrecord.login)
                .font(.system(size: 14, weight: .light, design: .default))
        }
    }
}

struct AddPCRecordSheet: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var login: String = ""
    @State private var pass: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Login", text: $login)
                TextField("Passcode", text: $pass)
            }
            .navigationTitle("New Pascode")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        let pcrecord = PCRecord(name: name, login: login, pass: pass)
                        context.insert(pcrecord) //insert new record in swiftdata
                        dismiss()
                    }
                }
            }
        }
    }
}

struct UpdatePCRecordSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var pcrecord: PCRecord
    @State var originalName: String
    @State var originalLogin: String
    @State var originalPass: String
    
    func undoChange() { //in case user wants to undo changes
        pcrecord.name = originalName
        pcrecord.login = originalLogin
        pcrecord.pass = originalPass
    }
    
    var body: some View {
        NavigationStack {
            Form {
                HStack{
                    Text("Name : ")
                        .font(.system(size: 14, weight: .light, design: .default))
                        .foregroundColor(Color.gray)
                    TextField("Name", text: $pcrecord.name)
                }
                
                HStack{
                    Text("Login : ")
                        .font(.system(size: 14, weight: .light, design: .default))
                        .foregroundColor(Color.gray)
                    TextField("Login", text: $pcrecord.login)
                }
                
                HStack{
                    Text("Pass : ")
                        .font(.system(size: 14, weight: .light, design: .default))
                        .foregroundColor(Color.gray)
                    TextField("Passcode", text: $pcrecord.pass)
                }
            }
            .navigationTitle("Update Passcode")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Undo") {
                        undoChange() //reset to original value
                    }
                    .buttonStyle(DefaultButtonStyle())
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
