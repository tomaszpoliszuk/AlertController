NSString *domainString = @"com.tomaszpoliszuk.alertcontroller";

NSMutableDictionary *tweakSettings;

static BOOL enableTweak;
static BOOL dismissByTappingOutside;
static BOOL displayButtonsVertically;
static BOOL hideCancelAction;

static long long setAlertStyle;
static long long setAlertStyleOutput;

static long long setActionSheetStyle;
static long long setActionSheetStyleOutput;

static int uiStyle;


@interface UIView (AlertController)
-(void)setOverrideUserInterfaceStyle:(NSInteger)style;
@end

@interface UIInterfaceActionGroupView : UIView
-(void)updateTraitOverride;
@end

@interface _UIContextMenuActionsListView : UIInterfaceActionGroupView
-(void)updateTraitOverride;
@end

@interface _UIAlertControllerInterfaceActionGroupView : UIInterfaceActionGroupView
-(void)updateTraitOverride;
@end

void TweakSettingsChanged() {
	NSUserDefaults *tweakSettings = [[NSUserDefaults alloc] initWithSuiteName:domainString];
	enableTweak = [[tweakSettings objectForKey:@"enableTweak"] boolValue];
	dismissByTappingOutside = [[tweakSettings objectForKey:@"dismissByTappingOutside"] boolValue];
	displayButtonsVertically = [[tweakSettings objectForKey:@"displayButtonsVertically"] boolValue];
	hideCancelAction = [[tweakSettings objectForKey:@"hideCancelAction"] boolValue];

	setAlertStyle = [[tweakSettings valueForKey:@"setAlertStyle"] integerValue];
	setActionSheetStyle = [[tweakSettings valueForKey:@"setActionSheetStyle"] integerValue];

	uiStyle = [[tweakSettings valueForKey:@"uiStyle"] integerValue];
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
	if ( setAlertStyle == 9 ) {
//	Alert = Default
		setAlertStyleOutput = origValue;
	} else {
		setAlertStyleOutput = setAlertStyle;
	}
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

%hook UIInterfaceActionGroupView
%new
-(void)updateTraitOverride {
	[self setOverrideUserInterfaceStyle:uiStyle];
}
-(void)didMoveToWindow {
	if (uiStyle > 0) {
		[self setOverrideUserInterfaceStyle:uiStyle];
	}
	%orig;
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

%ctor {
// Found in https://github.com/EthanRDoesMC/Dawn/commit/847cb5192dae9138a893e394da825e86be561a6b
	if ([[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"/Application"] || [[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"SpringBoard.app"]) {
		TweakSettingsChanged();
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)TweakSettingsChanged, CFSTR("com.tomaszpoliszuk.alertcontroller.settingschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		%init; // == %init(_ungrouped);
	}
}
