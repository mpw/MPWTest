//
// (C) Copyright Tilo Prütz
//

#import "TTestCase.h"
#import "TMockController.h"
#import "MPWMethodMirror.h"
#import "MPWClassMirror.h"

#include <objc/runtime.h>

//#include "TUnit/NSException.h"
//#include "TUnit/TMockController.h"
//#include "TUnit/TMockMessage.h"
//#include "TUnit/TObject.Mock.h"

#pragma .h #import <Foundation/Foundation.h>
#pragma .h #include "HSFoundation.h"
#pragma .h #include "AccessorMacros.h"
int PROFILE_CHANNEL_TEST = 0;
#pragma .h extern int PROFILE_CHANNEL_TEST;
#pragma .h #define PROFILE_CHANNEL_NAME_TEST @"test"


#define MPWTEST 1    // 

@implementation NSException(exceptionAt)

+exceptionAt: (const char*)file : (int)line withMessage:(NSString*)msg
{
	return [NSException exceptionWithName:@"exception" reason:[NSString stringWithFormat:@"%@ %s %d",msg,file,line] userInfo:nil];
}

+exceptionAt: (const char*)file : (int)line withFormat:(NSString*)msg,...
{
	return [self exceptionAt: file : line withMessage:msg];
}


+(void)raiseAt: (const char*)file : (int)line withMessage:(NSString*)msg
{
	[[self exceptionAt:file :line withMessage:msg] raise];
}


@end


#pragma .h typedef void(TUnitCallBack)();
#pragma .h extern TUnitCallBack *tUnitBeforeSetUp;
#pragma .h #define _ASSERT(sel) [self sel file: __FILE__ line: __LINE__]; [self clearHint];
#pragma .h #define ASSERTEQUALSINT(int1, int2) _ASSERT(_assertInt: int1 equalsInt: int2)
#pragma .h #define ASSERTEQUALSUINT(int1, int2) _ASSERT(_assertUInt: int1 equalsUInt: int2)
#pragma .h #define ASSERTISGREATERTHANINT(int1, int2) _ASSERT(_assertInt: int2 isGreaterThan: int1)
#pragma .h #define ASSERTISLESSTHANINT(int1, int2) _ASSERT(_assertInt: int2 isLessThan: int1)
#pragma .h #define ASSERTEQUALS(obj1, obj2) _ASSERT(_assert: obj1 equals: obj2)
#pragma .h #define ASSERTIDENTICAL(obj1, obj2) _ASSERT(_assert: obj1 isIdenticalTo: obj2)
#pragma .h #define ASSERT(x) _ASSERT(_assert: @#x isTrue: x shouldBeFalse: NO)
#pragma .h #define ASSERTFALSE(x) _ASSERT(_assert: @#x isTrue: x shouldBeFalse: YES)
#pragma .h #define ASSERTNIL(x) ASSERT((x) == nil);
#pragma .h #define ASSERTNOTNIL(x) ASSERT((x) != nil);
#pragma .h #define ASSERTKINDOF(expectedClass, obj) _ASSERT(_assert: obj isKindOf: expectedClass)
#pragma .h #define ASSERTLISTCONTENTSEQUAL(expected, got)\
#pragma .h         _ASSERT(_assertList: got containsEqualElementsAs: expected)
#pragma .h #define ASSERTLISTCONTAINS(expected, got)\
#pragma .h         _ASSERT(_assertList: got containsElementsFrom: expected)
#pragma .h #define ASSERTSUBSTRING(expected, got) _ASSERT(_assert: got hasSubstring: expected)
#pragma .h #define ASSERTMATCHES(expected, result) _ASSERT(_assert: result matches: expected)

#pragma .h #define ASSERTISFASTERTHAN(fast, slow, howMany) {\
#pragma .h     long long __fastTime__ = [TTime currentTimeMillis];\
#pragma .h \
#pragma .h     for (int __i__ = 0; __i__ < howMany; ++__i__) {\
#pragma .h         fast;\
#pragma .h     }\
#pragma .h     __fastTime__ = [TTime currentTimeMillis] - __fastTime__;\
#pragma .h \
#pragma .h     long long __slowTime__ = [TTime currentTimeMillis];\
#pragma .h \
#pragma .h     for (int __i__ = 0; __i__ < howMany; ++__i__) {\
#pragma .h         slow;\
#pragma .h     }\
#pragma .h     __slowTime__ = [TTime currentTimeMillis] - __slowTime__;\
#pragma .h     ASSERTISLESSTHANINT(__slowTime__, __fastTime__);\
#pragma .h }

