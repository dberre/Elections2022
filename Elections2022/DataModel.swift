//
//  DataModel.swift
//  Elections2022
//
//  Created by Dominique Berre on 29/06/2022.
//

import Foundation
import TabularData

struct CandidateResult {
    let name: String
    let group: String
    let votes: Int
    let votesVsExpr: Double
}

struct PoolingResult: Identifiable {
    var id: String { "\(department)-\(cityName)" }
    let department: String
    let circoCode: Int
    let cityName: String
    let votants: Int
    let abstention: Double
    
    let results: [CandidateResult]
}

final class DataModel: ObservableObject {

    enum LoadingState {
        case idle
        case loading
        case error(String)
        case complete
    }

    @Published var state = LoadingState.idle

    private var dataFrame: DataFrame? = nil
            
    private let fileUrl = Bundle.main.url(forResource: "Resultats2eFull", withExtension: "csv")!
    
    // defines all the coulumns to extract from the CSV file (which contains much more)
    // The string is the Header text in the CSV file. The type is the decoding type
    private let deptNumID = ColumnID("DeptNum", String.self)
    private let deptNameID = ColumnID("DeptName", String.self)
    private let deptID = ColumnID("Dept", String.self)
    private let circoCodeID = ColumnID("CircoCode", Int.self)
    private let cityNameID = ColumnID("CityName", String.self)
    private let inscritsID = ColumnID("Inscrits", String.self)
    private let absPercentID  = ColumnID("AbsPercent", Double.self)
    private let exprID = ColumnID("Expr", Int.self)
    private let nom1ID = ColumnID("Nom1", String.self)
    private let nuance1ID = ColumnID("Nuance1", String.self)
    private let voix1ID = ColumnID("Voix1", Int.self)
    private let voixVsExp1ID  = ColumnID("VoixVsExp1", Double.self)
    private let nom2ID = ColumnID("Nom2", String.self)
    private let nuance2ID = ColumnID("Nuance2", String.self)
    private let voix2ID = ColumnID("Voix2", Int.self)
    private let voixVsExp2ID  = ColumnID("VoixVsExp2", Double.self)
    private let nom3ID = ColumnID("Nom3", String.self)
    private let nuance3ID = ColumnID("Nuance3", String.self)
    private let voix3ID = ColumnID("Voix3", Int.self)
    private let voixVsExp3ID  = ColumnID("VoixVsExp3", Double.self)

    // defines an array of columns names. Used only by DataFrame() for reading the CSV
    private var columns: [String] { [
        deptNumID.name,
        deptNameID.name,
        circoCodeID.name,
        cityNameID.name,
        inscritsID.name,
        absPercentID.name,
        exprID.name,
        nom1ID.name,
        nuance1ID.name,
        voix1ID.name,
        voixVsExp1ID.name,
        nom2ID.name,
        nuance2ID.name,
        voix2ID.name,
        voixVsExp2ID.name,
        nom3ID.name,
        nuance3ID.name,
        voix3ID.name,
        voixVsExp3ID.name
    ]}
    
    // this method return a list of all the entries from the CSV file
    // an entry is a triple (department, circo, city)
    func entries() -> [(department: String, circo: Int, city: String)] {
        guard let dataFrame = dataFrame else { return [] }

        return dataFrame.rows.map { row in
            (row[deptID]!, row[circoCodeID]!, row[cityNameID]!)
        }
    }
    
    var departments: [String] {
        guard let dataFrame = dataFrame else { return [] }
        
        // extract the department column to a array of Strings
        let df = dataFrame[deptID.name].compactMap { dept in
            (dept as? String)
        }
        
        // remove duplicates and return a sorted array
        return Array(Set(df)).sorted()
    }
    
    func cities(for department: String?) -> [String] {
        guard let dataFrame = dataFrame else { return [] }
        guard let department = department else { return [] }
        
        // first filter on the department and then extract the city to an array of Strings
        return dataFrame
            .filter(on: deptID.name, String.self) { dept in
                dept == department
            } ["CityName"].map { name in
                name as? String ?? ""
            }
    }
    
    func circos(for department: String) -> [Int] {
        guard let dataFrame = dataFrame else { return [] }
        
        // first filter on the department and then extract the circo to an array of Strings
        let result = dataFrame
            .filter(on: deptID.name, String.self) { dept in
                dept == department
            } ["CircoCode"].map { name in
                name as? Int ?? 0
            }
        // remove duplicates and return a sorted array
        return Array(Set(result)).sorted()
    }
        
