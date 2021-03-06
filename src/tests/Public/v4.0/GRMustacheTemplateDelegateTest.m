// The MIT License
// 
// Copyright (c) 2012 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustacheTemplateDelegateTest.h"

@interface GRMustacheTemplateDelegateAssistant : NSObject
@property (nonatomic, retain) NSString *stringProperty;
@end

@implementation GRMustacheTemplateDelegateAssistant
@synthesize stringProperty;
@end

@interface GRMustacheTemplateRecorder : NSObject<GRMustacheTemplateDelegate>
@property (nonatomic, retain) GRMustacheInvocation *lastInvocation;
@property (nonatomic) NSUInteger templateWillRenderCount;
@property (nonatomic) NSUInteger templateDidRenderCount;
@property (nonatomic) NSUInteger willRenderReturnValueOfInvocationCount;
@property (nonatomic) NSUInteger didRenderReturnValueOfInvocationCount;
@property (nonatomic) NSUInteger nilReturnValueCount;
@property (nonatomic, retain) NSString *lastUsedValue;
@property (nonatomic, retain) NSString *lastUsedKey;
@end

@implementation GRMustacheTemplateRecorder
@synthesize lastInvocation=_lastInvocation;
@synthesize templateWillRenderCount=_templateWillRenderCount;
@synthesize templateDidRenderCount=_templateDidRenderCount;
@synthesize willRenderReturnValueOfInvocationCount=_willRenderReturnValueOfInvocationCount;
@synthesize didRenderReturnValueOfInvocationCount=_didRenderReturnValueOfInvocationCount;
@synthesize nilReturnValueCount=_nilReturnValueCount;
@synthesize lastUsedValue=_lastUsedValue;
@synthesize lastUsedKey=_lastUsedKey;

- (void)dealloc
{
    self.lastUsedValue = nil;
    self.lastUsedKey = nil;
    self.lastInvocation = nil;
    [super dealloc];
}

- (void)templateWillRender:(GRMustacheTemplate *)template
{
    self.templateWillRenderCount += 1;
}

- (void)templateDidRender:(GRMustacheTemplate *)template
{
    self.templateDidRenderCount += 1;
}

- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation
{
    self.lastInvocation = invocation;
    self.willRenderReturnValueOfInvocationCount += 1;
    self.lastUsedKey = invocation.key;
    self.lastUsedValue = invocation.returnValue;
    if (invocation.returnValue) {
        if ([invocation.returnValue isKindOfClass:[NSString class]]) {
            invocation.returnValue = [[invocation.returnValue description] uppercaseString];
        }
    } else {
        self.nilReturnValueCount += 1;
    }
}

- (void)template:(GRMustacheTemplate *)template didRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation
{
    self.didRenderReturnValueOfInvocationCount += 1;
}

@end

@implementation GRMustacheTemplateDelegateTest

- (void)testTemplateWillRender
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.templateWillRenderCount, (NSUInteger)1, @"");
}

- (void)testTemplateDidRender
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.templateDidRenderCount, (NSUInteger)1, @"");
}

- (void)testTemplateWillRenderIsNotCalledForPartial
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle];
    GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTemplateDelegateTest}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.templateWillRenderCount, (NSUInteger)1, @"");
}

- (void)testTemplateDidRenderIsNotCalledForPartial
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle];
    GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTemplateDelegateTest}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.templateDidRenderCount, (NSUInteger)1, @"");
}

- (void)testWillRenderReturnValueOfInvocationWithText
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"---" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.willRenderReturnValueOfInvocationCount, (NSUInteger)0, @"");
}

- (void)testDidRenderReturnValueOfInvocationWithText
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"---" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.didRenderReturnValueOfInvocationCount, (NSUInteger)0, @"");
}

- (void)testWillRenderReturnValueOfInvocationWithVariable
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}{{bar}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.willRenderReturnValueOfInvocationCount, (NSUInteger)2, @"");
}

- (void)testDidRenderReturnValueOfInvocationWithVariable
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}{{bar}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.didRenderReturnValueOfInvocationCount, (NSUInteger)2, @"");
}

- (void)testWillRenderReturnValueOfInvocationWithUnrenderedSection
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#foo}}{{bar}}{{/foo}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.willRenderReturnValueOfInvocationCount, (NSUInteger)1, @"");
}

- (void)testDidRenderReturnValueOfInvocationWithUnrenderedSection
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#foo}}{{bar}}{{/foo}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.didRenderReturnValueOfInvocationCount, (NSUInteger)1, @"");
}

- (void)testWillRenderReturnValueOfInvocationWithRenderedSectionAndVariable
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{^foo}}{{bar}}{{/foo}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.willRenderReturnValueOfInvocationCount, (NSUInteger)2, @"");
}

- (void)testDidRenderReturnValueOfInvocationWithRenderedSectionAndVariable
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{^foo}}{{bar}}{{/foo}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.didRenderReturnValueOfInvocationCount, (NSUInteger)2, @"");
}

- (void)testDelegateCanReadInvocationReturnValue
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}{{bar}}" error:NULL];
    template.delegate = recorder;
    [template renderObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"foo"]];
    STAssertEquals(recorder.nilReturnValueCount, (NSUInteger)1, @"");
}

