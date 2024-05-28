//
//  CodableKeyOptions.swift
//  CodableKit
//
//  Created by WendellXY on 2024/5/14
//  Copyright © 2024 WendellXY. All rights reserved.
//

import SwiftSyntax

public struct CodableKeyOptions: OptionSet {
  public let rawValue: Int32

  public init(rawValue: Int32) {
    self.rawValue = rawValue
  }

  /// The default options for a `CodableKey`, which is equivalent to an empty set.
  public static let `default`: Self = []
  /// The key will be ignored when encoding and decoding.
  public static let ignored = Self(rawValue: 1 << 0)
  /// The key will be explicitly set to `nil` (`null`) when encoding and decoding.
  /// By default, the key will be omitted if the value is `nil`.
  public static let explicitNil = Self(rawValue: 1 << 1)
  /// If the key has a custom CodableKey, a computed property will be generated to access the key; otherwise, this
  /// option is ignored.
  ///
  /// For example, if you have a custom key `myKey` and the original key `key`, a computed property `myKey` will be
  /// generated to access the original key `key`.
  ///
  /// ```swift
  /// @Codable
  /// struct MyStruct {
  ///   @CodableKey("key", options: .generateCustomKey)
  ///   var myKey: String
  /// }
  /// ```
  ///
  /// The generated code will be:
  /// ```swift
  /// struct MyStruct {
  ///   var myKey: String
  ///   var key: String {
  ///     myKey
  ///   }
  /// }
  /// ```
  public static let generateCustomKey = Self(rawValue: 1 << 2)
  /// Transcode the value between raw string and the target type. This is useful when the value needs to be converted
  /// from a string to another type during decoding and vice versa during encoding. The type of the property must
  /// conform to `Codable`, otherwise, a compile-time error will occur.
  public static let transcodeRawString = Self(rawValue: 1 << 3)
  /// Use the default value (if set) when decode or encode fails.
  public static let useDefaultOnFailure = Self(rawValue: 1 << 4)
}

// MARK: It will be nice to use a macro to generate this code below.
extension CodableKeyOptions {
  package init(from expr: MemberAccessExprSyntax) {
    let variableName = expr.declName.baseName.text
    switch variableName {
    case "ignored":
      self = .ignored
    case "explicitNil":
      self = .explicitNil
    case "generateCustomKey":
      self = .generateCustomKey
    case "transcodeRawString":
      self = .transcodeRawString
    case "useDefaultOnFailure":
      self = .useDefaultOnFailure
    default:
      self = .default
    }
  }
}

extension CodableKeyOptions {
  /// Parse the options from 1a `LabelExprSyntax`. It support parse a single element like `.default`,
  /// or multiple elements like `[.ignored, .explicitNil]`
  package static func parse(from labeledExpr: LabeledExprSyntax) -> Self {
    if let memberAccessExpr = labeledExpr.expression.as(MemberAccessExprSyntax.self) {
      Self.init(from: memberAccessExpr)
    } else if let arrayExpr = labeledExpr.expression.as(ArrayExprSyntax.self) {
      arrayExpr.elements
        .compactMap { $0.expression.as(MemberAccessExprSyntax.self) }
        .map { Self.init(from: $0) }
        .reduce(.default) { $0.union($1) }
    } else {
      .default
    }
  }
}

extension LabeledExprSyntax {
  /// Parse the options from a `LabelExprSyntax`. It support parse a single element like .default,
  /// or multiple elements like [.ignored, .explicitNil].
  ///
  /// This is a convenience method to use for chaining.
  package func parseOptions() -> CodableKeyOptions {
    CodableKeyOptions.parse(from: self)
  }
}
