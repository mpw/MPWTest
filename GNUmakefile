# $Id: GNUmakefile,v 1.1 2002/03/12 21:42:57 marcel Exp $

include $(GNUSTEP_MAKEFILES)/common.make

LIBRARY_NAME = MPWTest



MPWTest_OBJC_FILES = \
	MPSTestSuite.m MPWLoggingTester.m MPWTestCase.m \
	MPWTestResults.m NSBundleClassEnumeration.m NSObjectTestingSupport.m \


MPWTest_LIBRARIES_DEPEND_UPON += -lFoundation

MPWTest_INCLUDE_DIRS += -I.headers

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/library.make
-include GNUmakefile.postamble