#pragma .h #define _FAIL(eClass, eId, expectedE, x, code...) {\
#pragma .h     eClass e = nil;\
#pragma .h     id unexpectedException = nil;\
#pragma .h \
#pragma .h     @try {\
#pragma .h         x;\
#pragma .h     } @catch(eClass caught) {\
#pragma .h         e = caught; \
#pragma .h     } @catch(id u) {\
#pragma .h         unexpectedException = u;\
#pragma .h     }\
#pragma .h     if (e == nil && unexpectedException == nil) {\
#pragma .h         @throw [TTestException exceptionAt: __FILE__ : __LINE__ \
#pragma .h                 withMessage: @#x @" did not fail"];\
#pragma .h     } else if (expectedE != nil && ![expectedE isEqualTo: e]) {\
#pragma .h         @throw [TTestException exceptionAt: __FILE__ : __LINE__ \
#pragma .h                 withFormat: @#x @" failed with unexpected exception %@ instead of %@",\
#pragma .h                 e, expectedE];\
#pragma .h     } else if (unexpectedException != nil) {\
#pragma .h         @throw [TTestException exceptionAt: __FILE__ : __LINE__ \
#pragma .h                 withFormat: @#x @" failed with unexpected exception %@ instead of %@",\
#pragma .h                 unexpectedException, @#eClass];\
#pragma .h     } else if (eId != 0 && eId != [(id)e errorId]) {\
#pragma .h         @throw [TTestException exceptionAt: __FILE__ : __LINE__ \
#pragma .h                 withFormat: @#x@" failed with unexpected exception ID %d instead of %d",\
#pragma .h                 [(id)e errorId], eId];\
#pragma .h     }\
#pragma .h     code;\
#pragma .h }
#pragma .h //#define FAIL(x...) _FAIL(id, 0, nil, x)
#pragma .h #define FIXME_FAIL(x...) _FAIL(id, 0, nil, x)
#pragma .h 
#pragma .h #define FAIL_WITH_CLASS(exceptionClass, x...)\
#pragma .h         _FAIL(exceptionClass *, 0, nil, x)
#pragma .h 
#pragma .h #define FAIL_WITH_CLASS_AND_ID(exceptionClass, exceptionId, x...)\
#pragma .h         _FAIL(exceptionClass *, exceptionId, nil, x)
#pragma .h 
#pragma .h #define FAIL_WITH_EQUAL(expectedException, x...)\
#pragma .h         _FAIL(id, 0, expectedException, x)
#pragma .h 
#pragma .h 
#pragma .h #define FAIL(x) {\
#pragma .h     BOOL __failed__ = NO;\
#pragma .h \
#pragma .h     @try {\
#pragma .h         x;\
#pragma .h     } @catch(NSException *e) {\
#pragma .h         __failed__ = YES;\
#pragma .h     }\
#pragma .h     if (!__failed__) {\
#pragma .h         [NSException raiseAt: __FILE__ : __LINE__ \
#pragma .h                 withMessage: @"Assertion " @#x @" did not fail"];\
#pragma .h     }\
#pragma .h }
#pragma .h #define ASSERTISFAST(expectedMaxMilliSeconds, method, howMany) {\
#pragma .h     long long __expected__ = (long long)expectedMaxMilliSeconds;\
#pragma .h     struct rusage __usage__;\
#pragma .h     long long __before__;\
#pragma .h     long long __after__;\
#pragma .h     getrusage(RUSAGE_SELF, &__usage__);\
#pragma .h     __before__ = (long long)__usage__.ru_utime.tv_sec * 1000000 +\
#pragma .h             (long long)__usage__.ru_utime.tv_usec;\
#pragma .h \
#pragma .h     for (int __i__ = 0; __i__ < howMany; ++__i__) {\
#pragma .h         method;\
#pragma .h     }\
#pragma .h     getrusage(RUSAGE_SELF, &__usage__);\
#pragma .h     __after__ = (long long)__usage__.ru_utime.tv_sec * 1000000 +\
#pragma .h             (long long)__usage__.ru_utime.tv_usec;\
#pragma .h \
#pragma .h     ASSERTISLESSTHANINT(__expected__, (__after__ - __before__) / 1000);\
#pragma .h }

