// The MIT License (MIT)
//
// Copyright (c) 2016 Suyeol Jeon (xoul.kr)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import XCTest

import RxCocoa
import RxSwift
import RxTest


// MARK: - RxExpectation

open class RxExpectation: XCTest {

  fileprivate weak var _testCase: XCTestCase?
  fileprivate var _description: String?

  let scheduler = TestScheduler(initialClock: 0)
  fileprivate var _inputDisposables: [Disposable] = []
  fileprivate var _lastTime: TestTime = TestTime.min

  public init(_ testCase: XCTestCase, description: String? = nil) {
    self._testCase = testCase
    self._description = description
  }

}


// MARK: - Input

extension RxExpectation {

  public func input<O: ObserverType>(
    _ observer: O,
    _ events: [Recorded<Event<O.E>>],
    file: StaticString = #file,
    line: UInt = #line
  ) {
    Swift.assert(!events.contains { $0.time == AnyTestTime }, "Input events should have specific time.",
                 file: file, line: line)
    let disposable = self.scheduler.createHotObservable(events).bindTo(observer)
    self._inputDisposables.append(disposable)
    self._lastTime = events.map { $0.time }.max() ?? self._lastTime
  }

  public func input<E>(
    _ variable: Variable<E>,
    _ events: [Recorded<Event<E>>],
    file: StaticString = #file,
    line: UInt = #line
  ) {
    Swift.assert(!events.contains { $0.time == AnyTestTime }, "Input events should have specific time.",
                 file: file, line: line)
    let disposable = self.scheduler.createHotObservable(events).bindTo(variable)
    self._inputDisposables.append(disposable)
    self._lastTime = events.map { $0.time }.max() ?? self._lastTime
  }

}


// MARK: - Assert

extension RxExpectation {

  func _assert<O: ObservableConvertibleType, E>(
    _ source: O,
    expectedEvents: [Recorded<Event<E>>],
    assertionBlock: @escaping (([Recorded<Event<E>>], [Recorded<Event<E>>]) -> RxAssertionResult<E>),
    filterNext: Bool,
    not: Bool,
    file: StaticString = #file,
    line: UInt = #line
  ) where E == O.E {
    guard let testCase = self._testCase else { return }
    let recorder = self.scheduler.createObserver(E.self)
    let disposeBag = DisposeBag()
    let expectation = testCase.expectation(description: "")

    source.asObservable()
      .subscribe(recorder)
      .addDisposableTo(disposeBag)

    for disposable in self._inputDisposables {
      disposable.addDisposableTo(disposeBag)
    }

    let lastTime = max(expectedEvents.map { $0.time }.max() ?? self._lastTime, self._lastTime)
    self.scheduler.scheduleAt(lastTime + 100, action: expectation.fulfill)
    self.scheduler.start()

    testCase.waitForExpectations(timeout: 0.5) { error in
      XCTAssertNil(error, file: file, line: line)
      let recordedEvents: [Recorded<Event<E>>]
      if !filterNext {
        recordedEvents = recorder.events
      } else {
        recordedEvents = recorder.events.filter { event in
          if case .next = event.value {
            return true
          }
          return false
        }
      }
      let result = assertionBlock(expectedEvents, recordedEvents)
      XCTAssert(result.isSucceeded, result.failureMessage, file: file, line: line)
    }
  }

}


// MARK: AssertEqual

extension RxExpectation {

  // MARK: Internal

  func _eventEquals<E: Equatable>(_ lhs: Recorded<Event<E>>, _ rhs: Recorded<Event<E>>) -> Bool {
    return (lhs.time == AnyTestTime || rhs.time == AnyTestTime || lhs.time == rhs.time)
      && lhs.value == rhs.value
  }

  func _eventsEqual<E: Equatable>(_ lhs: [Recorded<Event<E>>], _ rhs: [Recorded<Event<E>>]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for i in lhs.indices {
      if !self._eventEquals(lhs[i], rhs[i]) {
        return false
      }
    }
    return true
  }

  func _assertEqual<O: ObservableConvertibleType, E: Equatable>(
    _ source: O,
    _ expectedEvents: [Recorded<Event<E>>],
    filterNext: Bool,
    not: Bool,
    file: StaticString = #file,
    line: UInt = #line
  ) where E == O.E {
    self._assert(
      source,
      expectedEvents: expectedEvents,
      assertionBlock: { expectedEvents, recordedEvents in
        let eventsEqual = self._eventsEqual(expectedEvents, recordedEvents)
        let isSucceeded = (!not && eventsEqual) || (not && !eventsEqual)

        let expectedEventsDescription = expectedEvents.description
          .replacingOccurrences(of: String(AnyTestTime), with: "any")
        let message = "\(self._description ?? "")\n" +
          "\t Expected: \(not ? "!" : "")\(expectedEventsDescription)\n" +
        "\t Recorded: \(not ? " " : "")\(recordedEvents)"

        return RxAssertionResult(expectedEvents: expectedEvents,
                                 recordedEvents: recordedEvents,
                                 isSucceeded: isSucceeded,
                                 failureMessage: message)
      },
      filterNext: filterNext,
      not: false,
      file: file,
      line: line
    )
  }


  // MARK: with Equatable Events

  public func assertEqual<O: ObservableConvertibleType, E: Equatable>(
    _ source: O,
    _ expectedEvents: [Recorded<Event<E>>],
    file: StaticString = #file,
    line: UInt = #line) where E == O.E {
    self._assertEqual(source, expectedEvents, filterNext: false, not: false, file: file, line: line)
  }

  public func assertNextEqual<O: ObservableConvertibleType, E: Equatable>(
    _ source: O,
    _ expectedEvents: [Recorded<Event<E>>],
    file: StaticString = #file,
    line: UInt = #line
  ) where E == O.E {
    self._assertEqual(source, expectedEvents, filterNext: true, not: false, file: file, line: line)
  }


  // MARK: with Equatable Elements

  public func assertNextEqual<O: ObservableConvertibleType, E: Equatable>(
    _ source: O,
    _ expectedElements: [E],
    file: StaticString = #file,
    line: UInt = #line
  ) where E == O.E {
    let events = expectedElements.map { Recorded(time: AnyTestTime, value: Event.next($0)) }
    self.assertNextEqual(source, events, file: file, line: line)
  }

}


// MARK: - AssertNotEqual

extension RxExpectation {

  // MARK: with Equatable Events

  public func assertNotEqual<O: ObservableConvertibleType, E: Equatable>(
    _ source: O,
    _ expectedEvents: [Recorded<Event<E>>],
    file: StaticString = #file,
    line: UInt = #line
  ) where E == O.E {
    self._assertEqual(source, expectedEvents, filterNext: false, not: true, file: file, line: line)
  }

  public func assertNextNotEqual<O: ObservableConvertibleType, E: Equatable>(
    _ source: O,
    _ expectedEvents: [Recorded<Event<E>>],
    file: StaticString = #file,
    line: UInt = #line
  ) where E == O.E {
    self._assertEqual(source, expectedEvents, filterNext: true, not: true, file: file, line: line)
  }


  // MARK: with Equatable Elements

  public func assertNextNotEqual<O: ObservableConvertibleType, E: Equatable>(
    _ source: O,
    _ expectedElements: [E],
    file: StaticString = #file,
    line: UInt = #line
  ) where E == O.E {
    let events = expectedElements.map { Recorded(time: AnyTestTime, value: Event.next($0)) }
    self.assertNextNotEqual(source, events, file: file, line: line)
  }

}
