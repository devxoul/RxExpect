//
//  XCTAssertEqual+AssertionResult.swift
//  RxExpect
//
//  Created by Suyeol Jeon on 20/05/2017.
//
//

import XCTest
import RxExpect

func XCTAssertEqual(_ results: @autoclosure () -> [AssertionResult], _ bools: @autoclosure () -> [Bool], _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
  let boolResults: [Bool] = results().map {
    switch $0 {
    case .success: return true
    case .failure: return false
    }
  }
  XCTAssertEqual(boolResults, bools(), message, file: file, line: line)
}
