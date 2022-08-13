//
//  XCTest-Extensions.swift
//  Elections2022Tests
//
//  Created by Dominique Berre on 12/08/2022.
//

import XCTest
import Combine

extension XCTestCase {
    func waitUntil<T: Equatable>(
        _ propertyPublisher: Published<T>.Publisher,
        equals expectedValue: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let expectation = expectation(description: "Awaiting: \(expectedValue)")
                
        var cancellable: AnyCancellable?
        cancellable = propertyPublisher
            .dropFirst()
            .first( where: { $0 == expectedValue })
            .sink { value in
                print(value)
                XCTAssertEqual(value, expectedValue, file: file, line: line)
                cancellable?.cancel()
                expectation.fulfill()
            }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
