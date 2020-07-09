#define userSettingsFile @"/var/mobile/Library/Preferences/com.tomaszpoliszuk.alertcontroller.plist"
#define packageName "com.tomaszpoliszuk.alertcontroller"

NSMutableDictionary *tweakSettings;

static BOOL enableTweak;

static int uiStyle;

static BOOL dismissByTappingOutside;
static BOOL displayButtonsVertically;
static BOOL showIcons;
static BOOL hideCancelAction;

//	static long long setAlertStyle;
static long long setAlertStyleOutput;

static long long setActionSheetStyle;
static long long setActionSheetStyleOutput;

static BOOL squareCornersInAlert;
static BOOL removeSeparatorsInAlert;

static BOOL squareCornersInActionSheet;

@interface UIView (AlertController)
-(void)setOverrideUserInterfaceStyle:(NSInteger)style;
@end

@interface UIInterfaceActionGroupView : UIView
-(void)updateTraitOverride;
@end

@interface _UIAlertControllerInterfaceActionGroupView : UIInterfaceActionGroupView
-(void)updateTraitOverride;
@end

@interface UIInterfaceActionConcreteVisualStyle : NSObject
@end

@interface UIInterfaceActionConcreteVisualStyle_iOS : UIInterfaceActionConcreteVisualStyle
- (double)contentCornerRadius;
@end

@interface UIInterfaceActionConcreteVisualStyle_iOSAlert : UIInterfaceActionConcreteVisualStyle_iOS
@end

@interface UIInterfaceActionConcreteVisualStyle_iOSSheet : UIInterfaceActionConcreteVisualStyle_iOS
@end

void SettingsChanged() {
	CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR(packageName), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if(keyList) {
		tweakSettings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, CFSTR(packageName), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	} else {
		tweakSettings = nil;
	}
	if (!tweakSettings) {
		tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:userSettingsFile];
	}

	enableTweak = [([tweakSettings objectForKey:@"enableTweak"] ?: @(YES)) boolValue];

	uiStyle = [([tweakSettings valueForKey:@"uiStyle"] ?: @(0)) integerValue];

	dismissByTappingOutside = [([tweakSettings objectForKey:@"dismissByTappingOutside"] ?: @(YES)) boolValue];
	displayButtonsVertically = [([tweakSettings objectForKey:@"displayButtonsVertically"] ?: @(NO)) boolValue];
	showIcons = [([tweakSettings objectForKey:@"showIcons"] ?: @(YES)) boolValue];
	hideCancelAction = [([tweakSettings objectForKey:@"hideCancelAction"] ?: @(NO)) boolValue];

//	setAlertStyle = [([tweakSettings valueForKey:@"setAlertStyle"] ?: @(9)) integerValue];
	setActionSheetStyle = [[tweakSettings valueForKey:@"setActionSheetStyle"] integerValue];

	squareCornersInAlert = [([tweakSettings objectForKey:@"squareCornersInAlert"] ?: @(NO)) boolValue];
	removeSeparatorsInAlert = [([tweakSettings objectForKey:@"removeSeparatorsInAlert"] ?: @(NO)) boolValue];

	squareCornersInActionSheet = [([tweakSettings objectForKey:@"squareCornersInActionSheet"] ?: @(NO)) boolValue];
}

static void receivedNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	SettingsChanged();
}

%hook UIAlertController
-(bool)_canDismissWithGestureRecognizer {
	bool origValue = %orig;
	if ( enableTweak ) {
		return dismissByTappingOutside;
	} else {
		return origValue;
	}
}
- (long long)preferredStyle {
	long long origValue = %orig;
//	if ( setAlertStyle == 9 ) {
//	Alert = Default
		setAlertStyleOutput = origValue;
//	} else {
//		setAlertStyleOutput = setAlertStyle;
//	}
	if ( setActionSheetStyle == 9 ) {
//	Action Sheet = Default
		setActionSheetStyleOutput = origValue;
	} else {
		setActionSheetStyleOutput = setActionSheetStyle;
	}
	if ( enableTweak && origValue == 1 ) {
//	Alert
		return setAlertStyleOutput;
	} else if ( enableTweak && origValue == 0 ) {
//	Action Sheet
		return setActionSheetStyleOutput;
	} else {
		return origValue;
	}
}
-(void)viewWillAppear:(BOOL)arg1 {
	BOOL origValue = arg1;
//	Force title and label color in dark mode alert so older, light-only applications displays text correctly
	if ( uiStyle == 2 ) {
		MSHookIvar<UILabel *>(self.view, "_titleLabel").textColor = UIColor.whiteColor;
		MSHookIvar<UILabel *>(self.view, "_messageLabel").textColor = UIColor.whiteColor;
	}
	%orig(origValue);
}
%end


%hook _UIAlertControllerView
-(void)_configureActionGroupViewToAllowHorizontalLayout:(bool)arg1 {
	if ( enableTweak && displayButtonsVertically ) {
		%orig(!displayButtonsVertically);
	} else {
		%orig;
	}
}
-(bool)showsCancelAction {
	BOOL origValue = %orig;
	if ( enableTweak && !dismissByTappingOutside && !hideCancelAction ) {
		return !hideCancelAction;
	} else if ( enableTweak && dismissByTappingOutside && hideCancelAction ) {
		return !hideCancelAction;
	} else {
		return origValue;
	}
}
%end

%hook UIAlertAction
- (long long)image {
	long long origValue = %orig;
	if ( enableTweak && !showIcons ) {
		return nil;
	} else {
		return origValue;
	}
}
%end

%hook _UIAlertControllerInterfaceActionGroupView
%new
-(void)updateTraitOverride {
	if ( enableTweak && uiStyle ) {
		[self setOverrideUserInterfaceStyle:uiStyle];
	}
}
-(void)didMoveToWindow {
	if (enableTweak && uiStyle > 0) {
		[self setOverrideUserInterfaceStyle:uiStyle];
	}
	%orig;
}
%end

%hook UIInterfaceActionConcreteVisualStyle_iOSAlert
- (double)contentCornerRadius {
	double origValue = %orig;
	if ( enableTweak && squareCornersInAlert ) {
		return 0;
	} else {
		return origValue;
	}
}
- (id)newActionSeparatorViewForGroupViewState:(id)arg1 {
	id origValue = %orig;
	if ( enableTweak && removeSeparatorsInAlert ) {
		return nil;
	} else {
		return origValue;
	}
}
%end

%hook UIInterfaceActionConcreteVisualStyle_iOSSheet
- (double)contentCornerRadius {
	double origValue = %orig;
	if ( enableTweak && squareCornersInActionSheet ) {
		return 0;
	} else {
		return origValue;
	}
}
%end

%ctor {
// Found in https://github.com/EthanRDoesMC/Dawn/commit/847cb5192dae9138a893e394da825e86be561a6b
	if ([[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"/Application"] || [[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"SpringBoard.app"]) {
		SettingsChanged();
		CFNotificationCenterAddObserver( CFNotificationCenterGetDarwinNotifyCenter(), NULL, receivedNotification, CFSTR("com.tomaszpoliszuk.alertcontroller.settingschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		%init; // == %init(_ungrouped);
	}
}
