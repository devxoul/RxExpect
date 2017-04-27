//
//  Asserter.swift
//  RxExpect
//
//  Created by Suyeol Jeon on 27/04/2017.
//
//

import XCTest

public class Asserter {
  public typealias Method = (
    _ expression: @autoclosure () throws -> Bool,
    _ message: @autoclosure () -> String,
    _ file: StaticString,
    _ line: UInt
  ) -> Void

  public var method: Method = XCTAssert

  public required init(method: @escaping Method) {
    self.method = method
  }

  public func assert(
    _ expression: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
  ) {
    self.method(expression(), message(), file, line)
  }
}
