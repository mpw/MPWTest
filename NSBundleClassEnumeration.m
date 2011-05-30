/* NSBundleClassEnumeration.m created by marcel on Sat 16-Dec-2000 */


#import "NSBundleClassEnumeration.h"
#import "MPWClassMirror.h"


@implementation NSBundle(classEnumeration)


-(NSArray*)classes
{
	NSMutableArray *bundleClasses=[NSMutableArray array];
	for ( MPWClassMirror *mirror in [MPWClassMirror allUsefulClasses] ) {
		if ( [mirror isInBundle:self] ) {
			[bundleClasses addObject:mirror];
		}
	}
	return bundleClasses;
}

@end

