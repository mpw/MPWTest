//
//  MPWTestAssertionHandler.h
//  MPWTest
//
//  Created by Marcel Weiher on 26/10/2004.
//  Copyright 2004 Marcel Weiher. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MPWTestAssertionHandler : NSAssertionHandler {
	id	tester;
}

-initWithTester:aTester;
+assertionHandlerWithTester:aTester;


@end
