import RxSwift
import RxTest

public struct AnyTestTime {
  static let time = TestTime.min

  public static func next<T>(_ element: T) -> Recorded<Event<T>> {
    return Recorded.next(time, element)
  }
}
