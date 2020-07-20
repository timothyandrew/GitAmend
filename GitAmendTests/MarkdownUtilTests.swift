//
//  MarkdownUtilTests.swift
//  GitAmendTests
//
//  Created by Timothy Andrew on 20/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import XCTest
import GitAmend

class MarkdownUtilTests: XCTestCase {
    func testBasic() {
        let (title, url) = MarkdownUtil.parse(mdUrl: "* [foo](bar)")!
        XCTAssertEqual(title, "foo")
        XCTAssertEqual(url, "bar")
    }
    
    func testMedium() {
        let (title, url) = MarkdownUtil.parse(mdUrl: "* [A Terrible, Horrible, No-Good, Very Bad Day at Slack](https://slack.engineering/a-terrible-horrible-no-good-very-bad-day-at-slack-dfe05b485f82)")!
        XCTAssertEqual(title, "A Terrible, Horrible, No-Good, Very Bad Day at Slack")
        XCTAssertEqual(url, "https://slack.engineering/a-terrible-horrible-no-good-very-bad-day-at-slack-dfe05b485f82")
    }
    
    func testInvalid() {
        let result = MarkdownUtil.parse(mdUrl: "notaurl")
        XCTAssertNil(result)
    }
}
