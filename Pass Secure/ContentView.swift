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
    @State private var isExport = false //indicate export request
    @State private var isExportcsv = false //indicate export request
    @State private var isExportConfirmcsv = false //indicate export confirmation status
    @State private var isExportpdf = false //indicate export request
    @State private var isExportpdf2 = false //indicate export request
    @State private var isExportConfirmpdf = false //indicate export confirmation status
    @State private var BCount = 0
    @State private var isShowingPopup = false
    private let fnamecsv = NSHomeDirectory() + "/Documents/PassSecureExport.csv"
    private let fnamepdf = NSHomeDirectory() + "/Documents/PassSecureExport.pdf"
    @State private var fname = ""
    @State var Encrypass:String = ""
    @State var ReEncrypass:String = ""
    @State private var bbb = false
    @State var BoxMsg = ""

    
    
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
                .navigationTitle("Pass Secure")
                .navigationBarTitleDisplayMode(.large)
                .sheet(isPresented: $isShowingItemSheet) { AddPCRecordSheet() }
                .sheet(isPresented: $isExportConfirmcsv)
                {
                    ActivityView(activityItems: [URL(filePath: NSHomeDirectory()  + "/Documents/PassSecureExport.csv")]) //user to select how to handle the exported csv file
                }
                .sheet(isPresented: $isExportConfirmpdf)
                {
                    ActivityView(activityItems: [URL(filePath: NSHomeDirectory()  + "/Documents/PassSecureExport.pdf")]) //user to select how to handle the exported pdf file
                }
                .sheet(item: $pcrecordToEdit) { pcrecord in
                    UpdatePCRecordSheet(pcrecord: pcrecord, originalName: pcrecord.name, originalLogin: pcrecord.login, originalPass: pcrecord.pass)
                }
                .toolbar {
                    if !pcrecords.isEmpty {
                        Menu { //MARK: menu
                            
                            Button{
                                self.isExportpdf = true // export as encrypted pdf
                            }
                        label: { Label("Export (Encrypted PDF)", systemImage: "lock.doc")}
                            
                            Button{
                                self.isExportcsv = true //export as csv
                                exportContent()
                            } label: { Label("Export (Plain CSV)", systemImage: "doc")}
                            
                            
                            Button{
                            }
                        label: {Label("About", systemImage: "info.square")}
                        }
                    label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                            .foregroundColor(.red)
                    }
                    }
                    
                }.alert("Encryption Key", isPresented: $isExportpdf) { //MARK: pop up box 1
                    
                    SecureField("Enter Key", text: $Encrypass)
                    SecureField("Re-enter Key", text: $ReEncrypass)
                    Button("Cancel", role:. cancel) {}
                    Button("Submit") {
                        
                        
                        if (Encrypass=="" && ReEncrypass=="")
                        {
                            self.isExportpdf2 = true
                            BoxMsg = "Fields cannot be empty"
                        }
                        else
                        if (Encrypass=="" || ReEncrypass=="")
                        {
                            self.isExportpdf2 = true
                            BoxMsg = "Fields cannot be empty"
                        }
                        else
                        if (Encrypass != ReEncrypass)
                        {
                            BoxMsg = "Key mismatch"
                            Encrypass=""
                            ReEncrypass=""
                            isExportpdf2 = true
                        }
                        else
                        if (Encrypass==ReEncrypass)
                        {
                            ExportContent.myshare.Encrypass = Encrypass
                            exportContent()
                            Encrypass=""
                            ReEncrypass=""
                            BoxMsg=""
                        }
                    }
                }
            message: {
                Text(BoxMsg)
            }
                
            .alert("Encryption Key", isPresented: $isExportpdf2) { //MARK: pop up box 2
                
                SecureField("Enter Key", text: $Encrypass)
                SecureField("Re-enter Key", text: $ReEncrypass)
                Button("Cancel", role:. cancel) {}
                Button("Submit") {
                    
                    if (Encrypass=="" && ReEncrypass=="")
                    {
                        self.isExportpdf = true
                        BoxMsg = "Fields cannot be empty"
                    }
                    else
                    if (Encrypass=="" || ReEncrypass=="")
                    {
                        self.isExportpdf = true
                        BoxMsg = "Fields cannot be empty"
                    }
                    else
                    if (Encrypass != ReEncrypass)
                    {
                       BoxMsg = "Key mismatch"
                        Encrypass=""
                        ReEncrypass=""
                        isExportpdf = true
                    }
                    else
                        if (Encrypass==ReEncrypass)
                        {
                            ExportContent.myshare.Encrypass = Encrypass
                        Encrypass=""
                        ReEncrypass=""
                        exportContent()
                        BoxMsg=""
                        }
                }
            }
        message: {
            Text(BoxMsg)
        }
                
                .overlay {
                    if pcrecords.isEmpty {
                        ContentUnavailableView(label: {
                            Label("No record", systemImage: "list.bullet.rectangle.portrait")
                        }, description: {
                            Text("Start adding Password record to see your list.")
                        }, actions: {
                            Button{ isShowingItemSheet = true }
                        label: {Label("Create new record", systemImage:"pencil.tip.crop.circle.badge.plus")}
                        })
                        .offset(y: -60)
                    }
                }
                HStack
                {
                   
                    if !pcrecords.isEmpty {
                        Button(role: .destructive, action: {isShowingItemSheet = true})
                        {
                            Text("New record")
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
       
      /*  .alert(isPresented: $isExportcsv) {
            Alert(title: Text("Alert"), message: Text("Content will be exported to a plain CSV file"),
                  primaryButton: .cancel(Text("Cancel")) {
            
            },
                  secondaryButton: .default(Text("OK")) {
                
                for pcrecord in pcrecords { //push all content into myshare
                    let temp = ExportToMyshare(pcrecord: pcrecord)
                    _=temp
                }
                
                if isExportcsv {
                    fname = NSHomeDirectory() + "/Documents/PassSecureExport.csv"
                }
                
                if isExportpdf {
                    fname = NSHomeDirectory() + "/Documents/PassSecureExport.pdf"
                }
                
                do {
                    try
                    String(ExportContent.myshare.ExportRecord).write( // write the consolidated string content into a file
                        
                        toFile: fname,
                        atomically: true,
                        encoding: .utf8
                    )
                    print ("file created successfully, paht is \(fname)")
                }
                catch {
                    print (error)
                }
                
                if isExportcsv {
                    isExportConfirmcsv = true
                }
                
                if isExportpdf {
                    _ = write(toFile: fname)
                    
                    isExportConfirmpdf = true
                }
                
                ExportContent.myshare.ExportRecord = "NAME, LOGIN, PASS\n" // re-initialize
                ExportContent.myshare.RecordCount = 0
                isExport = false
                isExportcsv = false
                isExportpdf = false
            }
            )
        }*/
    }
    
    //func createPasswordProtectedPDF() {
    

    

    func write(toFile path: String, withOptions options: [PDFDocumentWriteOption: Any]? = nil) -> Bool {
        // Create a new PDF document
        
        let newlineCount = (ExportContent.myshare.ExportRecord.reduce(0) { count, character in
            character == "\n" ? count + 1 : count})
        
        var height: Int = 842 // default height as A4 paper
        if newlineCount>=50{ height = newlineCount*20 }
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: height)) // increase the height in proportion to number of record

        let data = pdfRenderer.pdfData { context in
            
            context.beginPage() //create a new pdf page
            
            let attributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)
            ]
            // adding text to pdf
            
            let text = ExportContent.myshare.ExportRecord
            text.draw(at: CGPoint(x: 20, y: 50), withAttributes: attributes)
        }
        
        guard let pdfDocument = PDFDocument(data: data)
        else {
            print("Failed to create PDF document")
            return false
        }
        
        
        // Write the PDF document to the specified file path
        if pdfDocument.write(to: URL(fileURLWithPath: path), withOptions: [PDFDocumentWriteOption.userPasswordOption : ExportContent.myshare.Encrypass, PDFDocumentWriteOption.ownerPasswordOption : ExportContent.myshare.Encrypass])
        {return true }
        else { return false}
    }
    
      
  //  }
    func exportContent()
    {
      
      for pcrecord in pcrecords { //push all content into myshare
          let temp = ExportToMyshare(pcrecord: pcrecord)
          _=temp
      }
      
      if isExportcsv {
          fname = NSHomeDirectory() + "/Documents/PassSecureExport.csv"
      }
      
        print(isExportpdf)
      if isExportpdf {
          fname = NSHomeDirectory() + "/Documents/PassSecureExport.pdf"
          
      }
      
      do {
          try
          String(ExportContent.myshare.ExportRecord).write( // write the consolidated string content into a file
              toFile: fname,
              atomically: true,
              encoding: .utf8
          )
          print ("file created successfully, path is \(fname)")
      }
      catch {
          print (error)
      }
      
      if isExportcsv {
          isExportConfirmcsv = true
      }
      
      if isExportpdf {
          _=write(toFile: fname) //function creates pdf
          isExportConfirmpdf = true
      }
      
      ExportContent.myshare.ExportRecord = "NAME, LOGIN, PASS\n" // re-initialize
      ExportContent.myshare.RecordCount = 0
     // isExport = false
      isExportcsv = false
      isExportpdf = false
  }
    
    
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

/*
#Preview {
    ContentView()
        .modelContainer(for: PCRecord.self)
              
}
       */

struct ExportToMyshare
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




struct AppPage: View {
    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            
            Text("Pass Secure")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text("Welcome to My Awesome App! This app is designed to make your life easier and more enjoyable. With a user-friendly interface and a wide range of features, it's the perfect companion for your daily tasks.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 10)
            
            Button(action: {
                // Handle button action here
            }) {
                Text("Get Started")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 30)
        }
        .padding()
    }
}

struct AppPage_Previews: PreviewProvider {
    static var previews: some View {
        AppPage()
    }
}
