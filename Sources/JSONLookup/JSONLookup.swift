//
//  JSONLookupTests.swift
//  JSONLookupTests
//
//  Created by JP Wright on 07.09.18.
//  Copyright © 2018 JP Wright. All rights reserved.
//


import Foundation

@dynamicMemberLookup
public enum JSON: Codable {
    case bool(Bool)
    case number(Double)
    case string(String)
    indirect case jsonArray([JSON])
    indirect case jsonDict([String: JSON])

    // MARK: Decodable

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: JSONCodingKeys.self) {
            self = JSON(from: container)
        } else if let container = try? decoder.unkeyedContainer() {
            self = JSON(from: container)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: ""))
        }
    }

    // MARK: Encodable

    public func encode(to encoder: Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        switch self {

        case .bool(let bool):
            try singleValueContainer.encode(bool)

        case .number(let double):
            try singleValueContainer.encode(double)

        case .string(let str):
            try singleValueContainer.encode(str)

        case .jsonArray(let array):
            var unkeyedContainer = encoder.unkeyedContainer()
            try unkeyedContainer.encode(contentsOf: array)

        case .jsonDict(let dict):
            var container = encoder.container(keyedBy: JSONCodingKeys.self)

            for key in dict.keys {
                let codingKey = JSONCodingKeys(stringValue: key)!
                guard let json = dict[key] else {
                    // Should this encode nil or just pass?
                    try container.encodeNil(forKey: codingKey)
                    continue
                }

                switch json {
                case .bool(let bool):
                    try container.encode(bool, forKey: codingKey)

                case .number(let number):
                    try container.encode(number, forKey: codingKey)

                case .string(let str):
                    try container.encode(str, forKey: codingKey)

                case .jsonArray(let jsonArray):
                    try container.encode(jsonArray, forKey: codingKey)

                case .jsonDict(let jsonDict):
                    try container.encode(jsonDict, forKey: codingKey)
                }
            }
        }
    }

    internal init(from container: KeyedDecodingContainer<JSONCodingKeys>) {
        var dict: [String: JSON] = [:]
        for key in container.allKeys {
            if let value = try? container.decode(Bool.self, forKey: key) {
                dict[key.stringValue] = .bool(value)
            } else if let value = try? container.decode(Double.self, forKey: key) {
                dict[key.stringValue] = .number(value)
            } else if let value = try? container.decode(String.self, forKey: key) {
                dict[key.stringValue] = .string(value)
            } else if let value = try? container.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key) {
                dict[key.stringValue] = JSON(from: value)
            } else if let value = try? container.nestedUnkeyedContainer(forKey: key) {
                dict[key.stringValue] = JSON(from: value)
            }
        }
        self = .jsonDict(dict)
    }

    internal init(from container: UnkeyedDecodingContainer) {
        var container = container
        var arr: [JSON] = []
        while !container.isAtEnd {
            if let value = try? container.decode(Bool.self) {
                arr.append(.bool(value))
            } else if let value = try? container.decode(Double.self) {
                arr.append(.number(value))
            } else if let value = try? container.decode(String.self) {
                arr.append(.string(value))
            } else if let value = try? container.nestedContainer(keyedBy: JSONCodingKeys.self) {
                arr.append(JSON(from: value))
            } else if let value = try? container.nestedUnkeyedContainer() {
                arr.append(JSON(from: value))
            }
        }
        self = .jsonArray(arr)
    }

    // MARK: Convenience accessors for better type inference.

    public var string: String? {
        guard case .string(let str) = self else { return nil }
        return str
    }

    public var bool: Bool? {
        guard case .bool(let bool) = self else { return nil }
        return bool
    }

    public var double: Double? {
        guard case .number(let double) = self else { return nil }
        return double
    }

    public var int: Int? {
        guard case .number(let double) = self else { return nil }
        return Int(double)
    }

    public var jsonArray: [JSON]? {
        guard case .jsonArray(let array) = self else { return nil }
        return array
    }

    public var jsonDict: [String: JSON]? {
        guard case .jsonDict(let jsonDictionary) = self else { return nil }
        return jsonDictionary
    }

    // MARK: Array and Dictionary lookup.

    public subscript(index: Int) -> JSON? {
        guard case .jsonArray(let arr) = self else { return nil }
        return index < arr.count ? arr[index] : nil
    }
    public subscript(key: String) -> JSON? {
        guard case .jsonDict(let dict) = self else { return nil }
        return dict[key]
    }

    // MARK: Dynamic member lookup.

    public subscript(dynamicMember member: String) -> JSON? {
        guard case .jsonDict(let jsonDictionary) = self else { return nil }
        return jsonDictionary[member]
    }
    public subscript(dynamicMember member: String) -> [JSON]? {
        guard case .jsonArray(let array) = self else { return nil }
        return array
    }
    public subscript(dynamicMember member: String) -> String? {
        guard case .string(let str) = self else { return nil }
        return str
    }
    public subscript(dynamicMember member: String) -> Bool? {
        guard case .bool(let bool) = self else { return nil }
        return bool
    }
    public subscript(dynamicMember member: String) -> Double? {
        guard case .number(let double) = self else { return nil }
        return double
    }
    public subscript(dynamicMember member: String) -> Int? {
        guard case .number(let double) = self else { return nil }
        return Int(double)
    }
}

internal struct JSONCodingKeys: CodingKey {
    internal var stringValue: String

    internal init?(stringValue: String) {
        self.stringValue = stringValue
    }

    internal var intValue: Int?

    internal init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}
