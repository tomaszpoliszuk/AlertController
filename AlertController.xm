NSString *domainString = @"com.tomaszpoliszuk.alertcontroller";

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

void TweakSettingsChanged() {
	NSUserDefaults *tweakSettings = [[NSUserDefaults alloc] initWithSuiteName:domainString];

	enableTweak = [[tweakSettings objectForKey:@"enableTweak"] boolValue];

	uiStyle = [[tweakSettings valueForKey:@"uiStyle"] integerValue];

	dismissByTappingOutside = [[tweakSettings objectForKey:@"dismissByTappingOutside"] boolValue];
	displayButtonsVertically = [[tweakSettings objectForKey:@"displayButtonsVertically"] boolValue];
	showIcons = [[tweakSettings objectForKey:@"showIcons"] boolValue];
	hideCancelAction = [[tweakSettings objectForKey:@"hideCancelAction"] boolValue];

//	setAlertStyle = [[tweakSettings valueForKey:@"setAlertStyle"] integerValue];
	setActionSheetStyle = [[tweakSettings valueForKey:@"setActionSheetStyle"] integerValue];

	squareCornersInAlert = [[tweakSettings objectForKey:@"squareCornersInAlert"] boolValue];
	removeSeparatorsInAlert = [[tweakSettings objectForKey:@"removeSeparatorsInAlert"] boolValue];

	squareCornersInActionSheet = [[tweakSettings objectForKey:@"squareCornersInActionSheet"] boolValue];
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
		TweakSettingsChanged();
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)TweakSettingsChanged, CFSTR("com.tomaszpoliszuk.alertcontroller.settingschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		%init; // == %init(_ungrouped);
	}
}
