//
//  TMock.h
//  MPWTest
//
//  Created by Marcel Weiher on 4/10/11.
//  Copyright 2011 Marcel Weiher. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TUNIT_UNLIMITEDCALLCOUNT   -1

@interface TMockRecorder : NSProxy {
@public
	id controller;
}

-initWithController:anObject;


@end



@interface NSObject(mocking)

-mock;
-stub;
-shouldReceive;
-andReturn:anObject;
-andReturnInt:(int)anInt;
-ordered;
-skipParameterCheck:(int)parameterToIgnore;

@end
