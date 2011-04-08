/* NSBundleClassEnumeration.m created by marcel on Sat 16-Dec-2000 */

//	Code contributed by Dirk Theisen [ d.theisen@objectpark.de (Dirk Theisen) ]

#import "NSBundleClassEnumeration.h"
//#import <objc/objc-runtime.h>

@implementation NSBundle(classEnumeration)
//#ifdef Darwin
#define NO_NX_CLASSES 1
//#endif

#if 0

- (NSArray*) classNames {
	
	void *enumstate=NULL;
	Class *nextClass;
    NSMutableArray *classArray = [NSMutableArray array];
	
	while ((nextClass = objc_next_class(&enumstate))) {
		[classArray addObject:[nextClass name]];
	}
    return classArray;
}


#else


#if NO_NX_CLASSES

-(NSArray*)invalidClassNames
{
	static id invalidClassNames=nil;
	if (!invalidClassNames) {
		invalidClassNames=[[NSArray alloc] initWithObjects:
						@"NSFramework_",
						@"NSATSGlyphGen",
#if WINDOWS						   
						   @"Object",
						   @"NSProxy",
						   @"MPWSoftPointerProxy",
						   @"MPWTrampoline",
						   @"MPWDirectForwarding",
						   @"Protocol",
						   @"MPWEnum",
						   @"MPWFutu",
						   @"SoftPointer",
						   @"_SoftPointer",
						   @"MPWFastInfoSet",
						   @"MPWXmlWrapper",
						   @"MPWXmlArchiver",
						   @"MPWXmlUnarchiver",
#endif						   
						   nil];
		
	}
	return invalidClassNames;
}


-(BOOL)isValidClass:(Class)theClass andClassName:(NSString*)cName
{
//	NSLog(@"checking validity of %@",cName);
#if WINDOWS	
	Class superclass= class_getSuperclass( theClass );
	if ( superclass == nil ) {
		return NO;
	}
	if ( superclass == [NSProxy class] ) {
		return NO;
	}
#else	
	if  (!([NSBundle bundleForClass: theClass]==self)) {
		return NO;
	}
#endif
	for ( id name in [self invalidClassNames] ) {
		if ( [cName hasPrefix:name] ) {
			return NO;
		}
	}
	return YES;
}


- (NSArray*) classNames {

    int classCount = objc_getClassList(NULL, 0);
    Class classes[classCount + 10];
    id classArray;
    int i;
    objc_getClassList(classes, classCount);
	printf("classCount = %d\n",classCount);
    classArray = [NSMutableArray array];
    for (i=0;i<classCount;i++ ) {
//		printf("class[%d]%=%s\n",i,[NSStringFromClass(classes[i]) cString]);
		const char *cName=object_getClassName( classes[i] );
		NSString *str=[NSString stringWithCString:cName];
		if ( [self isValidClass:classes[i] andClassName:str] ) {
			[classArray addObject: str];
		}
    }
	NSLog(@"got classNames array");
    return classArray;
}

#else

- (NSArray*) classNames {
    NXHashTable *class_hash = objc_getClasses();
    NXHashState state = NXInitHashState(class_hash);
    Class class;
    NSMutableArray *classArray=[NSMutableArray array];

    while (NXNextHashState(class_hash, &state, (void*)&class)) {
        if ([NSBundle bundleForClass: class]==self) {
            NSString* str = NSStringFromClass(class);
            if (![str hasPrefix:@"NSFramework_"])
                [classArray addObject: str];
        }
    }
    return classArray;
}


#endif

#endif

@end