    func arrayOfResult(for row: DataFrame.Row) -> [CandidateResult] {
        var ar = [CandidateResult]()
        ar.append(CandidateResult(name: row[nom1ID]!, group: row[nuance1ID]!, votes: row[voix1ID]!, votesVsExpr: row[voixVsExp1ID]!))
        if (row[nom2ID] != nil) {
            ar.append(CandidateResult(name: row[nom2ID]!, group: row[nuance2ID]!, votes: row[voix2ID]!, votesVsExpr: row[voixVsExp2ID]!))
            if (row[nom3ID] != nil) {
                ar.append(CandidateResult(name: row[nom3ID]!, group: row[nuance3ID]!, votes: row[voix3ID]!, votesVsExpr: row[voixVsExp3ID]!))
            }
        }
        return ar
    }
    
    func result(department: String?, city: String?) -> [PoolingResult] {
        guard let dataFrame = dataFrame else { return [] }

        guard let department = department, let city = city else { return [ ] }
        
        return dataFrame
            .filter(on: deptID.name, String.self) { dept in
                dept == department
            }.filter(on: cityNameID.name, String.self) { value in
                value == city
            }
            .rows.map { row in
                PoolingResult(
                    department: department,
                    circoCode: 2,
                    cityName: "",
                    votants: row[exprID]!,
                    abstention: row[absPercentID]!,
                    results: arrayOfResult(for: row)
                )
            }
    }

    func result(department: String?, circoCode: Int?) -> [PoolingResult] {
        guard let dataFrame = dataFrame else { return [] }

        guard let department = department, let circoCode = circoCode else { return [ ] }
                
        return dataFrame
            .filter(on: deptID.name, String.self) { dept in
                dept == department
            }.filter(on: circoCodeID.name, Int.self) { value in
                value == circoCode
            }
            .rows.map { row in
                PoolingResult(
                    department: department,
                    circoCode: circoCode,
                    cityName: row[cityNameID]!,
                    votants: row[exprID]!,
                    abstention: row[absPercentID]!,
                    results: arrayOfResult(for: row)
                )
            }
    }
    
    func loadAsync(completion: @escaping (DataModel.LoadingState) -> Void) {
        state = .loading
        
        DispatchQueue.global().async {
            let result = self.loadCsv(self.fileUrl)
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.dataFrame = data
                    self.state = .complete
                case .failure(let error):
                    self.dataFrame = nil
                    self.state = .error(error.message)
                }
                completion(self.state)
            }
        }
    }
    
    func loadSync() throws {
        let result = loadCsv(fileUrl)
        switch result {
        case .success(let data):
            self.dataFrame = data
        case .failure(let error):
            throw LoadFileError(message: "failed to load the url: \(fileUrl.absoluteString). \(error.message)")
        }        
    }
    
    // Defines the type of the Error reported when reading the CSV fails
    private struct LoadFileError: Error {
        let message: String
    }
            
    private func loadCsv(_ url: URL) -> Result<DataFrame, LoadFileError> {
        
        // define the columns type (for speeding up parsing and raise early types errors)
        let types: [String: CSVType] = [
            deptNumID.name: .string,
            deptNameID.name: .string,
            circoCodeID.name: .integer,
            cityNameID.name: .string,
            inscritsID.name: .integer,
            absPercentID.name: .string,
            exprID.name: .integer,
            nom1ID.name: .string,
            nuance1ID.name: .string,
            voix1ID.name: .integer,
            voixVsExp1ID.name: .string,
            nom2ID.name: .string,
            nuance2ID.name: .string,
            voix2ID.name: .integer,
            voixVsExp2ID.name: .string,
            nom3ID.name: .string,
            nuance3ID.name: .string,
            voix3ID.name: .integer,
            voixVsExp3ID.name: .string
        ]
        
        // defines some options to successfully read the CSV file
        let options = CSVReadingOptions(
            hasHeaderRow: true,
            nilEncodings: ["", "nil"],
            ignoresEmptyLines: true,
            delimiter: ";"
        )
        
        do {
            // read the CSV file
            var data = try DataFrame(
                contentsOfCSVFile: url,
                columns: columns,
                types: types,
                options: options)
            
            // formatter used later on for decoding the floating point numbers which have "," in the file
            let numberFormatter = NumberFormatter()
            numberFormatter.decimalSeparator = ","

            // merge the department number and name coulumns to a single column. Content is "deptNum - deptName"
            // the deptNum is formatted to have always a 2 digit number with leading 0 when needed
            data.combineColumns(deptNumID.name, deptNameID.name, into: deptID.name) { (col1: String?, col2: String?) -> String in
                if let col1 = col1, let num = Int(col1) {
                    return String(format: "%02d - %@", num, col2 ?? "")
                }
                return "\(col1 ?? "?") - \(col2 ?? "")"
            }
            
            // convert from String to Double some columns
            for column in [absPercentID.name, voixVsExp1ID.name, voixVsExp2ID.name, voixVsExp3ID.name] {
                data.transformColumn(column) { (from: String) -> Double in
                    numberFormatter.number(from: from)?.doubleValue ?? 0.0
                }
            }

            return .success(data)
            
        } catch {
            return .failure(LoadFileError(message: error.localizedDescription))
        }
    }
}
