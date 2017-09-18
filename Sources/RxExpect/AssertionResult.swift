//
//  AssertionResult.swift
//  RxExpect
//
//  Created by Suyeol Jeon on 20/05/2017.
//
//

public enum AssertionResult {
  case success(file: StaticString, line: UInt)
  case failure(message: String, file: StaticString, line: UInt)
}
