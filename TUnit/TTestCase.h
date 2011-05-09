
#import <Foundation/Foundation.h>

//#include <sys/resource.h>


@interface TTestCase:NSObject
{
    NSString *_hint;
}


- (NSString *)_description: obj;
- objDescription: obj;
- (void)_assertList: (NSArray *)got containsElementsFrom: (NSArray *)expected
   failOnUnexpected: (BOOL)failOnUnexpected file: (const char *)file line: (int)line;
- (void)_assert: obj1 equals: obj2 file: (const char *)file line: (int)line;
- (void)_assertInt: (int)int1 equalsInt: (int)int2 file: (const char *)file line: (int)line;
- (void)_assert: (NSString *)expression isTrue: (BOOL)isTrue;

- (void)clearHint;

@end

@interface NSException(exceptionAt)

+exceptionAt: (const char*)file : (int)line withMessage:(NSString*)msg;
+(void)raiseAt: (const char*)file : (int)line withMessage:(NSString*)msg;
@end


typedef void(TUnitCallBack)();
extern TUnitCallBack *tUnitBeforeSetUp;

#define _ASSERT(sel) [self sel file: __FILE__ line: __LINE__]; [self clearHint];

#define ASSERTEQUALSINT(int1, int2) _ASSERT(_assertInt: int1 equalsInt: int2)

#define ASSERTEQUALSUINT(int1, int2) _ASSERT(_assertUInt: int1 equalsUInt: int2)

#define ASSERTISGREATERTHANINT(int1, int2) _ASSERT(_assertInt: int2 isGreaterThan: int1)

#define ASSERTISLESSTHANINT(int1, int2) _ASSERT(_assertInt: int2 isLessThan: int1)

#define ASSERTEQUALS(obj1, obj2) _ASSERT(_assert: obj1 equals: obj2)

#define ASSERTIDENTICAL(obj1, obj2) _ASSERT(_assert: obj1 isIdenticalTo: obj2)

#define ASSERT(x) _ASSERT(_assert: @#x isTrue: x shouldBeFalse: NO)

#define ASSERTFALSE(x) _ASSERT(_assert: @#x isTrue: x shouldBeFalse: YES)

#define ASSERTNIL(x) ASSERT((x) == nil);

#define ASSERTNOTNIL(x) ASSERT((x) != nil);

#define ASSERTKINDOF(expectedClass, obj) _ASSERT(_assert: obj isKindOf: expectedClass)

#define ASSERTLISTCONTENTSEQUAL(expected, got)\
        _ASSERT(_assertList: got containsEqualElementsAs: expected)

#define ASSERTLISTCONTAINS(expected, got)\
        _ASSERT(_assertList: got containsElementsFrom: expected)

#define ASSERTSUBSTRING(expected, got) _ASSERT(_assert: got hasSubstring: expected)

#define ASSERTMATCHES(expected, result) _ASSERT(_assert: result matches: expected)

#define ASSERTISFASTERTHAN(fast, slow, howMany) {\
    long long __fastTime__ = [TTime currentTimeMillis];\
\
    for (int __i__ = 0; __i__ < howMany; ++__i__) {\
        fast;\
    }\
    __fastTime__ = [TTime currentTimeMillis] - __fastTime__;\
\
    long long __slowTime__ = [TTime currentTimeMillis];\
\
    for (int __i__ = 0; __i__ < howMany; ++__i__) {\
        slow;\
    }\
    __slowTime__ = [TTime currentTimeMillis] - __slowTime__;\
    ASSERTISLESSTHANINT(__slowTime__, __fastTime__);\
}

#define ASSERTISFAST(expectedMaxMilliSeconds, method, howMany) {\
    long long __expected__ = (long long)expectedMaxMilliSeconds;\
    struct rusage __usage__;\
    long long __before__;\
    long long __after__;\
    getrusage(RUSAGE_SELF, &__usage__);\
    __before__ = (long long)__usage__.ru_utime.tv_sec * 1000000 +\
            (long long)__usage__.ru_utime.tv_usec;\
\
    for (int __i__ = 0; __i__ < howMany; ++__i__) {\
        method;\
    }\
    getrusage(RUSAGE_SELF, &__usage__);\
    __after__ = (long long)__usage__.ru_utime.tv_sec * 1000000 +\
            (long long)__usage__.ru_utime.tv_usec;\
\
    ASSERTISLESSTHANINT(__expected__, (__after__ - __before__) / 1000);\
}

#define _FAIL(eClass, eId, expectedE, x, code...) {\
    eClass e = nil;\
    id unexpectedException = nil;\
\
    @try {\
        x;\
    } @catch(eClass caught) {\
        e = [caught autorelease];\
    } @catch(id u) {\
        unexpectedException = u;\
    }\
    if (e == nil && unexpectedException == nil) {\
        @throw [TTestException exceptionAt: __FILE__ : __LINE__ \
                withMessage: @#x @" did not fail"];\
    } else if (expectedE != nil && ![expectedE isEqualTo: e]) {\
        @throw [TTestException exceptionAt: __FILE__ : __LINE__ \
                withFormat: @#x @" failed with unexpected exception %@ instead of %@",\
                e, expectedE];\
    } else if (unexpectedException != nil) {\
        @throw [TTestException exceptionAt: __FILE__ : __LINE__ \
                withFormat: @#x @" failed with unexpected exception %@ instead of %@",\
                unexpectedException, @#eClass];\
    } else if (eId != 0 && eId != [(id)e errorId]) {\
        @throw [TTestException exceptionAt: __FILE__ : __LINE__ \
                withFormat: @#x@" failed with unexpected exception ID %d instead of %d",\
                [(id)e errorId], eId];\
    }\
    code;\
}


//#define FAIL(x...) _FAIL(id, 0, nil, x)
#define FIXME_FAIL(x...) _FAIL(id, 0, nil, x)

#define FAIL_WITH_CLASS(exceptionClass, x...)\
        _FAIL(exceptionClass *, 0, nil, x)

#define FAIL_WITH_CLASS_AND_ID(exceptionClass, exceptionId, x...)\
        _FAIL(exceptionClass *, exceptionId, nil, x)

#define FAIL_WITH_EQUAL(expectedException, x...)\
        _FAIL(id, 0, expectedException, x)


#define FAIL(x) {\
    BOOL __failed__ = NO;\
\
    @try {\
        x;\
    } @catch(NSException *e) {\
        __failed__ = YES;\
    }\
    if (!__failed__) {\
        [NSException raiseAt: __FILE__ : __LINE__ \
                withMessage: @"Assertion " @#x @" did not fail"];\
    }\
}
