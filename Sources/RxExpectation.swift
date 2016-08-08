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

public class RxExpectation {

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
        assert(!events.contains({ $0.time == AnyTestTime }), "Input events should have specific time.",
               file: file, line: line)
        let disposable = self.scheduler.createHotObservable(events).bindTo(observer)
        self._inputDisposables.append(disposable)
        self._lastTime = events.map { $0.time }.maxElement() ?? self._lastTime
    }

    public func input<E>(variable: Variable<E>, _ events: [Recorded<Event<E>>],
                         file: StaticString = #file, line: UInt = #line) {
        assert(!events.contains({ $0.time == AnyTestTime }), "Input events should have specific time.",
               file: file, line: line)
        let disposable = self.scheduler.createHotObservable(events).bindTo(variable)
        self._inputDisposables.append(disposable)
        self._lastTime = events.map { $0.time }.maxElement() ?? self._lastTime
    }

}


// MARK: - AssertEqual

extension RxExpectation {

    private func _assertEqual<O: ObservableConvertibleType, E where E == O.E>(
                              source: O,
                              _ expectedEvents: [Recorded<Event<E>>],
                              _ recordedEventFilter: Recorded<Event<E>> -> Bool,
                              _ predicate: ((Recorded<Event<E>>, Recorded<Event<E>>) -> Bool),
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
            let recordedEvents = recorder.events.filter(recordedEventFilter)
            let isCountEqual = expectedEvents.count == recordedEvents.count
            let isValueEqual = !zip(expectedEvents, recordedEvents).lazy.contains { !predicate($0, $1) }
            let isSucceeded = isCountEqual && isValueEqual
            let expectedEventsDescription = String(expectedEvents)
                .stringByReplacingOccurrencesOfString(String(AnyTestTime), withString: "any")
            let message = "\(self._description ?? "")\n" +
                          "\t Expected: \(expectedEventsDescription)\n" +
                          "\t Recorded: \(recordedEvents)"
            XCTAssert(isSucceeded, message, file: file, line: line)
        }
    }

    public func assertEqual<O: ObservableConvertibleType, E where E == O.E>(
                            source: O,
                            _ expectedEvents: [Recorded<Event<E>>],
                            _ predicate: ((Recorded<Event<E>>, Recorded<Event<E>>) -> Bool),
                            file: StaticString = #file,
                            line: UInt = #line) {
        let recordedEventFilter: Recorded<Event<E>> -> Bool = { _ in true }
        self._assertEqual(source, expectedEvents, recordedEventFilter, predicate, file: file, line: line)
    }

    public func assertEqualNext<O: ObservableConvertibleType, E where E == O.E>(
                                source: O,
                                _ expectedEvents: [Recorded<Event<E>>],
                                _ predicate: ((Recorded<Event<E>>, Recorded<Event<E>>) -> Bool),
                                file: StaticString = #file,
                                line: UInt = #line) {
        let recordedEventFilter: Recorded<Event<E>> -> Bool = { event in
            if case .Next = event.value {
                return true
            }
            return false
        }
        self._assertEqual(source, expectedEvents, recordedEventFilter, predicate, file: file, line: line)
    }

}


// MARK: - AssertEqual (Equatable)

extension RxExpectation {

    public func assertEqual<O: ObservableConvertibleType, E: Equatable where E == O.E>(
                            source: O,
                            _ expectedEvents: [Recorded<Event<E>>],
                            file: StaticString = #file,
                            line: UInt = #line) {
        let predicate: (Recorded<Event<E>>, Recorded<Event<E>>) -> Bool = { lhs, rhs in
            return lhs.time == AnyTestTime || rhs.time == AnyTestTime || lhs == rhs
        }
        self.assertEqual(source, expectedEvents, predicate, file: file, line: line)
    }

