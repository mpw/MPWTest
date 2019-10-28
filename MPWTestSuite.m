/* MPWTestSuite.m Copyright (c) 1998-1999 by Marcel Weiher, All Rights Reserved, created  on Thu 27-Aug-1998 */

//  with changes contributed by Dirk Theisen

#import "MPWTestSuite.h"
#import "MPWTestCase.h"
#import "MPWTestResults.h"
#import "NSObjectTestingSupport.h"
#import "NSBundleClassEnumeration.h"
#import "MPWClassMirror.h"

@implementation MPWTestSuite


-initWithName:aName testCases:cases 
{
    self = [super init];
    name=[aName retain];
    testCases=[cases retain];
    return self;
}

+testSuiteWithName:aName testCases:cases 
{
    return [[[self alloc] initWithName:aName testCases:cases] autorelease];
}

+testSuiteWithClass:(Class)testClass selectorStrings:selectorArray
{
    int i;
    id theTestCases = [[NSMutableArray alloc] init];
    for (i=0;i<[selectorArray count];i++) {
//		NSLog(@"class: %@ testCase[%d]: %@",testClass,i,[selectorArray objectAtIndex:i]);
        id testCase = [[[testClass testClass] alloc] initWithClass:testClass testName:[selectorArray objectAtIndex:i]];
		if ( testCase ) {
            [theTestCases addObject:testCase];
            [testCase release];
		} else {
			NSLog(@"didn't get test-case for class: %@ testCase[%d]: %@",NSStringFromClass( testClass ),i,[selectorArray objectAtIndex:i]);
		}
    }
    return [self testSuiteWithName:NSStringFromClass(testClass) testCases:theTestCases];
}

+testSuiteWithClass:(Class)testClass testType:(NSString*)testType 
{
	SEL testTypeSelector = NSSelectorFromString( testType );
    if ( [testClass respondsToSelector:testTypeSelector] ) {
        return [self testSuiteWithClass:testClass selectorStrings:[testClass performSelector:testTypeSelector]];
    } else {
        return nil;
    }

}

+testSuiteWithName:aName classMirrors:(NSArray*)classMirrors testTypes:testTypeNames
{
    id subTests=[NSMutableArray array];
    NSEnumerator* classEnumerator=[classMirrors objectEnumerator];
    id nextClass;
    while ( nextClass=[classEnumerator nextObject]) {
		for ( NSString* testType in testTypeNames ) {
			id testSuite = [self testSuiteWithClass:[nextClass theClass] testType:testType];
			if ( testSuite ) {
				[subTests addObject:testSuite];
			} else {
				NSLog(@"not testing class: %@",nextClass);
			}
		}
    }
    return [self testSuiteWithName:aName testCases:subTests];
}

-(void)dealloc
{
    [testCases release];
    [super dealloc];
}

int hadSignal=0;
int havePrinted=0;
-(void)runTest:testResults
{
	long i,max;
    [testResults beginTest:self];
    NS_DURING
	for (i=0,max=[testCases count];i<max;i++ ) {
		[[testCases objectAtIndex:i] runTest:testResults];
		if ( hadSignal ) {
			if ( !havePrinted  ) {
				fprintf(stderr,"error:  had signal, aborting tests\n");
				havePrinted=YES;
			}
			break;
		}
	}
    NS_HANDLER
		NSLog(@"exception in suite run handler: %@",localException);
    NS_ENDHANDLER
    [testResults endTest:self];
}

-description
{
    return name;
}

+testSuiteForBundle:(NSBundle*)aBundle name:aName testTypes:testTypeNames
{
    id suite;
    NSLog(@"will load bundle %@",aName);
//    [self initializeLoadedClassesIfNecessary];
    if ( [aBundle load] ) {
        //    newClasses=getClasses(initial);
//			NSLog(@"bundle = %@",aBundle);
//		NSLog(@"did load bundle with class names: %@",[aBundle classNames]);
#if 0 // WINDOWS
		suite = [MPWTestSuite testSuiteWithName:aName  classNames:
				 [NSArray arrayWithObjects:
				  @"MPWIntArray",
				  @"MPWObject",
				  @"MPWPoint",
				  nil]];
#else
        NSLog(@"will get class mirrors");
        NSArray *classMirrors = [aBundle classes];
        NSLog(@"got class mirrors");
        classMirrors = [classMirrors sortedArrayUsingSelector:@selector(compare:)];
        NSLog(@"did sort class mirrors");
		suite = [MPWTestSuite testSuiteWithName:aName  classMirrors:classMirrors testTypes:testTypeNames];
//		NSLog(@"got suite");
//				[initial addObjectsFromArray:newClasses];
#endif
    } else {
        [NSException raise:@"nobundle" format:@"Bundle %@/%@ couldn't be loaded",aName,aBundle];
    }
    return suite;
}

+(BOOL)isCompleteFrameworkName:(NSString*)frameworkName
{
	NSString* pathExtension=[frameworkName pathExtension];
	return ( [pathExtension isEqual:@"framework"] ||
			 [pathExtension isEqual:@"bundle"] ||
			[frameworkName rangeOfString:@"/"].location != NSNotFound );
}

+frameworkPathForFrameworkName:(NSString*)frameworkName
{
	NSArray *prefixes=[NSArray arrayWithObjects:
		@"~/programming/Build/Frameworks",
		@"~/Library/Frameworks",
		@"/Library/Frameworks",
		@"/Local/Library/Frameworks",
		nil];
	int i;
	if ( [self isCompleteFrameworkName:frameworkName] && [[NSFileManager defaultManager] fileExistsAtPath:frameworkName] ) {
		return frameworkName;
	}
	if ( [[NSFileManager defaultManager] fileExistsAtPath:[frameworkName stringByAppendingPathComponent:@"framework"]] ) {
		return frameworkName;
	}
	for ( i=0;i<[prefixes count];i++) {
		id path = [[NSString stringWithFormat:@"%@/%@.framework",[prefixes objectAtIndex:i],frameworkName] stringByStandardizingPath];
		if ( [[NSFileManager defaultManager] fileExistsAtPath:path] ) {
			return path;
		}
	}
	return nil;
}

+testSuiteForLocalFramework:(NSString*)frameworkName testTypes:testTypeNames
{
	NSString *path=[self frameworkPathForFrameworkName:frameworkName];
//	NSLog(@"path: %@",path);
	id bundle = [NSBundle bundleWithPath:path];
	id suite=nil;
	if ( bundle ) {
		suite = [self testSuiteForBundle:bundle name:frameworkName testTypes:testTypeNames];
	}
	return suite;
}

-(int)numberOfTests
{
    int number=0;
    id subTestEnumerator=[testCases objectEnumerator];
    id nextSubtest;
    while (nextSubtest=[subTestEnumerator nextObject]){
        number+=[nextSubtest numberOfTests];
    }
    return number;
}

-(void)listInto:(NSMutableArray*)result
{
    for (MPWTestSuite *s in testCases) {
        [result addObject:[s name]];
    }
}

-(NSString*)name
{
    return name; 
}

@end
