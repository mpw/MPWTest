//
// (C) Copyright Tilo Prütz
//

#include "TTestCase.h"


#include <objc/runtime.h>

//#include "TUnit/NSException.h"
//#include "TUnit/TMockController.h"
//#include "TUnit/TMockMessage.h"
//#include "TUnit/TObject.Mock.h"


@interface NSException(exceptionAt)

+exceptionAt: (const char*)file : (int)line withMessage:(NSString*)msg;
+(void)raiseAt: (const char*)file : (int)line withMessage:(NSString*)msg;
@end


@implementation NSException(exceptionAt)

+exceptionAt: (const char*)file : (int)line withMessage:(NSString*)msg
{
	return [NSException exceptionWithName:@"exception" reason:[NSString stringWithFormat:@"%@ %s %d",msg,file,line] userInfo:nil];
}

+(void)raiseAt: (const char*)file : (int)line withMessage:(NSString*)msg
{
	[[self exceptionAt:file :line withMessage:msg] raise];
}


@end



TUnitCallBack *tUnitBeforeSetUp = NULL;


static NSString *__baseDir = nil;
static NSString *__dataDir = nil;
static NSString *__package = nil;


@implementation TTestCase:NSObject
{
    NSString *_hint;
}


- (void)dealloc
{
    [_hint release];
    [super dealloc];
}


- (NSString *)assertionMessage: (NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *reason = [[[NSString alloc] initWithFormat: format arguments: args] autorelease];
    va_end(args);
    NSString *message = [NSString stringWithFormat: @"Assertion failed: %@", reason];
    if (_hint != nil) {
        message = [NSString stringWithFormat: @"%@ (%@)", message, _hint];
    }
    return message;
}



- (NSString *)_dictDiff: (NSDictionary *)dict1 : (NSDictionary *)dict2
{
    NSMutableArray *msgs = [NSMutableArray array];
    NSMutableArray *keys1 = [NSMutableArray arrayWithArray: [dict1 allKeys]];
    NSMutableArray *keys2 = [NSMutableArray arrayWithArray: [dict2 allKeys]];
	NSEnumerator *dictKeys = [dict1 keyEnumerator];
	id key=nil;
    while (key=[dictKeys nextObject]) {
        id value1 = [dict1 objectForKey: key];
        id value2 = [dict2 objectForKey: key];
        if (value2 != nil) {
            if (![value1 isEqual: value2]) {
                NSString *msg = nil;
                if ([value1 isKindOfClass: [NSDictionary class]] &&
                        [value2 isKindOfClass: [NSDictionary class]]) {
                    msg = [self _dictDiff: value1 : value2];
                }
                [msgs addObject: [NSString stringWithFormat: @"%@: %@ != %@%s%@",
                        [self objDescription: key], [self _description: value1],
                        [self _description: value2], msg != nil ? ":\n" : "", msg]];
            }
            [keys1 removeObject: key];
            [keys2 removeObject: key];
        }
    }
    if ([keys1 count]>0) {
        [msgs addObject: [NSString stringWithFormat: @"Only in expected dict: %@\n",
                [self objDescription:
                [keys1 arrayByFilteringWithObject: self andSelector: @selector(_description:)]]]];
    }
    if ([keys2 count]>0) {
        [msgs addObject: [NSString stringWithFormat: @"Only in result dict: %@\n",
                [self objDescription:
                [keys2 arrayByFilteringWithObject: self andSelector: @selector(_description:)]]]];
    }
    return [msgs componentsJoinedByString: @"\n\n"];
}

- (void)_assert: obj1 equals: obj2 file: (const char *)file line: (int)line
{
    if ((obj1 != nil || obj2 != nil) && ![obj1 isEqual: obj2]) {
        NSString *msg = nil;
        if ([obj1 isKindOfClass: [NSDictionary class]] && [obj2 isKindOfClass: [NSDictionary class]]) {
            msg = [self _dictDiff: obj1 : obj2];
        }
        @throw [NSException exceptionAt: file : line withMessage: [self assertionMessage:
																   @"»%@« is not equal »%@«%s%@", obj1, obj2, msg != nil ? ":\n" : "", msg]];
    }
}