#pragma .h #define TTestException NSException



TUnitCallBack *tUnitBeforeSetUp = NULL;


static NSString *__baseDir = nil;
static NSString *__dataDir = nil;
static NSString *__package = nil;

#if TARGET_OS_MAC
@interface OSEnvironment : NSObject { }
-(NSString*)getEnv:(NSString*)var;
@end
@implementation OSEnvironment
-(NSString*)getEnv:(NSString *)var { return [NSString stringWithUTF8String:getenv([var UTF8String])]; }
@end

#define STRING(s) ([(s) UTF8String])
#define STRINGVALUE(o) STRING([o description])
#define LOGALERT(a,b) 
#endif


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


#if !MPWTEST
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
	if ( [self respondsToSelector:@selector(prepare)] ) {
		[self prepare];
	}
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
#if !MPWTEST
    [TUserIO print: @"objc."];
    if ([__package containsData]) {
        [TUserIO print: __package];
        [TUserIO print: @"."];
    }
    [TUserIO print: [self className]];
   [TUserIO print: @" "];
#else
//	NSLog(@"objc.%@",[self className]);
#endif
}

- (BOOL)runTestMethod: (SEL)sel
{
    NSString *method = NSStringFromSelector(sel);
    BOOL isOk = YES;

#if 0
	NSLog(@"will run: %@",method);
#endif
	@try {
		[self clearHint];
		[self setUp];
		@try {
				printf(".");
//               [OSUserIO print: @"."];
               [self performSelector: sel];
		} @finally {
			@try {
				verifyAndCleanupMocks();
			} @finally {
				[self tearDown];
			}
		}

	} @catch (id e ) {
		isOk = NO;
		NSLog(@"Test %@:%@ failed %@",[self class],method,e);	
	}
	return isOk;
}

static int runs=0;

- (int)run
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int failures = 0;

    NSString *methodFilter = [OSEnvironment getEnv: @"TESTMETHOD"];
    [self printRunning];
#if 1
	return 10;
	MPWClassMirror *classMirror=[MPWClassMirror mirrorWithClass:[self class]];
	
	for ( MPWMethodMirror *method in [classMirror methodMirrors] ) {
		NSAutoreleasePool *testPool = [[NSAutoreleasePool alloc] init];
		NSString *methodName = [method name];
		if ( [methodName hasPrefix:"@test"] || [methodName hasPrefix:"itShould"] ) {
			if (nil != methodFilter && ![methodName matches: methodFilter]) {
				// skip tests specified in TESTMETHOD-filter
			} else if ([methodName matches: @"Broken$"]) {
				// skip broken tests
			} else {
				runs++;
				if (![self runTestMethod: [method selector]]) {
					++failures;
				}
			}
		}
		[testPool release];
	}
#else	
	Method *methodList=class_copyMethodList( [self class], &methodCount );
	if ( methodList ) {
		for (int i=0;i<methodCount;i++) {
            NSAutoreleasePool *testPool = [[NSAutoreleasePool alloc] init];
			Method m=methodList[i];
			SEL sel=method_getName(m);
			NSString *method=NSStringFromSelector(sel);
            if ([method hasPrefix: @"test"] || [method hasPrefix: @"itShould"]) {
 			}
			[testPool release];
		}
		free(methodList);
	}
#endif

	[pool release];
	return failures;	
}

#if !MPWTEST

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
                        [exceptions push: e];
                    } @finally {
                        @try {
                            verifyAndCleanupMocks();
                        } @catch(id e) {
                            [exceptions push: e];
                        } @finally {
                            [self tearDown];
                        }
                    }
                } @catch(id e) {
                    [exceptions push: e];
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


#endif


+ (NSString *)testDataDir
{
    return [[OSEnvironment getEnv: @"TEST_DATA_DIR"]
            stringByAppendingPathComponent: NSStringFromClass([self class])];
}


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
	return fixture;
}

