//
//  CodableKit.swift
//  CodableKit
//
//  Created by Wendell on 3/30/24.
//

import CodableKitMacros

/// A macro that generates `Codable` conformance and boilerplate code for a struct, such that the Codable struct can
/// have default values for its properties, and custom keys for encoding and decoding with `@CodableKey`.
///
/// Suppose you have a struct like this:
///
/// ```swift
/// @Codable
/// struct User {
///   @CodableKey("uid") let id: Int
///   let id: Int
///   let name: String
///   let email: String
///   var age = 25
/// }
/// ```
///
/// It will generate the following code:
///
/// ```swift
/// extension User: Codable {
///   enum CodingKeys: String, CodingKey {
///     case id = "uid"
///     case name
///     case email
///     case age
///   }
///
///   init(from decoder: Decoder) throws {
///     let container = try decoder.container(keyedBy: CodingKeys.self)
///     id = try container.decode(Int.self, forKey: .id)
///     name = try container.decode(String.self, forKey: .name)
///     email = try container.decode(String.self, forKey: .email)
///     age = try container.decodeIfPresent(Int.self, forKey: .age) ?? 25
///   }
///
///   func encode(to encoder: Encoder) throws {
///     var container = encoder.container(keyedBy: CodingKeys.self)
///     try container.encode(id, forKey: .id)
///     try container.encode(name, forKey: .name)
///     try container.encode(email, forKey: .email)
///     try container.encode(age, forKey: .age)
///   }
/// }
/// ```
@attached(
  extension,
  conformances: Codable,
  names: named(CodingKeys), named(init(from:)), named(encode(to:))
)
public macro Codable() = #externalMacro(module: "CodableKitMacros", type: "CodableMacro")

/// Custom the key used for encoding and decoding a property.
///
/// - Parameters:
///   - key: The custom key to use for encoding and decoding the property. If not provided,
///   the property name will be used.
///   - options: Options for customizing the behavior of the key.
@attached(peer)
public macro CodableKey(
  _ key: String? = nil,
  options: CodableKeyMacro.Options = .default
) = #externalMacro(module: "CodableKitMacros", type: "CodableKeyMacro")