- (NSString *)_description: obj
{
    return [NSString stringWithFormat: @"(%@) %@", [obj className], [self objDescription: obj]];
}


#if 0
- objDescription: obj
{
    return objc_get_class(obj) == [TMock class] ? (id)[TMockController descriptionFor: obj] : obj;
}
#else
- objDescription: obj
{
    return  obj;
}

#endif

- (void)_assertInt: (int)int1 equalsInt: (int)int2 file: (const char *)file line: (int)line
{
    if (int1 != int2) {
        @throw [NSException exceptionAt: file : line withMessage: [self assertionMessage:
                @"%d is not equal %d", int1, int2]];
    }
}


- (void)_assertUInt: (unsigned long)int1 equalsUInt: (unsigned long)int2
        file: (const char *)file line: (int)line
{
    if (int1 != int2) {
        @throw [NSException exceptionAt: file : line withMessage: [self assertionMessage:
                @"%lu is not equal %lu", int1, int2]];
    }
}


- (void)_assertInt: (int)int1 isGreaterThan: (int)int2
        file: (const char *)file line: (int)line
{
    if (int1 <= int2) {
        @throw [NSException exceptionAt: file : line withMessage: [self assertionMessage:
                @"%d is not greater than %d", int1, int2]];
    }
}


- (void)_assertInt: (int)int1 isLessThan: (int)int2
        file: (const char *)file line: (int)line
{
    if (int1 >= int2) {
        @throw [NSException exceptionAt: file : line withMessage: [self assertionMessage:
                @"%d is not less than %d", int1, int2]];
    }
}


- (void)_assert: obj1 isIdenticalTo: obj2
        file: (const char *)file line: (int)line
{
    if (obj1 != obj2) {
        @throw [NSException exceptionAt: file : line withMessage: [self assertionMessage:
                @"%@(%p) is not identical to %@(%p)", obj1, obj1, obj2, obj2]];
    }
}


- (void)_assert: (NSString *)expression isTrue: (BOOL)isTrue
        shouldBeFalse: (BOOL)shouldBeFalse file: (const char *)file
        line: (int)line
{
    if ((!isTrue && !shouldBeFalse) || (isTrue && shouldBeFalse)) {
        @throw [NSException exceptionAt: file : line withMessage: [self assertionMessage:
                @"%@ is not %s", expression, shouldBeFalse ? "false" : "true"]];
    }
}


- (void)_assert: obj isKindOfClass: (Class)expectedClass
        file: (const char *)file line: (int)line
{
    if (![obj isKindOfClass: expectedClass]) {
        @throw [NSException exceptionAt: file : line withMessage: [self assertionMessage:
                @"object's class %@ is not kind of expected class %@",
                [obj className], [expectedClass className]]];
    }
}


- (void)_assertList: (NSArray *)got containsElementsFrom: (NSArray *)expected
        file: (const char *)file line: (int)line
{
    [self _assertList: got containsElementsFrom: expected failOnUnexpected: NO
            file: file line: line];
}


- (void)_assertList: (NSArray *)got containsEqualElementsAs: (NSArray *)expected
        file: (const char *)file line: (int)line
{
    [self _assertList: got containsElementsFrom: expected failOnUnexpected: YES
            file: file line: line];
}


