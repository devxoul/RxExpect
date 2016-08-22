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
import RxTests


// MARK: - RxExpectation

public class RxExpectation: XCTest {

    private weak var _testCase: RxTestCase?
    private var _description: String?

    let scheduler = TestScheduler(initialClock: 0)
    private var _inputDisposables: [Disposable] = []
    private var _lastTime: TestTime = TestTime.min

    public init(_ testCase: RxTestCase, description: String? = nil) {
        self._testCase = testCase
        self._description = description
    }

}


// MARK: - Input

extension RxExpectation {

    public func input<O: ObserverType>(observer: O, _ events: [Recorded<Event<O.E>>],
                                       file: StaticString = #file, line: UInt = #line) {
        Swift.assert(!events.contains({ $0.time == AnyTestTime }), "Input events should have specific time.",
                     file: file, line: line)
        let disposable = self.scheduler.createHotObservable(events).bindTo(observer)
        self._inputDisposables.append(disposable)
        self._lastTime = events.map { $0.time }.maxElement() ?? self._lastTime
    }

    public func input<E>(variable: Variable<E>, _ events: [Recorded<Event<E>>],
                         file: StaticString = #file, line: UInt = #line) {
        Swift.assert(!events.contains({ $0.time == AnyTestTime }), "Input events should have specific time.",
                     file: file, line: line)
        let disposable = self.scheduler.createHotObservable(events).bindTo(variable)
        self._inputDisposables.append(disposable)
        self._lastTime = events.map { $0.time }.maxElement() ?? self._lastTime
    }

}


// MARK: - Assert

extension RxExpectation {

    private func _assert<O: ObservableConvertibleType, E where E == O.E>(
                         source: O,
                         expectedEvents: [Recorded<Event<E>>],
                         assertionBlock: (([Recorded<Event<E>>], [Recorded<Event<E>>]) -> RxAssertionResult<E>),
                         filterNext: Bool,
                         not: Bool,
                         file: StaticString = #file,
                         line: UInt = #line) {
        guard let testCase = self._testCase else { return }
        let recorder = self.scheduler.createObserver(E)
        let disposeBag = DisposeBag()
        let expectation = testCase.expectationWithDescription("")

        source.asObservable()
            .subscribe(recorder)
            .addDisposableTo(disposeBag)

        for disposable in self._inputDisposables {
            disposable.addDisposableTo(disposeBag)
        }

        let lastTime = max(expectedEvents.map { $0.time }.maxElement() ?? self._lastTime, self._lastTime)
        self.scheduler.scheduleAt(lastTime + 100, action: expectation.fulfill)
        self.scheduler.start()

        testCase.waitForExpectationsWithTimeout(0.5) { error in
            XCTAssertEqual(error, nil, file: file, line: line)
            let recordedEvents: [Recorded<Event<E>>]
            if !filterNext {
                recordedEvents = recorder.events
            } else {
                recordedEvents = recorder.events.filter { event in
                    if case .Next = event.value {
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

    // MARK: Private

    private func _assertEqual<O: ObservableConvertibleType, E: Equatable where E == O.E>(
                              source: O,
                              _ expectedEvents: [Recorded<Event<E>>],
                              filterNext: Bool,
                              not: Bool,
                              file: StaticString = #file,
                              line: UInt = #line) {
        func isEqual(lhs: Recorded<Event<E>>, _ rhs: Recorded<Event<E>>) -> Bool {
            return (lhs.time == AnyTestTime || rhs.time == AnyTestTime) && lhs.value == rhs.value
        }
        self._assert(
            source,
            expectedEvents: expectedEvents,
            assertionBlock: { expectedEvents, recordedEvents in
                let isCountEqual = expectedEvents.count == recordedEvents.count
                let isValueEqual = !zip(expectedEvents, recordedEvents).lazy.contains { !isEqual($0, $1) }
                let isSucceeded: Bool
                if !not {
                    isSucceeded = isCountEqual && isValueEqual
                } else {
                    isSucceeded = !isValueEqual
                }

                let expectedEventsDescription = String(expectedEvents)
                .stringByReplacingOccurrencesOfString(String(AnyTestTime), withString: "any")
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

    public func assertEqual<O: ObservableConvertibleType, E: Equatable where E == O.E>(
                            source: O,
                            _ expectedEvents: [Recorded<Event<E>>],
                            file: StaticString = #file,
                            line: UInt = #line) {
        self._assertEqual(source, expectedEvents, filterNext: false, not: false, file: file, line: line)
    }

    public func assertNextEqual<O: ObservableConvertibleType, E: Equatable where E == O.E>(
                                source: O,
                                _ expectedEvents: [Recorded<Event<E>>],
                                file: StaticString = #file,
                                line: UInt = #line) {
        self._assertEqual(source, expectedEvents, filterNext: true, not: false, file: file, line: line)
    }


    // MARK: with Equatable Elements

    public func assertNextEqual<O: ObservableConvertibleType, E: Equatable where E == O.E>(
                                source: O,
                                _ expectedElements: [E],
                                file: StaticString = #file,
                                line: UInt = #line) {
        let events = expectedElements.map { Recorded(time: AnyTestTime, event: Event.Next($0)) }
        self.assertNextEqual(source, events, file: file, line: line)
    }

}


// MARK: - AssertNotEqual

extension RxExpectation {

    // MARK: with Equatable Events

    public func assertNotEqual<O: ObservableConvertibleType, E: Equatable where E == O.E>(
                               source: O,
                               _ expectedEvents: [Recorded<Event<E>>],
                               file: StaticString = #file,
                               line: UInt = #line) {
        self._assertEqual(source, expectedEvents, filterNext: false, not: true, file: file, line: line)
    }

    public func assertNextNotEqual<O: ObservableConvertibleType, E: Equatable where E == O.E>(
                                   source: O,
                                   _ expectedEvents: [Recorded<Event<E>>],
                                   file: StaticString = #file,
                                   line: UInt = #line) {
        self._assertEqual(source, expectedEvents, filterNext: true, not: true, file: file, line: line)
    }


    // MARK: with Equatable Elements

    public func assertNextNotEqual<O: ObservableConvertibleType, E: Equatable where E == O.E>(
                                   source: O,
                                   _ expectedElements: [E],
                                   file: StaticString = #file,
                                   line: UInt = #line) {
        let events = expectedElements.map { Recorded(time: AnyTestTime, event: Event.Next($0)) }
        self.assertNextNotEqual(source, events, file: file, line: line)
    }

}
