#define userSettingsFile @"/var/mobile/Library/Preferences/com.tomaszpoliszuk.alertcontroller.plist"
#define packageName "com.tomaszpoliszuk.alertcontroller"
#define isiOS13Up (kCFCoreFoundationVersionNumber >= 1665.15)

NSMutableDictionary *tweakSettings;

static bool enableTweak;

static bool dismissByTappingOutside;
static bool showIcons;
static bool hideCancelAction;

static long long setAlertStyle;
static long long setActionSheetStyle;

static int uiStyleInAlert;
static double titleLabelFontAlert;
static double messageLabelFontAlert;
static bool squareCornersInAlert;
static bool showSeparatorsInAlert;
static long long buttonsSizeAlert;
static bool displayButtonsVerticallyAlert;

static int uiStyleInActionSheet;
static double titleLabelFontActionSheet;
static double messageLabelFontActionSheet;
static bool squareCornersInActionSheet;
static bool showSeparatorsInActionSheet;
static long long buttonsSizeActionSheet;
static bool mergeCancelButtonInActionSheet;


@interface UIAlertController (AlertController)
@property (readonly) long long _resolvedStyle;
@end

@interface UIView (AlertController)
-(void)setOverrideUserInterfaceStyle:(NSInteger)style;
-(id)_viewControllerForAncestor;
@end

@interface UIInterfaceActionGroupView : UIView
@end

@interface _UIAlertControllerInterfaceActionGroupView : UIInterfaceActionGroupView
@end

@interface _UIInterfaceActionVibrantSeparatorView : UIView
@end

void SettingsChanged() {
	CFArrayRef keyList = CFPreferencesCopyKeyList(
		CFSTR(packageName),
		kCFPreferencesCurrentUser,
		kCFPreferencesAnyHost
	);
	if(keyList) {
		tweakSettings = (
			NSMutableDictionary *)CFBridgingRelease(
			CFPreferencesCopyMultiple(
				keyList,
				CFSTR(packageName),
				kCFPreferencesCurrentUser,
				kCFPreferencesAnyHost
			)
		);
		CFRelease(keyList);
	} else {
		tweakSettings = nil;
	}
	if (!tweakSettings) {
		tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:userSettingsFile];
	}

	enableTweak = [([tweakSettings objectForKey:@"enableTweak"] ?: @(YES)) boolValue];

	dismissByTappingOutside = [([tweakSettings objectForKey:@"dismissByTappingOutside"] ?: @(YES)) boolValue];
	showIcons = [([tweakSettings objectForKey:@"showIcons"] ?: @(YES)) boolValue];
	hideCancelAction = [([tweakSettings objectForKey:@"hideCancelAction"] ?: @(NO)) boolValue];

	setAlertStyle = [([tweakSettings valueForKey:@"setAlertStyle"] ?: @(1)) integerValue];
	setActionSheetStyle = [([tweakSettings valueForKey:@"setActionSheetStyle"] ?: @(0)) integerValue];

	uiStyleInAlert = [([tweakSettings valueForKey:@"uiStyleInAlert"] ?: @(0)) integerValue];
	titleLabelFontAlert = [[tweakSettings valueForKey:@"titleLabelFontAlert"] integerValue];
	messageLabelFontAlert = [[tweakSettings valueForKey:@"messageLabelFontAlert"] integerValue];
	squareCornersInAlert = [([tweakSettings objectForKey:@"squareCornersInAlert"] ?: @(NO)) boolValue];
	showSeparatorsInAlert = [([tweakSettings objectForKey:@"showSeparatorsInAlert"] ?: @(YES)) boolValue];
	buttonsSizeAlert = [([tweakSettings valueForKey:@"buttonsSizeAlert"] ?: @(0)) integerValue];
	displayButtonsVerticallyAlert = [([tweakSettings objectForKey:@"displayButtonsVerticallyAlert"] ?: @(NO)) boolValue];

	uiStyleInActionSheet = [([tweakSettings valueForKey:@"uiStyleInActionSheet"] ?: @(0)) integerValue];
	titleLabelFontActionSheet = [[tweakSettings valueForKey:@"titleLabelFontActionSheet"] integerValue];
	messageLabelFontActionSheet = [[tweakSettings valueForKey:@"messageLabelFontActionSheet"] integerValue];
	squareCornersInActionSheet = [([tweakSettings objectForKey:@"squareCornersInActionSheet"] ?: @(NO)) boolValue];
	showSeparatorsInActionSheet = [([tweakSettings objectForKey:@"showSeparatorsInActionSheet"] ?: @(YES)) boolValue];
	buttonsSizeActionSheet = [([tweakSettings valueForKey:@"buttonsSizeActionSheet"] ?: @(1)) integerValue];
	mergeCancelButtonInActionSheet = [([tweakSettings objectForKey:@"mergeCancelButtonInActionSheet"] ?: @(NO)) boolValue];

}

