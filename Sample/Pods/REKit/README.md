REKit
=====
REKit [rikít] is a collection of extensions of `NSObject`.  Currently it provides 2 features:

1. [REResponder](#REResponder): provides ability to add/override methods at instance level
2. [REObserver](#REObserver): provides Blocks compatible method for KVO (Key-Value Coding) + α

Blocks and GCD (Grand Central Dispatch), caused a great change in the iOS, OS X world. It provided ability to write code which is executed in the future. Programmers' world became more flexible.

REKit (especially REResponder) brings out Blocks latent ability in a different way with GCD. REResponder provides ability to reconstruct instances. To be concrete, it provides ability to add/override methods at instance level. REKit can also cause great change.

REKit was used in iPhone app : [SpliTron](http://www.webtron.jp/splitron/ "SpliTron"). REKit improved the development efficiency and maintainability. Thereby, SpliTron overcame some specification changes. REKit made the project team to focus on user experience.

REKit hopes to contribute to the iOS, OS X world.


## <a id="REResponder"></a>REResponder
REResponder provides ability to add/override methods at instance level. Details of features, behaviors, and [efficient examples](#Examples) are below.


### <a id="AddingMethodsDynamically"></a>Adding methods dynamically
You can add methods to arbitrary instance dynamically using Block. To do so, you use `-respondsToSelector:withKey:usingBlock:` method. For example, `NSObject` doesn't have `-sayHello` method, but you can add it as below:

```objective-c
id obj;
obj = [[NSObject alloc] init];
[obj respondsToSelector:@selector(sayHello) withKey:nil usingBlock:^(id receiver) {
	NSLog(@"Hello World!");
}];
[obj performSelector:@selector(sayHello)]; // Hello World!
```

It is applied to `obj` only, and it doesn't affect to the other instances.


### <a id="OverridingMethodsDyamically"></a>Overriding methods dynamically
You can override methods of arbitrary instance dynamically using Block. Same as "[Adding methods dynamically](#AddingMethodsDynamically)", you use `-respondsToSelector:withKey:usingBlock:` method. For example, if you have MyObject class logs "No!" in `-sayHello` method, you can override it to log "Hello World!":

```objective-c
MyObject *obj;
obj = [[MyObject alloc] init];
// [obj sayHello]; // No!	
[obj respondsToSelector:@selector(sayHello) withKey:nil usingBlock:^(id receiver) {
	NSLog(@"Hello World!");
}];
[obj sayHello]; // Hello World!
```

It is applied to `obj` only, and it doesn't affect to the other instances.


### <a id="ReceiverArgument"></a>The receiver argument of Block
As you can see above, `receiver` argument is necessary for Block. The `receier` argument is receiver of `-respondsToSelector:withKey:usingBlock:` method. It doesn't cause retain cycle even if you use `receiver` in the Block, so go ahead:

```objective-c
id obj;
obj = [[NSObject alloc] init];
[obj respondsToSelector:@selector(sayHello) withKey:nil usingBlock:^(id receiver) {
	// NSLog(@"obj = %@", obj); // Causes retain cycle! Use receiver instead.
	NSLog(@"receiver = %@", receiver);
}];
[obj performSelector:@selector(sayHello)];
```


### Block with arguments and/or return value
REResponder supports Block with arguments and/or return value. When you want to add or override method with arguments, list the arguments following `receiver` argument:

```objective-c
UIAlertView *alertView;
// …
[alertView
	respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)
	withKey:nil
	usingBlock:^(id receiver, UIAlertView *alertView) {
		return NO;
	}
];
```


### Manages Block with key
You can assign a key to Block, then you can manage Block with the key. To assign a key, you pass arbitrary object as key argument of `-respondsToSelector:withKey:usingBlock:` method. You can check if an instance has a block by calling `-hasBlockForSelector:withKey:` method. You can remove a block by calling `-removeBlockForSelector:withKey:` method.

When an instance will be released, blocks added to the instance are removed automatically. If you don't need to manage a block specially, you can pass nil as the key argument - UUID string will be assigned to the block internally.


### Stack of Blocks
An instance stacks Blocks per selector. The last added (upper most) Block is the block executed when the selector is called. When you try to add a Block with already existing key, old one will be removed, then new one will be stacked at the top.


### <a id="InvokingSupermethod"></a>Invoking supermethod
You can invoke supermethod - implementation of Block under the current Block, or hard-coded implementation - using `-supermethodOfCurrentBlock` method:

```objective-c
[obj respondsToSelector:@selector(description) withKey:nil usingBlock:^(id receiver) {
	// Make description…
	NSMutableString *description;
	description = [NSMutableString string];
	
	// Append original description
	IMP supermethod;
	if ((supermethod = [receiver supermethodOfCurrentBlock])) {
		[description appendString:supermethod(receiver, @selector(description))];
	}
	
	// Customize description…
	
	return description;
}];
```


The supermethod needs receiver and selector arguments at least. If the selector has arguments, list them following selector argument.

Cast supermethod if it's needed. For example, below is a cast of supermethod which returns CGRect:

```objective-c
typedef CGRect (*RectIMP)(id, SEL, ...);
RectIMP supermethod;
if ((supermethod = (RectIMP)[receiver supermethodOfCurrentBlock])) {
	rect = supermethod(receiver, @selector(rect));
}
```


### <a id="Examples"></a>Efficient Examples
The following sections illustrate some efficient examples of REResponder.


#### <a id="DelegateItself"></a>Delegate itself
A class using delegation pattern keeps reusability by excluding application contexts and provides delegate methods to plug application contexts into it. If you can plug application contexts into an instance, you can make an instance independent from delegate object which is on application layer. REResponder makes it possible.

The code fragments below illustrate how you can set `alertView` itself as the delegate to `alertView`:

```objective-c
UIAlertView *alertView;
alertView = [[UIAlertView alloc]
	initWithTitle:@"title"
	message:@"message"
	delegate:nil
	cancelButtonTitle:@"Cancel"
	otherButtonTitles:@"OK", nil
];
[alertView
	respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)
	withKey:nil
	usingBlock:^(id receiver, UIAlertView *alertView, NSInteger buttonIndex) {
		// Do something…
	}
];
alertView.delegate = alertView;
```


The code fragments below illustrate how you can set `animation` itself as the delegate to `animation`:

```objective-c
CABasicAnimation *animation;
// …
[animation
	respondsToSelector:@selector(animationDidStop:finished:)
	withKey:nil
	usingBlock:^(id receiver, CABasicAnimation *animation, BOOL finished) {
		// Do something…
	}
];
animation.delegate = animation;
```


Pros:

* You can gather related code fragments in one place. It improves maintainability.
* There is no need to worry "Whose delegate method was called?".
* There is no need to worry "Delegate is a zombie?".


#### Target itself
For target/action paradigm, you can use similar technique described in "[Delegate itself](#DelegateItself)". The code fragments below adds button - whose target is button itself - to `UICollectionViewCell`:

```objective-c
UIButton *button;
// …
[button respondsToSelector:@selector(buttonAction) withKey:@"key" usingBlock:^(id receiver) {
	// Do something…
}];
[button addTarget:button action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
[cell.contentView addSubview:button];
```


#### Mock object in UnitTest
REResponder is also useful for UnitTest. The code fragments below check whether delegate method of `BalloonController` is called, using mock object:

```objective-c
__block BOOL called = NO;

// Make mock
id mock;
mock = [[NSObject alloc] init];
[mock
	respondsToSelector:@selector(balloonControllerDidDismissBalloon:)
	withKey:nil
	usingBlock:^(id receiver, BalloonController *balloonController) {
		called = YES;
	}
];
balloonController.delegate = mock;

// Dismiss balloon
[balloonController dismissBalloonAnimated:NO];
STAssertTrue(called, @"");
```


#### Stub out high-cost process in UnitTest
The code fragments below stub out download process of AccountManager, then test view controller of account-view:

```objective-c
// Load sample image
__weak UIImage *sampleImage;
NSString *sampleImagePath;
sampleImagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"sample" ofType:@"png"];
sampleImage = [UIImage imageWithContentsOfFile:sampleImagePath];

// Stub out download process
[[AccountManager sharedManager]
	respondsToSelector:@selector(downloadProfileImageWithCompletion:)
	withKey:@"key"
	usingBlock:^(id receiver, void (^completion)(UIImage*, NSError*)) {
		// Execute completion block with sampleImage
		completion(sampleImage, nil);
		
		// Remove current block
		[receiver removeCurrentBlock];
	}
];

// Call thumbnailButtonAction which causes download of profile image
[acccountViewController thumbnailButtonAction];
STAssertEqualObjects(accountViewController.profileImageView.image, sampleImage, @"");
```


#### Gather code fragments
REResponder helps you to gather related code fragments into one place. For example, if you want to add code fragments about `UIKeyboardWillShowNotification`, you can gather them into `-_manageKeyboardWillShowNotificationObserver` method like below:

```objective-c
- (id)initWithCoder:(NSCoder *)aDecoder
{
	// super
	self = [super initWithCoder:aDecoder];
	if (!self) {
		return nil;
	}
	
	// Manage _keyboardWillShowNotificationObserver
	[self _manageKeyboardWillShowNotificationObserver];
	
	return self;
}

- (void)_manageKeyboardWillShowNotificationObserver
{
	__block id observer;
	observer = _keyboardWillShowNotificationObserver;
	
	#pragma mark └ [self viewWillAppear:]
	[self respondsToSelector:@selector(viewWillAppear:) withKey:nil usingBlock:^(id receiver, BOOL animated) {
		// supermethod
		REVoidIMP supermethod; // REVoidIMP is defined like this: typedef void (*REVoidIMP)(id, SEL, ...);
		if ((supermethod = (REVoidIMP)[receiver supermethodOfCurrentBlock])) {
			supermethod(receiver, @selector(viewWillAppear:), animated);
		}
		
		// Start observing
		if (!observer) {
			observer = [[NSNotificationCenter defaultCenter]
				addObserverForName:UIKeyboardWillShowNotification
				object:nil
				queue:[NSOperationQueue mainQueue]
				usingBlock:^(NSNotification *note) {
					// Do something…
				}
			];
		}
	}];
	
	#pragma mark └ [self viewDidDisappear:]
	[self respondsToSelector:@selector(viewDidDisappear:) withKey:nil usingBlock:^(id receiver, BOOL animated) {
		// supermethod
		REVoidIMP supermethod;
		if ((supermethod = (REVoidIMP)[receiver supermethodOfCurrentBlock])) {
			supermethod(receiver, @selector(viewDidDisappear:), animated);
		}
		
		// Stop observing
		[[NSNotificationCenter defaultCenter] removeObserver:observer];
		observer = nil;
	}];
}
```


### REResponder known issues
a. **Class is changed**<br />
When you add/override methods, the instance becomes an instance of class named "REResponder_UUID_OriginalClassName". It turned out that it breaks relationships of KVO. The problem has been fixed already, but some other problems can happen. If the problems happen, cope with them using `-willChangeClass:` and `-didChangeClass:`, or `REObjectWillChangeClassNotification` and `REObjectDidChangeClassNotification`.





## <a id="REObserver"></a>REObserver
REObserver provides:

1. [Blocks compatible method for KVO](#KVOWithBlock)
2. [Simple method to stop observing](#StopObservingSimply)
3. [Automatic observation stop system](#AutomaticObservationStop)


### <a id="KVOWithBlock"></a>Blocks compatible method for KVO
REObserver provides `-addObserverForKeyPath:options:usingBlock:` method. You can pass a block to be executed when the value is changed:

```objective-c
id observer;
observer = [obj addObserverForKeyPath:@"someKeyPath" options:0 usingBlock:^(NSDictionary *change) {
	// Do something…
}];
```


Pros:

* You can gather related code fragments in one place. It improves maintainability.
* There is no need to worry "Whose value for which keyPath is changed?".
* There is no need to make a context object, because Blocks can hold context.


### <a id="StopObservingSimply"></a>Simple method to stop observing
You can stop observing with `-stopObserving` method:

```objective-c
[observer stopObserving];
```


With code above, `observer` stops all observations. There is no need to remember observed object, keyPath, and context.

### <a id="AutomaticObservationStop"></a>Automatic observation stop system
When observed object or observing object is released, REObserver stops related observations automatically. It solves problems below (Below is Non-ARC code):

```objective-c
- (void)problem1
{
	UIView *view;
	view = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	@autoreleasepool {
		id observer;
		observer = [[[NSObject alloc] init] autorelease];
		[view addObserver:observer forKeyPath:@"backgroundColor" options:0 context:nil];
	}
	NSLog(@"observationInfo = %@", (id)[view observationInfo]); // view is observed by zombie!
	view.backgroundColor = [UIColor redColor]; // Crash!
}

- (void)problem2
{
	id observer;
	observer = [[[NSObject alloc] init] autorelease];
	@autoreleasepool {
		UIView *view;
		view = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		[view addObserver:observer forKeyPath:@"backgroundColor" options:0 context:nil];
	}
	// observer is observing zombie!
}
```


## Availability
iOS 5.0 and later

OS X 10.7 and later


## Installation
You can install REKit using [CocoaPods](http://cocoapods.org "CcooaPods").

&lt;Podfile for iOS&gt;

```
platform :ios, '5.0'
pod 'REKit'
```

&lt;Podfile for OS X&gt;

```
platform :osx, '10.7'
pod 'REKit'
```

&lt;Terminal&gt;

```
$ pod install
```

If you want to install REKit manually, add files which is under REKit folder to your project.


## License
MIT License. For more detail, read LICENSE file.
