//
//  RxAssertion+Count.swift
//  RxExpect
//
//  Created by Suyeol Jeon on 20/05/2017.
//
//

extension RxAssertion {
  public func count(_ count: Int, file: StaticString = #file, line: UInt = #line) {
    self.assert([], file: file, line: line) { _, recordedEvents in
      return count == recordedEvents.count
    }
  }
}

