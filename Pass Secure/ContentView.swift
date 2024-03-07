//
//  ContentView.swift
//
//
//  swiftdata related code is inspired by example "SwiftDataExample" by Sean Allen on 9/27/23
//  biometic authenticaion related code is inspired by Paul Hudson
//  passcode authenticaion related code is inspired from web information

import SwiftUI
import SwiftData
import LocalAuthentication


struct ContentView: View {
    @Environment(\.modelContext) var context
    @State private var isShowingItemSheet = false
    @Query()
    var pcrecords: [PCRecord]
   // static var myexporting = ExportContent(name: "", login: "", pass: "")
    @State private var pcrecordToEdit: PCRecord?
    @State private var text = "" //for error message
    @State private var isUnlocked = false //indicate authentication status
    @State private var showAlert = false //user aleart for unsucessful authentication
    @State private var failMsg = false //reminder message to user
    @State private var isLogout = false //indicate logout status
    @State private var isExport = false //indicate logout status
    private let fname = NSHomeDirectory() + "/Documents/abcdedf.txt"
    
  //  private let fname =  "\(URL.documentsDirectory) + /Documents/message.txt"
    static var defaultText: String =  "this is it"
    
    
    
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
                           // let wtf = exportRecord(pcrecord: pcrecord)
                     //
                           // let wtf = myexporting.jointo(name: pcrecord.name)
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
                .sheet(isPresented: $isExport)
                {
                    ActivityView(activityItems: [ExportContent.myshare.ExportRecord])
                    
                    
                }
                
                
                
                
                .sheet(item: $pcrecordToEdit) { pcrecord in
                    UpdatePCRecordSheet(pcrecord: pcrecord, originalName: pcrecord.name, originalLogin: pcrecord.login, originalPass: pcrecord.pass)
                }
                .toolbar {
                    if !pcrecords.isEmpty {
                        
                        Button("Add Passcode", systemImage: "plus", role: .destructive) {
                            isShowingItemSheet = true
                        }
                    }
                }
                
                .overlay {
                    if pcrecords.isEmpty {
                        ContentUnavailableView(label: {
                            Label("No record", systemImage: "list.bullet.rectangle.portrait")
                        }, description: {
                            Text("Start adding Passcode to see your list.")
                        }, actions: {
                            Button("Add Passcode") { isShowingItemSheet = true }
                        })
                        .offset(y: -60)
                    }
                }
                Button(action: {
                    isUnlocked = false // remove protected content and reset authentication status
                    isLogout = true // logout status
                }) {
                    Text("Logout")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button("Export"){ //MARK: export
                    
                    
                /*    let csvData = "Column 1,Column 2,Column 3\nRow 1,Cell 1,Cell 2\nRow 2,Cell 3,Cell 4"

                    // Create a file manager
                    let fileManager = FileManager.default

                    // Create a file URL for the CSV file
                    let fileURL = URL(fileURLWithPath: fname)

                    // Write the CSV data to the file
                    do {
                        try csvData.write(to: fileURL, atomically: true, encoding: .utf8)
                    } catch {
                        print("Error writing CSV data to file: \(error)")
                    }*/
                    
                    
                   // isExport = true
                    
                                                          
                 

                    
                    
                    
                    /*let fileName = "myFileName.txt" // Your File Name
                    var filePath = "" // Your file path
                    let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)

                    if dirs.count > 0 {
                       let dir = dirs[0] //documents directory
                       filePath = dir.appending("/" + fileName)
                       print("Local path = \(filePath)")
                    } else {
                       print("Could not find local directory to store file")
                    }*/
                    
                    do {
                        try
                       
                        String(ExportContent.myshare.ExportRecord).write(
                            toFile: fname,
                            atomically: true,
                            encoding: .utf8
                        )
                        print ("file created successfully")
                    }
                    catch {
                        print (error)
                    }
                }
                ShareLink(item: URL(filePath: fname))
                Spacer()
            } // the end of content protected by authentication
            
            else
            {
                if failMsg
                {
                    Spacer()
                    Image("logo") // Replace "imageName" with the name of your image asset
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
                
                if isLogout
                {
                    Image("logo") // Replace "imageName" with the name of your image asset
                                   .resizable()
                                   .aspectRatio(contentMode: .fit)
                                   .frame(width: 100, height: 100)
                    Text("You've been logged out")
                        .font(.title)
                        .foregroundColor(Color(red: 0.86, green: 0.24, blue: 0.00))
                    Text("\nPlease remember to close the app for security reason")
                        .font(.system(size: 12, weight: .light, design: .monospaced))
                        .foregroundColor(Color.gray)
                }
            }
        }
        .onAppear(perform: authenticate) //authentication once view is loaded
        .alert(isPresented: $showAlert) {
            Alert( //user alert of failed authentication
                title: Text("Authentication Failed"),
                message: Text("Biometric or Passcode authentication failed."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    

    
    func authenticate() {
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
    
    func authenticateWithPasscode() {
        // Prompt the user to enter their device passcode
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Enter your passcode") { success, authenticationError in
                if success {
                    // Authenticated successfully
                    isUnlocked = true
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
   // ContentView()
    ContentView()
        
}


struct exportRecord {
    let pcrecord: PCRecord
    var temp: String // Define temp as a property of type String
    var temp2: String = ""

    init(pcrecord: PCRecord) {
        self.pcrecord = pcrecord
        self.temp = pcrecord.login // Initialize temp with the value of pcrecord.login
        self.temp2 += self.temp
            printout()
    }
    
    func printout()
    {
               
        print(self.temp+self.temp2)
    }
}

struct testcall {
    @Environment(\.modelContext) var context
    @Query()
    var pcrecords: [PCRecord]
    
        
    func testout(){
        
        ForEach(pcrecords) { pcrecord in //MARK: for loop
        Text(pcrecord.login)
        }
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
            let www = exporting()
           
        }
    }
    
    func exporting()
    {
        print(pcrecord.login)
       
        ExportContent.myshare.ExportRecord += pcrecord.name + ", "
        ExportContent.myshare.ExportRecord += pcrecord.login + ", "
        ExportContent.myshare.ExportRecord += pcrecord.pass + "\n"
        // myexporting.login = pcrecord.login
        ///print("wtf \(ExportContent.myshare.name = "fdsafd")")
        //ExportContent.myshare.name = "zzzzz"
        //print("wtf2 \(ExportContent.myshare.name)")
        
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
