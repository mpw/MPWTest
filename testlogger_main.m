
#import "MPWTestSuite.h"
#import "MPWLoggingTester.h"
#import <Foundation/NSDebug.h>

extern int hadSignal;
static int counter=0;

void handler(int theSignal)
{
    signal( theSignal, handler  );
	hadSignal=1;
	counter++;
	if ( counter > 3 ) {
		exit(1);
	}
    [NSException raise:@"signal" format:@"toplevel:1: signal %d",theSignal];
}

int main (int argc, const char *argv[])
{
   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int exitCode=0;
    id test,results;
    id testsuites = [NSMutableArray array];
    int i,verbose=0;
    for (i=0;i<12;i++) {
        if ( i != 3 && i != 5 && i!=2   ) {
 //           signal( i, handler  );
        }
    }
	NSMutableArray *testTypeNames=[NSMutableArray array];
	NSMutableArray *testSuiteNames=[NSMutableArray array];
//	NSLog(@"did signals, now doing %d args %d classes",argc, objc_getClassList(NULL, 0));
    for (i=1;i<argc;i++) {
		NSLog(@"arg[%d]=%s",i,argv[i]);
        if ( !strcmp( argv[i], "-v" )) {
			verbose=1;
        } else if ( !strcmp( argv[i], "-a" )) {
			NSLog(@"loading appkit: %d",[[NSBundle bundleWithPath:@"/System/Library/Frameworks/AppKit.framework"] load]);
            [NSClassFromString(@"NSApplication") sharedApplication];
        } else if ( !strcmp( argv[i], "-tt" )) {
			if ( argv[i+1] ) {
				[testTypeNames addObject:[NSString stringWithUTF8String:argv[i+1]]];
				i++;
			}
        } else if ( !strcmp( argv[i], "-tn" )) {
			if ( argv[i+1] ) {
				
			}
        } else if ( !strcmp( argv[i], "-d" )) {
            if ( argv[i+1] && isdigit( argv[i+1][0] )) {
                NSDebugEnabled=atoi(argv[i+1]);
                i++;
            } else {
                NSDebugEnabled=YES;
            }
        } else {
			id suitename = [NSString stringWithUTF8String:argv[i]];
			[testSuiteNames addObject:suitename];
       }
    }
	if ( [testTypeNames count] == 0 ) {
		[testTypeNames addObject:@"testSelectors"];
	}
	for ( id suitename in testSuiteNames ) {
		id suite = [MPWTestSuite testSuiteForLocalFramework:suitename testTypes:testTypeNames];
		//			NSLog(@"suite name= %@",suitename);
		//			NSLog(@"suite = %@",suite);
		if ( suite ) {
			[testsuites addObject:suite];
		} else {
			NSLog(@"couldn't load framework: %@",suitename);
		}
		
	}
	
    test=[MPWTestSuite testSuiteWithName:@"all" testCases:testsuites];
	NSLog(@"test: %@",test);
    results=[[MPWLoggingTester alloc] init];
    [results setVerbose:verbose];
    fprintf(stderr,"Will run %d tests\n",[test numberOfTests]);
	[results addToTotalTests:[test numberOfTests]];
    [test runTest:results];
    if ( !verbose ){
        [results printResults];
    }
    if ( [results failureCount] >0 ) {
        exitCode=1;
    }
   [pool release];
   exit(exitCode);       // insure the process exit status is 0
   return exitCode;      // ...and make main fit the ANSI spec.
}