- (void)_assertList: (NSArray *)got containsElementsFrom: (NSArray *)expected
        failOnUnexpected: (BOOL)failOnUnexpected file: (const char *)file line: (int)line
{
    id unexpected = [NSMutableArray array];
    if (failOnUnexpected) {
		NSEnumerator *gotten=[got objectEnumerator];
		id current=nil;
        while ( current=[gotten nextObject] ) {
            if (![expected containsObject: current]) {
                [unexpected addObject: current];
            }
        }
    }
    id missed = [NSMutableArray array];

	NSEnumerator *expectedEnum=[expected objectEnumerator];
	id current=nil;
	while ( current=[expectedEnum nextObject] ) {
		if (![got containsObject: current]) {
			[missed addObject: current];
		}
	}
    if ([unexpected count] > 0 || [missed count] > 0) {
        @throw [NSException exceptionAt: file : line withMessage: [self assertionMessage:
                @"%@ does not contain the same elements as the expected list %@:%s%@%s%@",
                got, expected,
                [unexpected count] > 0 ? "\nUnexpected: " : "",
                [unexpected count] > 0 ? unexpected : nil,
                [missed count] > 0 ? "\nMissed: " : "",
                [missed count] > 0 ? missed : nil]];
    }
}


- (void)_assert: obj hasSubstring: (NSString *)string file: (const char *)file line: (int)line
{
    if (obj == nil || string == nil ||
            strstr([[obj stringValue] cString], [string cString]) == NULL) {
        @throw [NSException exceptionAt: file : line withMessage: [self assertionMessage:
                @"%@ does not have the substring %@", obj, string]];
    }
}


- (void)_assert: (NSString *)value matches: (NSString *)expected
        file: (const char *)file line: (int)line
{
    if (![value matches: expected]) {
        @throw [NSException exceptionAt: file : line withMessage: [self assertionMessage:
                @"value %@ does not match expression %@.", value, expected]];
    }
}


- (void)setHint: (NSString *)hint
{
    if (_hint != hint) {
        [_hint release];
        _hint = [hint retain];
    }
}


- (void)clearHint
{
    [_hint release];
    _hint = nil;
}


- (void)setUp
{
}


- (void)tearDown
{
}


+ (void)noTest
{
    @throw [NSException exceptionAt: __FILE__ : __LINE__ withMessage:
            @"TTestCase runs selectors without prefix 'test'."];
}


- (void)noTest
{
    @throw [NSException exceptionAt: __FILE__ : __LINE__ withMessage:
            @"TTestCase runs selectors without prefix 'test'."];
}


- (void)printRunning
{
#if 0
    [TUserIO print: @"objc."];
    if ([__package containsData]) {
        [TUserIO print: __package];
        [TUserIO print: @"."];
    }
    [TUserIO print: [self className]];
   [TUserIO print: @" "];
#else
	NSLog(@"objc.%@",[self className]);
#endif
}


#if 0

- (int)run: (NSString *)methodFilter
{
    int failures = 0;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    struct objc_method_list *list = [self class]->methods;

    [self printRunning];
    while (list != NULL) {
        for (int i = list->method_count; i-- > 0;) {
            NSAutoreleasePool *testPool = [[NSAutoreleasePool alloc] init];
            SEL sel = list->method_list[i].method_name;
            NSString *method = [TUtils stringFromSelector: sel];

            if (([method hasPrefix: @"test"] || [method hasPrefix: @"itShould"]) &&
                    (nil == methodFilter || [method matches: methodFilter]) &&
                    ![method matches: @"Broken$"]) {
                TStack *exceptions = [TStack stack];
                @try {
                    [self clearHint];
                    [TMockMessage cleanupOrderedMessages];
                    if (tUnitBeforeSetUp != NULL) {
                        tUnitBeforeSetUp();
                    }
                    [self setUp];
                    @try {
                        [TUserIO print: @"."];
                        [self perform: sel];
                    } @catch(id e) {
                        [exceptions push: [e autorelease]];
                    } @finally {
                        @try {
                            verifyAndCleanupMocks();
                        } @catch(id e) {
                            [exceptions push: [e autorelease]];
                        } @finally {
                            [self tearDown];
                        }
                    }
                } @catch(id e) {
                    [exceptions push: [e autorelease]];
                }
                if ([exceptions containsData]) {
                    ++failures;
                    [TUserIO eprintln: @"ERROR: Test %@:%@ failed - %@",
                            [self className], method, [exceptions pop]];
                    while ([exceptions containsData]) {
                        [TUserIO eprintln: @"Root cause:\n%@", [exceptions pop]];
                    }
                }
            }
            [testPool release];
        }
        list = list->method_next;
    }
    [TUserIO println: failures == 0 ? @" OK" : @" FAILED"];
    [pool release];
    return failures;
}


