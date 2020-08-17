
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

void usage( const char *name )
{
    char *only=strrchr( name ,'/');
    if ( only ) {
        name=only+1;
    }
    printf("usage: %s [-v][-a][-tt][-tn][-d [debugflag]] <frameworks>\n\n",name);

    printf("   -v  verbose, also show successful results\n");
    printf("   -vv very verbose, log test names as they are executing\n");
    printf("   -tt test type, message to ask for tests\n");
    printf("       default is testSelectors\n");
    printf("   -a  load AppKit\n");
    printf("   -l  list tests as plist\n");
    printf("   -d  NSDebugEnabled=debugflag or YES if not given\n\n");
    printf("   <frameworks> one or more framework names, without the .framework extension\n");
    printf("       will look in /Library/Frameworks or in the current directory\n");
}

int runTests( NSArray *testSuiteNames , NSMutableArray *testTypeNames,  BOOL verbose ,BOOL veryVerbose, BOOL list ) {
    NSMutableArray *testsuites=[NSMutableArray array];
    MPWTestSuite* test;
    MPWLoggingTester* results;
    int exitCode=0;
    
	if ( [testTypeNames count] == 0 ) {
		[testTypeNames addObject:@"testSelectors"];
	}
	for ( id suitename in testSuiteNames ) {
		MPWTestSuite* suite = [MPWTestSuite testSuiteForLocalFramework:suitename testTypes:testTypeNames];
		//			NSLog(@"suite name= %@",suitename);
		//			NSLog(@"suite = %@",suite);
        if ( list ) {
            NSMutableArray *theList=[NSMutableArray array];
            [suite listInto:theList];
            NSLog(@"%@",theList);
        }
		if ( suite ) {
			[testsuites addObject:suite];
		} else {
			NSLog(@"couldn't load framework: %@",suitename);
		}
		
	}
	
    test=[MPWTestSuite testSuiteWithName:@"all" testCases:testsuites];
    //	NSLog(@"test: %@",test);
    results=[[MPWLoggingTester alloc] init];
    [results setVerbose:veryVerbose];
    fprintf(stderr,"Will run %d tests\n",[test numberOfTests]);
	[results addToTotalTests:[test numberOfTests]];
    [test runTest:results];
    if ( !veryVerbose ){
        if ( verbose) {
            [results printAllResults];
        } else {
            [results printResults];
        }
    }
    if ( [results failureCount] >0 ) {
        exitCode=1;
    }
    return exitCode;
}


int main (int argc, const char *argv[])
{
    int exitCode=0;
   [NSAutoreleasePool new];
//    id testsuites = [NSMutableArray array];
    int i,verbose=0,veryVerbose=0;
    BOOL list=NO;
    for (i=0;i<12;i++) {
        if ( i != 3 && i != 5 && i!=2   ) {
 //           signal( i, handler  );
        }
    }
	NSMutableArray *testTypeNames=[NSMutableArray array];
	NSMutableArray *testSuiteNames=[NSMutableArray array];
//	NSLog(@"did signals, now doing %d args %d classes",argc, objc_getClassList(NULL, 0));
    for (i=1;i<argc;i++) {
//		NSLog(@"arg[%d]=%s",i,argv[i]);
        if ( !strcmp( argv[i], "-v" )) {
            verbose=1;
        } else if ( !strcmp( argv[i], "-vv" )) {
            veryVerbose=1;
        } else if ( !strcmp( argv[i], "-l" )) {
            list=1;
        } else if ( !strcmp( argv[i], "-a" )) {
            BOOL didLoadAppKit;
            didLoadAppKit=[[NSBundle bundleWithPath:@"/System/Library/Frameworks/AppKit.framework"] load];
//            NSLog(@"loaded appkit: %d",didLoadAppKit);
            [NSClassFromString(@"NSApplication") performSelector:NSSelectorFromString(@"sharedApplication")];
        } else if ( !strcmp( argv[i], "-tt" )) {
			if ( argv[i+1] ) {
				[testTypeNames addObject:[NSString stringWithUTF8String:argv[i+1]]];
				i++;
			}
        } else if ( !strcmp( argv[i], "-tn" )) {
			if ( argv[i+1] ) {
                ;
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
    if ( [testSuiteNames count] >0  ) {
        exitCode = runTests( testSuiteNames, testTypeNames, verbose, veryVerbose, list);
    } else {
        usage(argv[0]);
        exitCode=1;
    }
    
   exit(exitCode);       // insure the process exit status is 0
   return exitCode;      // ...and make main fit the ANSI spec.
}