static void receivedNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	SettingsChanged();
}

%hook UIAlertController
-(bool)_canDismissWithGestureRecognizer {
	bool origValue = %orig;
	if ( enableTweak ) {
		return dismissByTappingOutside;
	}
	return origValue;
}
- (long long)_resolvedStyle {
	long long origValue = %orig;
	if ( enableTweak && origValue == 1 && ( setAlertStyle == 0 || 1 ) ) {
		return setAlertStyle;
	} else if ( enableTweak && origValue == 0 && ( setActionSheetStyle == 0 || 1 ) ) {
		return setActionSheetStyle;
	}
	return origValue;
}
%end

%hook _UIAlertControllerView
-(void)_configureActionGroupViewToAllowHorizontalLayout:(bool)arg1 {
	if ( enableTweak && displayButtonsVerticallyAlert ) {
		%orig(!displayButtonsVerticallyAlert);
	} else {
		%orig;
	}
}
-(bool)showsCancelAction {
	bool origValue = %orig;
	if ( enableTweak && !dismissByTappingOutside && !hideCancelAction ) {
		return !hideCancelAction;
	} else if ( enableTweak && dismissByTappingOutside && hideCancelAction ) {
		return !hideCancelAction;
	}
	return origValue;
}
- (void)setCancelActionIsDiscrete:(bool)arg1 {
	if ( enableTweak && mergeCancelButtonInActionSheet ) {
		arg1 = NO;
	}
	%orig;
}
- (bool)_titleAndMessageLabelUseVibrancy {
	bool origValue = %orig;
	if ( enableTweak ) {
//	when tweak is enabled turn off tint in action sheets to allow for text color customisation
		return NO;
	}
	return origValue;
}
%end

%hook _UIAlertControllerInterfaceActionGroupView
-(void)updateTraitOverride {
	if ( enableTweak ) {
		if (isiOS13Up) {
			if ([[self _viewControllerForAncestor] isKindOfClass:%c(UIAlertController)]) {
				UIAlertController *alertController = [self _viewControllerForAncestor];
				if ( uiStyleInAlert > 0 && alertController._resolvedStyle == 1 ) {
					[self setOverrideUserInterfaceStyle:uiStyleInAlert];
				}
				if ( uiStyleInActionSheet > 0 && alertController._resolvedStyle == 0 ) {
					[self setOverrideUserInterfaceStyle:uiStyleInActionSheet];
				}
			}
		}
	}
}
-(void)didMoveToWindow {
	if ( enableTweak ) {
		if (isiOS13Up) {
			if ([[self _viewControllerForAncestor] isKindOfClass:%c(UIAlertController)]) {
				UIAlertController *alertController = [self _viewControllerForAncestor];
				if ( uiStyleInAlert > 0 && alertController._resolvedStyle == 1 ) {
					[self setOverrideUserInterfaceStyle:uiStyleInAlert];
				}
				if ( uiStyleInActionSheet > 0 && alertController._resolvedStyle == 0 ) {
					[self setOverrideUserInterfaceStyle:uiStyleInActionSheet];
				}
			}
		}
	}
	%orig;
}
- (bool)_shouldShowSeparatorAboveActionsSequenceView {
	bool origValue = %orig;
	if ( enableTweak ) {
		if (isiOS13Up) {
			if ([[self _viewControllerForAncestor] isKindOfClass:%c(UIAlertController)]) {
				UIAlertController *alertController = [self _viewControllerForAncestor];
				if ( alertController._resolvedStyle == 1 && !showSeparatorsInAlert ) {
					return NO;
				}
			}
			if ([[self _viewControllerForAncestor] isKindOfClass:%c(UIAlertController)]) {
				UIAlertController *alertController = [self _viewControllerForAncestor];
				if ( alertController._resolvedStyle == 0 && !showSeparatorsInActionSheet ) {
					return NO;
				}
			}
		}
	}
	return origValue;
}
%end

%hook UIAlertControllerVisualStyleAlert
+ (long long)interfaceActionPresentationStyle {
	long long origValue = %orig;
	if ( enableTweak && buttonsSizeAlert != 999 ) {
		return buttonsSizeAlert;
	}
	return origValue;
}
- (id)titleLabelFont {
	id origValue = %orig;
	if ( enableTweak && titleLabelFontAlert > 0 ) {
		return [UIFont systemFontOfSize:titleLabelFontAlert];
	}
	return origValue;
}
- (id)messageLabelFont {
	id origValue = %orig;
	if ( enableTweak && messageLabelFontAlert > 0 ) {
		return [UIFont systemFontOfSize:messageLabelFontAlert];
	}
	return origValue;
}
%end

