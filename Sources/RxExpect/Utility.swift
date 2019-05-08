import RxSwift
import RxTest

public protocol RecordedType {
  associatedtype ValueType

  var time: TestTime { get }
  var value: ValueType { get }
}

extension Recorded: RecordedType {
  public typealias ValueType = Value
}

public protocol EventType {
  associatedtype ElementType

  var element: ElementType? { get }
  var error: Error? { get }
  func `is`(_ event: EventFilter) -> Bool
}

extension Event: EventType {
  public typealias ElementType = Element

  public func `is`(_ event: EventFilter) -> Bool {
    switch (self, event) {
    case (.next, .next): return true
    case (.error, .error): return true
    case (.completed, .completed): return true
    default: return false
    }
  }
}

public enum EventFilter {
  case next
  case error
  case completed
}

public extension Array where Element: RecordedType, Element.ValueType: EventType {
  var elements: [Element.ValueType.ElementType] {
    return self.compactMap { $0.value.element }
  }

  var error: Error? {
    return self.lazy.compactMap { $0.value.error }.first
  }

  func filter(_ event: EventFilter) -> Array<Element> {
    return self.filter { $0.value.is(event) }
  }

  func `in`<R>(_ timeRange: R) -> Array<Element> where R: RangeExpression, R.Bound == TestTime {
    return self.filter { timeRange.contains($0.time) }
  }
}
