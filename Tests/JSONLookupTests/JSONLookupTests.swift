//
//  JSONLookupTests.swift
//  JSONLookupTests
//
//  Created by JP Wright on 07.09.18.
//  Copyright © 2018 JP Wright. All rights reserved.
//

import XCTest
@testable import JSONLookup

class JSONLookupTests: XCTestCase {

    func testAccessingContentfulArray() {
        let jsonStr = """
        {
            "sys": {
                "space": {
                    "sys": {
                        "type": "Link",
                        "linkType": "Space",
                        "id": "cfexampleapi"
                    }
                },
                "id": "6KntaYXaHSyIw8M6eo26OK",
                "type": "Entry",
                "createdAt": "2013-11-06T09:45:27.475Z",
                "updatedAt": "2013-11-18T09:13:37.808Z",
                "environment": {
                    "sys": {
                        "id": "master",
                        "type": "Link",
                        "linkType": "Environment"
                    }
                },
                "revision": 2,
                "contentType": {
                    "sys": {
                        "type": "Link",
                        "linkType": "ContentType",
                        "id": "dog"
                    }
                },
                "locale": "en-US"
            },
            "fields": {
                "name": "Doge",
                "description": "such json\\nwow",
                "image": {
                    "sys": {
                        "type": "Link",
                        "linkType": "Asset",
                        "id": "1x0xpXu4pSGS4OukSyWGUK"
                    }
                }
            }
        }
        """

        let json = jsonStr.data(using: .utf8)!
        let decodedJSON = try! JSONDecoder().decode(JSON.self, from: json)

        XCTAssertEqual(decodedJSON.sys?.id?.string, "6KntaYXaHSyIw8M6eo26OK")
        XCTAssertEqual(decodedJSON.sys?.contentType?.sys?.id?.string, "dog")
        XCTAssertEqual(decodedJSON.fields?.image?.sys?.linkType?.string, "Asset")
        XCTAssertEqual(decodedJSON.fields?.name?.string, "Doge")
    }

    func testDisambiguationBetweenBoolsAndNumbers() {
        let jsonStr = """
        {
            "key1": true,
            "key2": 44,
            "key3": 0.0,
            "key4": 5.55,
            "key5": 0,
        }
        """

        let json = jsonStr.data(using: .utf8)!
        let decodedJSON = try! JSONDecoder().decode(JSON.self, from: json)
        XCTAssertEqual(decodedJSON.key1?.bool, true)
        XCTAssertEqual(decodedJSON.key2?.int, 44)
        XCTAssertEqual(decodedJSON.key4?.double, 5.55)
        XCTAssertEqual(decodedJSON.key4?.int, 5)

        // Ensure zero and non-zero numbers are not bools.
        XCTAssertEqual(decodedJSON.key4?.bool, nil)
        XCTAssertEqual(decodedJSON.key2?.bool, nil)
        XCTAssertEqual(decodedJSON.key5?.bool, nil)

    }

    func testEncoding() {
        let jsonStr = """
        {
            "key1": true,
            "key2": 44,
            "key3": 0.0,
            "key4": 5.55,
            "key5": 0,
            "key6": [
                false,
                "hello",
                45
            ],
            "key7": []
        }
        """

        let json = jsonStr.data(using: .utf8)!
        let decodedJSON = try! JSONDecoder().decode(JSON.self, from: json)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encoded = try! encoder.encode(decodedJSON)
        let encodedJSONString = String(data: encoded, encoding: .utf8)!
        print(encodedJSONString)
    }
}