    public func assertEqualNext<O: ObservableConvertibleType, E: Equatable where E == O.E>(
                                source: O,
                                _ expectedEvents: [Recorded<Event<E>>],
                                file: StaticString = #file,
                                line: UInt = #line) {
        let predicate: (Recorded<Event<E>>, Recorded<Event<E>>) -> Bool = { lhs, rhs in
            return lhs.time == AnyTestTime || rhs.time == AnyTestTime || lhs == rhs
        }
        self.assertEqualNext(source, expectedEvents, predicate, file: file, line: line)
    }

}


// MARK: - AssertEqual (Void)

extension RxExpectation {

    public func assertEqual<O: ObservableConvertibleType where O.E == Void>(
                            source: O,
                            _ expectedEvents: [Recorded<Event<Void>>],
                            file: StaticString = #file,
                            line: UInt = #line) {
        let predicate: (Recorded<Event<Void>>, Recorded<Event<Void>>) -> Bool = { lhs, rhs in
            return lhs.time == AnyTestTime || rhs.time == AnyTestTime || lhs.time == rhs.time
        }
        self.assertEqual(source, expectedEvents, predicate, file: file, line: line)
    }

    public func assertEqualNext<O: ObservableConvertibleType where O.E == Void>(
                                source: O,
                                _ expectedEvents: [Recorded<Event<Void>>],
                                file: StaticString = #file,
                                line: UInt = #line) {
        let predicate: (Recorded<Event<Void>>, Recorded<Event<Void>>) -> Bool = { lhs, rhs in
            return lhs.time == AnyTestTime || rhs.time == AnyTestTime || lhs.time == rhs.time
        }
        self.assertEqualNext(source, expectedEvents, predicate, file: file, line: line)
    }

}


// MARK: - AssertEqual with Element

extension RxExpectation {

    public func assertEqual<O: ObservableConvertibleType, E where E == O.E>(
                            source: O,
                            _ expectedElements: [E],
                            _ predicate: ((E, E) -> Bool),
                            file: StaticString = #file,
                            line: UInt = #line) {
        let events = expectedElements.map { Recorded(time: 0, event: Event.Next($0)) }
        let eventPredicate: (Recorded<Event<E>>, Recorded<Event<E>>) -> Bool = { lhs, rhs in
            guard let leftElement = lhs.value.element, rightElement = rhs.value.element else { return false }
            return predicate(leftElement, rightElement)
        }
        self.assertEqual(source, events, eventPredicate, file: file, line: line)
    }

    public func assertEqualNext<O: ObservableConvertibleType, E where E == O.E>(
                                source: O,
                                _ expectedElements: [E],
                                _ predicate: ((E, E) -> Bool),
                                file: StaticString = #file,
                                line: UInt = #line) {
        let events = expectedElements.map { Recorded(time: 0, event: Event.Next($0)) }
        let eventPredicate: (Recorded<Event<E>>, Recorded<Event<E>>) -> Bool = { lhs, rhs in
            guard let leftElement = lhs.value.element, rightElement = rhs.value.element else { return false }
            return predicate(leftElement, rightElement)
        }
        self.assertEqualNext(source, events, eventPredicate, file: file, line: line)
    }

}


// MARK: - AssertEqual with Element (Equtable)

extension RxExpectation {

    public func assertEqual<O: ObservableConvertibleType, E: Equatable where E == O.E>(
                            source: O,
                            _ expectedElements: [E],
                            file: StaticString = #file,
                            line: UInt = #line) {
        let events = expectedElements.map { Recorded(time: 0, event: Event.Next($0)) }
        self.assertEqual(source, events, file: file, line: line)
    }

    public func assertEqualNext<O: ObservableConvertibleType, E: Equatable where E == O.E>(
                                source: O,
                                _ expectedElements: [E],
                                file: StaticString = #file,
                                line: UInt = #line) {
        let events = expectedElements.map { Recorded(time: 0, event: Event.Next($0)) }
        self.assertEqualNext(source, events, file: file, line: line)
    }

}


let AnyTestTime = TestTime.min

public func next<T>(element: T) -> Recorded<Event<T>> {
    return next(AnyTestTime, element)
}
