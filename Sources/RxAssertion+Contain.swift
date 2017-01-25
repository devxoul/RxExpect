//
//  RxAssertion+Contain.swift
//  RxExpect
//
//  Created by Suyeol Jeon on 25/01/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import RxSwift
import RxTest

extension RxAssertion {
  public func contains(file: StaticString = #file, line: UInt = #line, where predicate: @escaping (Recorded<Event<O.E>>) -> Bool) {
    self.assert([], file: file, line: line) { _, recordedEvents in
      return recordedEvents.contains(where: predicate)
    }
  }
}

extension RxAssertion where O.E: Equatable {
  public func contains(file: StaticString = #file, line: UInt = #line, _ event: Recorded<Event<O.E>>) {
    self.assert([], file: file, line: line) { _, recordedEvents in
      return recordedEvents.contains { recordedEvent in
        return self.recordedEventsEqual(event, recordedEvent)
      }
    }
  }

  public func contains(_ element: O.E, file: StaticString = #file, line: UInt = #line) {
    self.assert([], file: file, line: line) { _, recordedEvents in
      return recordedEvents.contains { recordedEvent in
        let event = Recorded(time: AnyTestTime, value: Event.next(element))
        return self.recordedEventsEqual(event, recordedEvent)
      }
    }
  }
}