+ (NSString *)testDataDir
{
    NSString *dir = [self objectForClassKey: @"TEST_DATA_DIR"];
    if (dir == nil) {
        dir = [TFile stringByAppendingPath: [self className] to: __dataDir];
        [self setObject: dir forClassKey: @"TEST_DATA_DIR"];
        [TFile makePath: dir];
    }
    return dir;
}

#endif

- (NSString *)testDataDir
{
    return [[self class] testDataDir];
}


+ (NSString *)testBaseDir
{
    return __baseDir;
}


- (NSString *)testBaseDir
{
    return [[self class] testBaseDir];
}

//---- MPWTest integration

+testFixture
{
	id fixture=[[[self alloc] init] autorelease];
}

+testSelectors
{
	NSMutableArray *testSelectors=[NSMutableArray array];
	if ( self != [TTestCase class] ) { 
		int methodCount=0;
		Method *methods= class_copyMethodList(self, &methodCount);
		for (int i=0;i<methodCount;i++) {
			NSString *msgName=NSStringFromSelector( method_getName( methods[i]) );
			if ( [msgName hasPrefix:@"test"] || [msgName hasPrefix:@"itShould"] ) {
				[testSelectors addObject:msgName];
			}
		}
	}
	return testSelectors;
}

-(void)doTestBasic:(NSString*)testName withTest:test
{
    SEL testMethod=NSSelectorFromString(testName);
	
    if ( testMethod &&  [self respondsToSelector:testMethod] ) {
        objc_msgSend( self, testMethod );
    } else {
        [NSException raise:@"test-inconsistency" format:@"error: fixture %@ doesn't respond to test message %@ for test %@",self,testName,[test description]];
    }
}


-(void)doTest:(NSString*)testName withTest:test
{
	[self setUp];
	[self doTestBasic:testName withTest:test];
	[self tearDown];
}

@end


#if 0
int objcmain(int argc, char *argv[])
{
    int result = 0;
    void *classIterator = NULL;
    Class class;
    Class testCaseClass = [TTestCase class];
    if (argc < 4) {
        @throw [NSException exceptionWithMessage: @"Need test base dir, data dir and package"];
    }
    __baseDir = [[NSString stringWithCString: argv[1]] retain];
    __dataDir = [[NSString stringWithCString: argv[2]] retain];
    __package = [[NSString stringWithCString: argv[3]] retain];
    NSString *classFilter = (argc > 4) ? [NSString stringWithCString: argv[4]] : nil;
    NSString *methodFilter = (argc > 5) ? [NSString stringWithCString: argv[5]] : nil;
    if ([classFilter hasSuffix: @"Test"]) {
        classFilter = [classFilter substringToIndex: [classFilter length] - 4];
    }

    NSMutableDictionary *testClasses = [NSMutableDictionary dictionary];
    while ((class = objc_next_class(&classIterator)) != Nil) {
        if (class_get_class_method(class->class_pointer, @selector(isKindOfClass:)) &&
                [class isKindOfClass: testCaseClass] && ![[class className] matches: @"TestCase$"] &&
                (classFilter == nil || [[class className] matches: classFilter])) {
            [testClasses setObject: class forKey: [class className]];
        }
    }
    for (id i = [[[testClasses allKeys] sortedArrayUsingSelector:
            @selector(caseInsensitiveCompare:)] iterator]; [i hasCurrent]; [i next]) {
        TTestCase *test = nil;
        @try {
            test = [[[testClasses objectForKey: [i current]] alloc] init];
            result += [test run: methodFilter];
        } @finally {
            [test release];
        }
    }
    return result;
}
#endif