+testSelectors
{
	NSMutableArray *testSelectors=[NSMutableArray array];
	if ( self != [TTestCase class] ) { 
		NSArray *methods = [[MPWClassMirror mirrorWithClass:self] methodMirrors];
		
		for (int i=0;i<[methods count];i++) {
			NSString *msgName=[[methods objectAtIndex:i] name];
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
        [self performSelector:testMethod];
    } else {
        [NSException raise:@"test-inconsistency" format:@"error: fixture %@ doesn't respond to test message %@ for test %@",self,testName,[test description]];
    }
}


-(void)doTest:(NSString*)testName withTest:test
{
	[self setUp];
	@try {
		[self doTestBasic:testName withTest:test];
	}
	@finally {
		[TMockController removeMocks];
		[self tearDown];
	}
}

@end


void uncaughtNSExceptionHandler(NSException* exception)
{
    LOGALERT(@"Uncaught Objective-C exception:\n%s",
            STRING([exception errorString]));
    [NSException printBacktrace];
    abort();
}

int debug=0;
int objcmain(int argc, char *argv[])
{
	MPWClassMirror *currentClass;
    int result = 0;

    if (argc > 1) {
        debug = atoi(argv[1]);
    }

    NSString *classFilter = [OSEnvironment getEnv: @"TESTCLASS"];
    if ([classFilter hasSuffix: @"Test"]) {
        classFilter = [classFilter substringToIndex: [classFilter length] - 4];
    }
	NSArray *allClasses = [MPWClassMirror allUsefulClasses];
	NSEnumerator *classEnumerator = [allClasses objectEnumerator];
    while ((currentClass = [classEnumerator nextObject]) != nil) {
		NSString *className =[currentClass name];
		if  ( [className isEqual:@"TMockRecorder"] ||
			 [className isEqual:@"NSScriptCommandDescriptionMoreIVars"] ||
			 [className isEqual:@"OSFilePath"]) {
			continue;
		}

        if ([[currentClass theClass] respondsToSelector: @selector(isSubclassOfClass:)] &&
				[[currentClass theClass] isSubclassOfClass:[TTestCase class]] && 
                [currentClass theClass] != [TTestCase class]) {
            TTestCase *test = [[[currentClass theClass] alloc] init];
#if 0
			NSLog(@"will test class: %@",className);
#endif
			@try {

            if (classFilter == nil || [className matches: classFilter]) {
                if ([className matches: @"TestCase$"]) {
                    // skip TestCases
                } else {
                    if (YES) {
                        result += [test run];
                    } else {
#if !TARGET_OS_MAC
                        [OSUserIO eprintLn: @"Errors during initialization:"];
                        [OSUserIO eprintLn: [ERRORHANDLER
                                errorStackMessagesStringWithIndent: @"    "]];
                        [ERRORHANDLER reset];
#endif
                    }
                }
            }
			} @catch ( id e ) {
				NSLog(@"=== uncaught exception in %@",className);
			}
            [test release];
        }
    }
    return result;
}

#if !MPWTEST

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    char **environment = [OSEnvironment getEnvironment];
    int result = 1;

#if !TARGET_OS_MAC
    __objc_msg_forward = objc_msg_forward;
    [NSProcessInfo initializeWithArguments: argv count: argc
            environment: environment];

    if ([[OSEnvironment getEnv: @"EXTENDED_DEBUG"] containsData]) {
        OSDebugPrinter *printer = [OSDebugPrinter globalDebugPrinter];
        PROFILE_CHANNEL_TEST = [printer registerProfileChannel: PROFILE_CHANNEL_NAME_TEST];
        [printer setProfileChannelsActive: [NSArray arrayWithObject: PROFILE_CHANNEL_NAME_TEST]];
    }
#endif

    NSSetUncaughtExceptionHandler(uncaughtNSExceptionHandler);
#if !TARGET_OS_MAC
    tUnitInitializeTest();
    ERRORHANDLER = [HSErrorHandler errorHandler];
#endif
    @try {
        result = objcmain(argc, argv);
		printf("\n\n  === result: %d failures of %d total tests, %g%% correct\n",result,runs,(100.0*(runs-result))/runs);
    } @catch (id e) {
#if !TARGET_OS_MAC
        [OSUserIO eprintLn: [NSString stringWithRestrictedFormat: @"Uncaught exception: %s",
                STRINGVALUE(e)]];
#else
		NSLog(@"uncaught exception: %@",STRINGVALUE(e));
#endif
    } 
#if !TARGET_OS_MAC
    if (!ERRORSTATE_OK) {
        [OSUserIO eprintLn: [ERRORHANDLER errorStackMessagesStringWithIndent: nil]];
    }
#endif
    [pool release];
    return result;
}

#endif