%hook UIInterfaceActionConcreteVisualStyle_iOSAlert
- (double)contentCornerRadius {
	double origValue = %orig;
	if ( enableTweak && squareCornersInAlert ) {
		return 0;
	}
	return origValue;
}
- (id)titleLabelColor {
	id origValue = %orig;
//	Force title color in dark mode Alert so older, light-only applications will display text correctly
	if ( enableTweak && uiStyleInAlert == 2 ) {
		return UIColor.whiteColor;
	}
	return origValue;
}
- (id)messageLabelColor {
	id origValue = %orig;
//	Force message color in dark mode Alert so older, light-only applications will display text correctly
	if ( enableTweak && uiStyleInAlert == 2 ) {
		return UIColor.whiteColor;
	}
	return origValue;
}
%end

%hook UIAlertControllerVisualStyleActionSheet
+ (long long)interfaceActionPresentationStyle {
	long long origValue = %orig;
	if ( enableTweak && buttonsSizeActionSheet != 999 ) {
		return buttonsSizeActionSheet;
	}
	return origValue;
}
- (id)titleLabelFont {
	id origValue = %orig;
	if ( enableTweak && titleLabelFontActionSheet > 0 ) {
		return [UIFont systemFontOfSize:titleLabelFontActionSheet];
	}
	return origValue;
}
- (id)messageLabelFont {
	id origValue = %orig;
	if ( enableTweak && messageLabelFontActionSheet > 0 ) {
		return [UIFont systemFontOfSize:messageLabelFontActionSheet];
	}
	return origValue;
}
- (id)titleLabelColor {
	id origValue = %orig;
//	Force title color in dark mode Action Sheet so older, light-only applications will display text correctly
	if ( enableTweak ) {
		if ( uiStyleInActionSheet == 1 ) {
			return UIColor.blackColor;
		} else if ( uiStyleInActionSheet == 2 ) {
			return UIColor.whiteColor;
		}
	}
	return origValue;
}
- (id)messageLabelColor {
	id origValue = %orig;
//	Force message color in dark mode Action Sheet so older, light-only applications will display text correctly
	if ( enableTweak ) {
		if ( uiStyleInActionSheet == 1 ) {
			return UIColor.blackColor;
		} else if ( uiStyleInActionSheet == 2 ) {
			return UIColor.whiteColor;
		}
	}
	return origValue;
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

%hook UIAlertAction
- (long long)image {
	long long origValue = %orig;
	if ( enableTweak && !showIcons ) {
		return nil;
	}
	return origValue;
}
%end

%hook _UIInterfaceActionVibrantSeparatorView
- (void)didMoveToWindow {
	%orig;
	if ( enableTweak ) {
		if (isiOS13Up) {
			if ([[self _viewControllerForAncestor] isKindOfClass:%c(UIAlertController)]) {
				UIAlertController *alertController = [self _viewControllerForAncestor];
				if ( alertController._resolvedStyle == 1 && !showSeparatorsInAlert ) {
					[self setHidden:TRUE];
				}
				if ( alertController._resolvedStyle == 0 && !showSeparatorsInActionSheet ) {
					[self setHidden:TRUE];
				}
			}
		}
	}
}
%end

%hook _UIAlertControlleriOSActionSheetCancelBackgroundView
- (id)initWithFrame:(CGRect)frame {
	id origValue = %orig;
	if (origValue) {
		if ( enableTweak && uiStyleInActionSheet == 2 ) {
			((UIView *)[origValue valueForKey:@"backgroundView"]).backgroundColor = [UIColor colorWithRed:0.24 green:0.24 blue:0.25 alpha:0.75];
			((UIView *)[origValue valueForKey:@"highlightView"]).backgroundColor = [UIColor colorWithRed:0.24 green:0.24 blue:0.25 alpha:0.9];
		}
	}
	return origValue;
}
%end

%ctor {
//	https://old.reddit.com/r/jailbreak/comments/4yz5v5/questionremote_messages_not_enabling/d6rlh88/
//	Found in https://github.com/EthanRDoesMC/Dawn/commit/847cb5192dae9138a893e394da825e86be561a6b
	if (
		[[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"/Application"]
		||
		[[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"SpringBoard.app"]
	) {
		SettingsChanged();
		CFNotificationCenterAddObserver(
			CFNotificationCenterGetDarwinNotifyCenter(),
			NULL,
			receivedNotification,
			CFSTR("com.tomaszpoliszuk.alertcontroller.settingschanged"),
			NULL,
			CFNotificationSuspensionBehaviorDeliverImmediately
		);
		%init;
	}
}
