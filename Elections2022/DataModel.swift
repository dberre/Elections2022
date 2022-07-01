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
    
    private var dataFrame: DataFrame? = nil
    
    @Published var state = LoadingState.idle
    
    enum LoadingState {
        case idle
        case loading
        case error(String)
        case complete
    }
    
    var dataTable: DataFrame {
        get { dataFrame ?? DataFrame() }
    }

    let columns: [String] = [
        DeptNumID.name,
        DeptNameID.name,
        CircoCodeID.name,
        CityNameID.name,
        InscritsID.name,
        AbsPercentID.name,
        VotantsID.name,
        Nom1ID.name,
        Nuance1ID.name,
        Voix1ID.name,
        VoixVsExp1ID.name,
        Nom2ID.name,
        Nuance2ID.name,
        Voix2ID.name,
        VoixVsExp2ID.name,
        Nom3ID.name,
        Nuance3ID.name,
        Voix3ID.name,
        VoixVsExp3ID.name
    ]
    
    // defines the columns (named by their header) and their types to extract
    private static let DeptNumID = ColumnID("DeptNum", String.self)
    private static let DeptNameID = ColumnID("DeptName", String.self)
    private static let DeptID = ColumnID("Dept", String.self)
    private static let CircoCodeID = ColumnID("CircoCode", Int.self)
    private static let CityNameID = ColumnID("CityName", String.self)
    private static let InscritsID = ColumnID("Inscrits", String.self)
    private static let AbsPercentID  = ColumnID("AbsPercent", Double.self)
    private static let VotantsID = ColumnID("Votants", Int.self)
    private static let Nom1ID = ColumnID("Nom1", String.self)
    private static let Nuance1ID = ColumnID("Nuance1", String.self)
    private static let Voix1ID = ColumnID("Voix1", Int.self)
    private static let VoixVsExp1ID  = ColumnID("VoixVsExp1", Double.self)
    private static let Nom2ID = ColumnID("Nom2", String.self)
    private static let Nuance2ID = ColumnID("Nuance2", String.self)
    private static let Voix2ID = ColumnID("Voix2", Int.self)
    private static let VoixVsExp2ID  = ColumnID("VoixVsExp2", Double.self)
    private static let Nom3ID = ColumnID("Nom3", String.self)
    private static let Nuance3ID = ColumnID("Nuance3", String.self)
    private static let Voix3ID = ColumnID("Voix3", Int.self)
    private static let VoixVsExp3ID  = ColumnID("VoixVsExp3", Double.self)
    
    private let fileUrl = Bundle.main.url(forResource: "Resultats2eFull", withExtension: "csv")!
    

    var departments: [String] {
        guard let dataFrame = dataFrame else { return [] }
        
        let df = dataFrame[Self.DeptID.name].compactMap { dept in
            (dept as? String)
        }
        
        return Array(Set(df)).sorted()
    }
    
    func cities(for department: String?) -> [String] {
        guard let dataFrame = dataFrame else { return [] }
        guard let department = department else { return [] }
        
        return dataFrame
            .filter(on: Self.DeptID.name, String.self) { dept in
                dept == department
            } ["CityName"].map { name in
                name as? String ?? ""
            }
    }
    
    func circos(for department: String) -> [Int] {
        guard let dataFrame = dataFrame else { return [] }
        
        let result = dataFrame
            .filter(on: Self.DeptID.name, String.self) { dept in
                dept == department
            } ["CircoCode"].map { name in
                name as? Int ?? 0
            }
        
        return Array(Set(result)).sorted()
    }
        
    func arrayOfResult(for row: DataFrame.Row) -> [CandidateResult] {
        var ar = [CandidateResult]()
        ar.append(CandidateResult(name: row[DataModel.Nom1ID]!, group: row[DataModel.Nuance1ID]!, votes: row[DataModel.Voix1ID]!, votesVsExpr: row[DataModel.VoixVsExp1ID]!))
        if (row[DataModel.Nom2ID] != nil) {
            ar.append(CandidateResult(name: row[DataModel.Nom2ID]!, group: row[DataModel.Nuance2ID]!, votes: row[DataModel.Voix2ID]!, votesVsExpr: row[DataModel.VoixVsExp2ID]!))
            if (row[DataModel.Nom3ID] != nil) {
                ar.append(CandidateResult(name: row[DataModel.Nom3ID]!, group: row[DataModel.Nuance3ID]!, votes: row[DataModel.Voix3ID]!, votesVsExpr: row[DataModel.VoixVsExp3ID]!))
            }
        }
        return ar
    }
    
    func result(department: String?, city: String?) -> [PoolingResult] {
        guard let dataFrame = dataFrame else { return [] }

        guard let department = department, let city = city else { return [ ] }
        
        return dataFrame
            .filter(on: Self.DeptID.name, String.self) { dept in
                dept == department
            }.filter(on: Self.CityNameID.name, String.self) { value in
                value == city
            }
            .rows.map { row in
                PoolingResult(
                    department: department,
                    circoCode: 2,
                    cityName: "",
                    votants: row[DataModel.VotantsID]!,
                    abstention: row[DataModel.AbsPercentID]!,
                    results: arrayOfResult(for: row)
                )
            }
    }

    func result(department: String?, circoCode: Int?) -> [PoolingResult] {
        guard let dataFrame = dataFrame else { return [] }

        guard let department = department, let circoCode = circoCode else { return [ ] }
                
        return dataFrame
            .filter(on: Self.DeptID.name, String.self) { dept in
                dept == department
            }.filter(on: Self.CircoCodeID.name, Int.self) { value in
                value == circoCode
            }
            .rows.map { row in
                PoolingResult(
                    department: department,
                    circoCode: circoCode,
                    cityName: row[DataModel.CityNameID]!,
                    votants: row[DataModel.VotantsID]!,
                    abstention: row[DataModel.AbsPercentID]!,
                    results: arrayOfResult(for: row)
                )
            }
    }
    
    init() {
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
            }
        }
    }
    
    private struct LoadFileError: Error {
        let message: String
        
    }
            
    private func loadCsv(_ url: URL) -> Result<DataFrame, LoadFileError> {
        
        // define the columns type (for speeding up parsing and raise early types errors)
        let types: [String: CSVType] = [
            "DeptNum": .string,
            "DeptName": .string,
            "CircoCode": .integer,
            "CityName": .string,
            "Inscrits": .integer,
            "AbsPercent": .string,
            "Votants": .integer,
            "Nom1": .string,
            "Nuance1": .string,
            "Voix1": .integer,
            "VoixVsExp1": .string,
            "Nom2": .string,
            "Nuance2": .string,
            "Voix2": .integer,
            "VoixVsExp2": .string,
            "Nom3": .string,
            "Nuance3": .string,
            "Voix3": .integer,
            "VoixVsExp3": .string
        ]
        
        let options = CSVReadingOptions(
            hasHeaderRow: true,
            nilEncodings: ["", "nil"],
            ignoresEmptyLines: true,
            delimiter: ";"
        )
        
        do {
            // some options for decoding properly the file
            var data = try DataFrame(
                contentsOfCSVFile: url,
                columns: columns,
                types: types,
                options: options)

            
            // a formatter for decoding the floating point numbers which have "," in the file
            let numberFormatter = NumberFormatter()
            numberFormatter.decimalSeparator = ","

            // format this column to have always a 2 digit number with leading 0 when needed
            data.transformColumn("DeptNum") { (deptNum: String) -> String in
                if let num = Int(deptNum) {
                    return String(format: "%02d", num)
                }
                return deptNum
            }
            
            data.combineColumns(Self.DeptNumID.name, Self.DeptNameID.name, into: Self.DeptID.name) { (col1: String?, col2: String?) in
                "\(col1 ?? "?") - \(col2 ?? "?")"
            }
            
            // convert from String to Double some columns
            for column in ["AbsPercent", "VoixVsExp1", "VoixVsExp2", "VoixVsExp3"] {
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
