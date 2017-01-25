//
//  RxAssertion+Equal.swift
//  RxExpect
//
//  Created by Suyeol Jeon on 23/01/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import RxCocoa
import RxSwift
import RxTest

// MARK: Equality Utilities

extension RxAssertion {

  // MARK: Equality of TestTime

  func timesEqual(_ lhs: TestTime, _ rhs: TestTime) -> Bool {
    return lhs == rhs || lhs == AnyTestTime || rhs == AnyTestTime
  }


  // MARK: Equality of Event<E>

  func eventsEqual<E>(_ lhs: Event<E>, _ rhs: Event<E>, by elementsEqual: (E, E) -> Bool) -> Bool {
    /// This code is from RxTest and copyrighted by 2015 Krunoslav Zaher
    switch (lhs, rhs) {
    case (.completed, .completed): return true
    case (.error(let e1), .error(let e2)):
      #if os(Linux)
        return  "\(e1)" == "\(e2)"
      #else
        let error1 = e1 as NSError
        let error2 = e2 as NSError

        return error1.domain == error2.domain
          && error1.code == error2.code
          && "\(e1)" == "\(e2)"
      #endif
    case (.next(let v1), .next(let v2)): return elementsEqual(v1, v2)
    default: return false
    }
  }


  // MARK: Equality of Recorded<Event<E>>

  func recordedEventsEqual<E>(_ lhs: Recorded<Event<E>>, _ rhs: Recorded<Event<E>>, by elementsEqual: (E, E) -> Bool) -> Bool {
    return self.timesEqual(lhs.time, rhs.time) && eventsEqual(lhs.value, rhs.value, by: elementsEqual)
  }

  func recordedEventsEqual<E: Equatable>(_ lhs: Recorded<Event<E>>, _ rhs: Recorded<Event<E>>) -> Bool {
    return self.recordedEventsEqual(lhs, rhs, by: ==)
  }

  func recordedEventsEqual<E: Sequence>(_ lhs: Recorded<Event<E>>, _ rhs: Recorded<Event<E>>) -> Bool where E.Iterator.Element: Equatable {
    return self.recordedEventsEqual(lhs, rhs) { left, right in left.elementsEqual(right) }
  }


  // MARK: Equality of [Recorded<Event<E>>]

  func recordedEventsEqual<E>(_ lhs: [Recorded<Event<E>>], _ rhs: [Recorded<Event<E>>], by elementsEqual: @escaping (E, E) -> Bool) -> Bool {
    return lhs.elementsEqual(rhs) { left, right in
      return self.recordedEventsEqual(left, right, by: elementsEqual)
    }
  }

  func recordedEventsEqual<E: Equatable>(_ lhs: [Recorded<Event<E>>], _ rhs: [Recorded<Event<E>>]) -> Bool {
    return lhs.elementsEqual(rhs, by: recordedEventsEqual)
  }

  func recordedEventsEqual<E: Sequence>(_ lhs: [Recorded<Event<E>>], _ rhs: [Recorded<Event<E>>]) -> Bool where E.Iterator.Element: Equatable {
    return lhs.elementsEqual(rhs, by: recordedEventsEqual)
  }
}


// MARK: - Equality Assertion (Non Equatable)

extension RxAssertion {
  public func equal(_ expectedEvents: [Recorded<Event<O.E>>], file: StaticString = #file, line: UInt = #line, by elementsEqual: @escaping (O.E, O.E) -> Bool) {
    self.assert(expectedEvents, file: file, line: line) { expectedEvents, recordedEvents in
      return self.recordedEventsEqual(expectedEvents, recordedEvents, by: elementsEqual)
    }
  }

  public func equal(_ expectedElements: [O.E], file: StaticString = #file, line: UInt = #line, by elementsEqual: @escaping (O.E, O.E) -> Bool) {
    let expectedEvents = expectedElements.map { Recorded(time: AnyTestTime, value: Event.next($0)) }
    self.equal(expectedEvents, file: file, line: line, by: elementsEqual)
  }
}


// MARK: - Equality Assertion (Equatable)

extension RxAssertion where O.E: Equatable {
  public func equal(_ expectedEvents: [Recorded<Event<O.E>>], file: StaticString = #file, line: UInt = #line) {
    self.assert(expectedEvents, file: file, line: line) { expectedEvents, recordedEvents in
      return self.recordedEventsEqual(expectedEvents, recordedEvents)
    }
  }

  public func equal(_ expectedElements: [O.E], file: StaticString = #file, line: UInt = #line) {
    let expectedEvents = expectedElements.map { Recorded(time: AnyTestTime, value: Event.next($0)) }
    self.equal(expectedEvents, file: file, line: line)
  }
}


// MARK: - Equality Assertion of Sequence Element (Equatable)

extension RxAssertion where O.E: Sequence, O.E.Iterator.Element: Equatable {
  public func equal(_ expectedEvents: [Recorded<Event<O.E>>], file: StaticString = #file, line: UInt = #line) {
    self.assert(expectedEvents, file: file, line: line) { expectedEvents, recordedEvents in
      return self.recordedEventsEqual(expectedEvents, recordedEvents)
    }
  }

  public func equal(_ expectedElements: [O.E], file: StaticString = #file, line: UInt = #line) {
    let expectedEvents = expectedElements.map { Recorded(time: AnyTestTime, value: Event.next($0)) }
    self.equal(expectedEvents, file: file, line: line)
  }
}
