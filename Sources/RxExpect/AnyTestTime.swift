import RxSwift
import RxTest

let AnyTestTime = TestTime.min

public func next<T>(_ element: T) -> Recorded<Event<T>> {
  return Recorded.next(AnyTestTime, element)
}
