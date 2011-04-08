/* MPWLoggingTester.h Copyright (c) 1998-1999 by Marcel Weiher, All Rights Reserved, created  on Thu 27-Aug-1998 */

#import "MPWTestResults.h"

@interface MPWLoggingTester : MPWTestResults
{
    BOOL	verbose;
}

-(void)setVerbose:(BOOL)n;
-(BOOL)verbose;
@end
