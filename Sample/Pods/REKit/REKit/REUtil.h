/*
 REUtil.h
 
 Copyright ©2012 Kazki Miura. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


// Notifications
extern NSString* const REObjectWillChangeClassNotification;
extern NSString* const REObjectDidChangeClassNotification;

// Keys for userInfo of notifications above
extern NSString* const REObjectOldClassNameKey;
extern NSString* const REObjectNewClassNameKey;


//--------------------------------------------------------------//
#pragma mark   Block
//--------------------------------------------------------------//

// BlockDescriptor
struct BlockDescriptor
{
	unsigned long reserved;
	unsigned long size;
	void *rest[1];
};

// Block
struct Block
{
	void *isa;
	int flags;
	int reserved;
	void *invoke;
	struct BlockDescriptor *descriptor;
};

// Flags of Block
enum {
	BLOCK_HAS_COPY_DISPOSE =	(1 << 25),
	BLOCK_HAS_CTOR =			(1 << 26), // helpers have C++ code
	BLOCK_IS_GLOBAL =			(1 << 28),
	BLOCK_HAS_STRET =			(1 << 29), // IFF BLOCK_HAS_SIGNATURE
	BLOCK_HAS_SIGNATURE =		(1 << 30), 
};

extern const char* REBlockGetObjCTypes(id block);
extern void* REBlockGetImplementation(id block);


//--------------------------------------------------------------//
#pragma mark - NSInvocation
//--------------------------------------------------------------//

@interface NSInvocation (REUtil)
- (void)invokeUsingIMP:(IMP)imp;
@end


//--------------------------------------------------------------//
#pragma mark - NSMethodSignature
//--------------------------------------------------------------//

@interface NSMethodSignature (REUtil)
- (const char*)objCTypes;
- (NSString*)description;
@end


//--------------------------------------------------------------//
#pragma mark - NSObject
//--------------------------------------------------------------//

@interface NSObject (REUtil)

// Class Exchange
- (void)willChangeClass:(Class)toClass;
- (void)didChangeClass:(Class)fromClass;

// Association
- (void)associateValue:(id)value forKey:(void*)key policy:(objc_AssociationPolicy)policy;
- (id)associatedValueForKey:(void*)key;

@end


//--------------------------------------------------------------//
#pragma mark - NSObject (REKitPrivate)
//--------------------------------------------------------------//

@interface NSObject (REKitPrivate)

// Method Exchange
+ (void)exchangeClassMethodWithOriginalSelector:(SEL)originalSelector newSelector:(SEL)newSelector;
+ (void)exchangeInstanceMethodWithOriginalSelector:(SEL)originalSelector newSelector:(SEL)newSelector;
+ (void)exchangeClassMethodsWithAdditiveSelectorPrefix:(NSString*)prefix selectors:(SEL)originalSelector, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)exchangeInstanceMethodsWithAdditiveSelectorPrefix:(NSString*)prefix selectors:(SEL)originalSelector, ... NS_REQUIRES_NIL_TERMINATION;

@end


//--------------------------------------------------------------//
#pragma mark - NSString
//--------------------------------------------------------------//

#define RE_LINE [NSString stringWithFormat:@"%s-l.%i", __PRETTY_FUNCTION__, __LINE__]
extern NSString* REUUIDString();
