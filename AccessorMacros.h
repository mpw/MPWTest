/*
	Copyright (c) 2001-2011 by Marcel Weiher. All rights reserved.*/

#ifndef ACCESSOR_MACROS
#define ACCESSOR_MACROS



//---	This file expands the accessor macros

#define newBool(x)	(x ? [[NSNumber numberWithBool:x] retain] : nil)
#define newInt(x)	[[NSNumber numberWithInt:x]  retain]
#define newChar(x)	[[NSNumber numberWithChar:x] retain]
#define makeBool(x)	(x ? [NSNumber numberWithBool:x] : nil)
#define makeInt(x)	[NSNumber numberWithInt:x]
#define makeChar(x)	[NSNumber numberWithChar:x]
#define toInt(x)	[x intValue]
#define toBool(x)	[x boolValue]
//#define toString(x)	[x stringValue]

#define ASSIGN_ID(var,value)\
    {\
        id tempValue=(value);\
	if ( tempValue!=var) {  \
        if ( tempValue!=(id)self ) \
            [tempValue retain]; \
		if ( var && var!=(id)self) \
			[var release]; \
		var = tempValue; \
	} \
    }\


#define	setAccessor( type, var,setVar ) \
-(void)setVar:(type)newVar { \
    ASSIGN_ID(var,newVar)\
} \

#define readAccessor( type, var )\
-(type)var						{	return var;			}

#define relayReadAccessor( var, delegate ) \
-var\
{\
    if ( var ) {\
        return var;\
    } else {\
        return [delegate var];\
    }\
}\

#define objectAccessor( objectType, var, setVar ) \
readAccessor( objectType*, var )\
setAccessor( objectType*, var,setVar )

#define idAccessor( var, setVar )\
readAccessor( id, var )\
setAccessor( id, var,setVar )


#define relayAccessor( var, setVar, delegate )\
relayReadAccessor( var , delegate )\
setAccessor( id, var, setVar )

#define	idAccessor_h( var,setVar ) -(void)setVar:newVar; \
-var;

#define scalarAccessor( scalarType, var, setVar ) \
-(void)setVar:(scalarType)newVar	{	var=newVar;	} \
-(scalarType)var					{	return var;	} 
#define scalarAccessor_h( scalarType, var, setVar ) \
-(void)setVar:(scalarType)newVar; \
-(scalarType)var;

#define objectAccessor_h( objectType, var, setVar )   scalarAccessor_h( objectType*, var, setVar )

#define intAccessor( var, setVar )	scalarAccessor( int, var, setVar )
#define intAccessor_h( var, setVar )	scalarAccessor_h( int, var, setVar )
#define floatAccessor(var,setVar )  scalarAccessor( float, var, setVar )
#define floatAccessor_h(var,setVar )  scalarAccessor_h( float, var, setVar )
#define boolAccessor(var,setVar )  scalarAccessor( BOOL, var, setVar )
#define boolAccessor_h(var,setVar )  scalarAccessor_h( BOOL, var, setVar )

#define lazyAccessor( type, var ,setVar, computeVar )   \
	readAccessorName( type,var, _##var ) \
	setAccessor( type, var, setVar ) \
-(type)var { \
	if ( ![self _##var] )  { \
		[self setVar:[self computeVar]]; \
	}  \
	return [self _##var]; \
} \


//--- compatibility:

//#define	accessor	idAccessor
//#define accessor_h	idAccessor_h


//---- RETAIN/RELEASE Macros for GNUStep compatibility

#ifndef RETAIN
#define RETAIN(x)  ([(x) retain])
#endif

#ifndef RELEASE
#define RELEASE(x)  ([(x) release])
#endif

#ifndef AUTORELEASE
#define AUTORELEASE(x)  ([(x) autorelease])
#endif

#ifndef DESTROY
#define DESTROY(x)  ([(x) release])
#endif

#ifndef ASSIGN
#define ASSIGN(var,value) ASSIGN_ID(var,value)
#endif	

#ifndef ASSIGNCOPY
#define ASSIGNCOPY(var,value) ASSIGN(var,[(value) copy])
#endif

#endif
