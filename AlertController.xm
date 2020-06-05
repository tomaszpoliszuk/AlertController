#define SettingsChangedNotification "com.tomaszpoliszuk.alertcontroller/TweakSettingsChanged"
#define UserSettingsFile @"/var/mobile/Library/Preferences/com.tomaszpoliszuk.alertcontroller.plist"
#define PackageName "com.tomaszpoliszuk.alertcontroller"


NSMutableDictionary *TweakSettings;

static BOOL EnableTweak;
static BOOL DismissByTappingOutside;
static BOOL HideCancelAction;

void TweakSettingsChanged() {
	CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR(PackageName), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if(keyList) {
		TweakSettings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, CFSTR(PackageName), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	} else {
		TweakSettings = nil;
	}
	if (!TweakSettings) {
		TweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:UserSettingsFile];
	}
	EnableTweak = [([TweakSettings objectForKey:@"EnableTweak"] ?: @(NO)) boolValue];
	DismissByTappingOutside = [([TweakSettings objectForKey:@"DismissByTappingOutside"] ?: @(NO)) boolValue];
	HideCancelAction = [([TweakSettings objectForKey:@"HideCancelAction"] ?: @(NO)) boolValue];

	[[NSNotificationCenter defaultCenter] postNotificationName:@SettingsChangedNotification object:nil userInfo:nil];
}

%hook UIAlertController
-(bool)_canDismissWithGestureRecognizer {
	if ( EnableTweak ) {
		return DismissByTappingOutside;
	} else {
		return %orig;
	}
}
%end

%hook UIAlertControllerVisualStyle
-(bool)hideCancelAction:(id)arg1 inAlertController:(id)arg2 {
	if ( EnableTweak ) {
		return HideCancelAction;
		return arg1;
		return arg2;
	} else {
		return %orig;
	}
}
%end

%ctor {
	if ([[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"/Application"] || [[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"SpringBoard.app"]) {
		TweakSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:UserSettingsFile];
		TweakSettingsChanged();
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)TweakSettingsChanged, CFSTR(SettingsChangedNotification), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		%init; // == %init(_ungrouped);
	}
}
