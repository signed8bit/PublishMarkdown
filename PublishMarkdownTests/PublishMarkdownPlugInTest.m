//
//  PublishMarkdownPlugInTest.m
//  PublishMarkdownPlugInTest
//
//  Created by Matthew Montgomery on 9/8/13.
//  Copyright (c) 2013 Matthew Montgomery. All rights reserved.
//

#import "PublishMarkdownPlugInTest.h"
#import "PublishMarkdownPlugIn.h"

@implementation PublishMarkdownPlugInTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testShouldConvertFileAtPath
{
    STAssertTrue([PublishMarkdownPlugIn shouldConvertFileAtPath:@"/the/path/to/file.md.html"], nil);

    STAssertFalse([PublishMarkdownPlugIn shouldConvertFileAtPath:nil], nil);
    STAssertFalse([PublishMarkdownPlugIn shouldConvertFileAtPath:@""], nil);
    STAssertFalse([PublishMarkdownPlugIn shouldConvertFileAtPath:@"/the/path/to/file.txt"], nil);
    STAssertFalse([PublishMarkdownPlugIn shouldConvertFileAtPath:@"/the/path/to/file.html"], nil);
}

- (void)testConvertMarkdownToHtml
{
    NSString *expected;
    expected = @"<pre><code>This is a code line.\n</code></pre>\n";

    NSString *result;
    result = [PublishMarkdownPlugIn convertMarkdownToHtml:@"    This is a code line."];

    STAssertTrue([expected isEqualToString:result], nil);
}

- (void)testMergeWithTemplate
{
    NSString *result;
    result = [PublishMarkdownPlugIn mergeWithTemplate:@"<p>This is a paragraph.</p>"];

    STAssertTrue([result rangeOfString:@"<p>This is a paragraph.</p>"].location != NSNotFound, nil);
}

- (void)testWriteTempFile
{
    STAssertNotNil([PublishMarkdownPlugIn writeTempFile:@"Testing 1 2 3"], nil);
}

@end
