//
//  RxAssertion+Empty.swift
//  RxExpect
//
//  Created by Suyeol Jeon on 23/01/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

extension RxAssertion {
  public func isEmpty(file: StaticString = #file, line: UInt = #line) {
    self.assert([], file: file, line: line) { expectedEvents, recordedEvents in
      return recordedEvents.isEmpty
    }
  }
}
