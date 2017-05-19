// The MIT License (MIT)
//
// Copyright (c) 2017 Suyeol Jeon (xoul.kr)
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

protocol AnyAssertion: class {
  var maximumTime: TestTime? { get }

  func prepareRecorder(scheduler: TestScheduler, disposeBag: DisposeBag)
  func assert(message: String) -> AssertionResult
}

public class RxAssertion<O: ObservableConvertibleType>: AnyAssertion {
  let source: O

  var shouldFilterNext: Bool
  var timeRange: Range<TestTime>
  var isNot: Bool

  var recorder: TestableObserver<O.E>?
  var expectedEvents: [Recorded<Event<O.E>>]?
  var file: StaticString?
  var line: UInt?
  var assertionBlock: AssertionBlock<O>?

  public init(source: O) {
    self.source = source
    self.shouldFilterNext = false
    self.timeRange = 0..<TestTime.max
    self.isNot = false
  }
}


// MARK: - Filtering Event

extension RxAssertion {
  public func filterNext() -> RxAssertion<O> {
    self.shouldFilterNext = true
    return self
  }
}


// MARK: - Filtering Time

extension RxAssertion {
  public func within(_ timeRange: Range<TestTime>) -> RxAssertion<O> {
    self.timeRange = timeRange
    return self
  }

  public func since(_ timeSince: TestTime) -> RxAssertion<O> {
    return self.within(timeSince..<self.timeRange.upperBound)
  }

  public func until(_ timeUntil: TestTime) -> RxAssertion<O> {
    return self.within(self.timeRange.lowerBound..<timeUntil)
  }
}


// MARK: - Reversing

extension RxAssertion {
  public func not() -> RxAssertion<O> {
    self.isNot = !self.isNot
    return self
  }
}


// MARK: - Assertion

extension RxAssertion {
  typealias AssertionBlock<O: ObservableConvertibleType> = ([Recorded<Event<O.E>>], [Recorded<Event<O.E>>]) -> Bool

  var maximumTime: TestTime? {
    guard let expectedEvents = self.expectedEvents else { fatalError("") }
    return expectedEvents.map { $0.time }.max()
  }

  func prepareRecorder(scheduler: TestScheduler, disposeBag: DisposeBag) {
    let recorder = scheduler.createObserver(O.E.self)
    self.recorder = recorder
    self.source.asObservable()
      .subscribe(recorder)
      .addDisposableTo(disposeBag)
  }

  func prepare(
    expectedEvents: [Recorded<Event<O.E>>],
    assertionBlock: (@escaping AssertionBlock<O>),
    file: StaticString = #file,
    line: UInt = #line
  ) {
    self.expectedEvents = expectedEvents
    self.file = file
    self.line = line
    self.assertionBlock = assertionBlock
  }

  private func filteredEvents(_ events: [Recorded<Event<O.E>>]) -> [Recorded<Event<O.E>>] {
    return events.filter { event in
      if self.shouldFilterNext {
        guard case .next = event.value else { return false }
      }
      guard self.timeRange.contains(event.time) || event.time == AnyTestTime else { return false }
      return true
    }
  }

  func assert(message: String) -> AssertionResult {
    guard let recorder = self.recorder else { fatalError("Call prepareRecorder() first") }
    guard let allExpectedEvents = self.expectedEvents,
      let file = self.file,
      let line = self.line,
      let assertionBlock = self.assertionBlock
    else { fatalError("") }

    let expectedEvents = self.filteredEvents(allExpectedEvents)
    let recordedEvents = self.filteredEvents(recorder.events)
    let result = assertionBlock(expectedEvents, recordedEvents)
    if (result && !self.isNot) || (!result && self.isNot) {
      return .success(file: file, line: line)
    } else {
      let message = self.failureMessage(message, expectedEvents, recordedEvents)
      return .failure(message: message, file: file, line: line)
    }
  }

  private func failureMessage(_ message: String, _ expectedEvents: [Recorded<Event<O.E>>], _ recordedEvents: [Recorded<Event<O.E>>]) -> String {
    let expectedEventsDescription = expectedEvents.description.replacingOccurrences(of: String(AnyTestTime), with: "any")
    let lines = [
      message,
      "\t Expected: \(expectedEventsDescription)",
      "\t Recorded: \(recordedEvents)",
    ]
    return lines.joined(separator: "\n")
  }

}