- (void)testDelegateCanReadInvocationReturnValueFromKeyPath
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{1.stringProperty}}" error:NULL];
    template.delegate = recorder;
    GRMustacheTemplateDelegateAssistant *assistant1 = [[[GRMustacheTemplateDelegateAssistant alloc] init] autorelease];
    assistant1.stringProperty = @"foo";
    [template renderObject:[NSDictionary dictionaryWithObjectsAndKeys:assistant1, @"1", nil]];
    STAssertEqualObjects(recorder.lastUsedValue, @"foo", @"");
}

- (void)testDelegateCanReadInvocationKey
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEqualObjects(recorder.lastUsedKey, @"foo", @"");
}

- (void)testDelegateCanReadInvocationKeyFromKeyPath
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo.bar.baz}}" error:NULL];
    template.delegate = recorder;
    [template renderObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"foo"]];
    STAssertEqualObjects(recorder.lastUsedKey, @"bar", @"");
}

- (void)testDelegateCanWriteInvocationReturnValue
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}" error:NULL];
    template.delegate = recorder;
    NSString *result = [template renderObject:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]];
    STAssertEqualObjects(result, @"BAR", @"");
}

- (void)testInvocationDescriptionContainsTag
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template;
    NSString *description;
    NSRange range;
    
    template = [GRMustacheTemplate templateFromString:@"{{name}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [description rangeOfString:@"{{name}}"];
    STAssertTrue(range.location != NSNotFound, @"");
    
    template = [GRMustacheTemplate templateFromString:@"{{#name}}{{/name}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [description rangeOfString:@"{{#name}}"];
    STAssertTrue(range.location != NSNotFound, @"");
    
    template = [GRMustacheTemplate templateFromString:@"{{   name\t}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [description rangeOfString:@"{{   name\t}}"];
    STAssertTrue(range.location != NSNotFound, @"");
}

- (void)testInvocationDescriptionContainsLineNumber
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template;
    NSString *description;
    NSRange range;
    
    template = [GRMustacheTemplate templateFromString:@"{{name}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:@"line 1"];
    STAssertTrue(range.location != NSNotFound, @"");
    
    template = [GRMustacheTemplate templateFromString:@"\n {{name}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [description rangeOfString:@"line 2"];
    STAssertTrue(range.location != NSNotFound, @"");
    
    template = [GRMustacheTemplate templateFromString:@"\n\n  {{#name}}\n\n{{/name}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [description rangeOfString:@"line 3"];
    STAssertTrue(range.location != NSNotFound, @"");
}

- (void)testInvocationDescriptionContainsResourceBasedTemplatePath
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template;
    NSString *description;
    NSRange range;
    
    template = [GRMustacheTemplate templateFromResource:@"GRMustacheTemplateDelegateTest" bundle:self.testBundle error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle];
    template = [repository templateForName:@"GRMustacheTemplateDelegateTest" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
}

- (void)testInvocationDescriptionContainsURLBasedTemplatePath
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template;
    NSString *description;
    NSRange range;
    
    template = [GRMustacheTemplate templateFromContentsOfURL:[self.testBundle URLForResource:@"GRMustacheTemplateDelegateTest" withExtension:@"mustache"] error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:[self.testBundle resourceURL]];
    template = [repository templateForName:@"GRMustacheTemplateDelegateTest" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
}

- (void)testInvocationDescriptionContainsPathBasedTemplatePath
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template;
    NSString *description;
    NSRange range;
    
    template = [GRMustacheTemplate templateFromContentsOfFile:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"] error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:[self.testBundle resourcePath]];
    template = [repository templateForName:@"GRMustacheTemplateDelegateTest" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
}

- (void)testInvocationDescriptionContainsResourceBasedPartialPath
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template;
    NSString *description;
    NSRange range;
    
    template = [GRMustacheTemplate templateFromResource:@"GRMustacheTemplateDelegateTest_wrapper" bundle:self.testBundle error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle];
    
    template = [repository templateForName:@"GRMustacheTemplateDelegateTest_wrapper" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    template = [repository templateFromString:@"{{>GRMustacheTemplateDelegateTest}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
}

- (void)testInvocationDescriptionContainsURLBasedPartialPath
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template;
    NSString *description;
    NSRange range;
    
    template = [GRMustacheTemplate templateFromContentsOfURL:[self.testBundle URLForResource:@"GRMustacheTemplateDelegateTest_wrapper" withExtension:@"mustache"] error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:[self.testBundle resourceURL]];
    
    template = [repository templateForName:@"GRMustacheTemplateDelegateTest_wrapper" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    template = [repository templateFromString:@"{{>GRMustacheTemplateDelegateTest}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
}

- (void)testInvocationDescriptionContainsPathBasedPartialPath
{
    GRMustacheTemplateRecorder *recorder = [[[GRMustacheTemplateRecorder alloc] init] autorelease];
    GRMustacheTemplate *template;
    NSString *description;
    NSRange range;
    
    template = [GRMustacheTemplate templateFromContentsOfFile:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest_wrapper" ofType:@"mustache"] error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:[self.testBundle resourcePath]];
    
    template = [repository templateForName:@"GRMustacheTemplateDelegateTest_wrapper" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    template = [repository templateFromString:@"{{>GRMustacheTemplateDelegateTest}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
}

@end
