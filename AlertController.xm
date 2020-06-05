NSString *settingsChangedNotification = @"com.tomaszpoliszuk.alertcontroller/TweakSettingsChanged";
NSString *kUserSettingsFile = @"/var/mobile/Library/Preferences/com.tomaszpoliszuk.alertcontroller.plist";
NSString *domainString = @"com.tomaszpoliszuk.alertcontroller";

NSMutableDictionary *tweakSettings;

static BOOL enableTweak;
static BOOL dismissByTappingOutside;
static BOOL hideCancelAction;

void TweakSettingsChanged() {
	NSUserDefaults *tweakSettings = [[NSUserDefaults alloc] initWithSuiteName:domainString];
	enableTweak = [[tweakSettings objectForKey:@"enableTweak"] boolValue];
	dismissByTappingOutside = [[tweakSettings objectForKey:@"dismissByTappingOutside"] boolValue];
	hideCancelAction = [[tweakSettings objectForKey:@"hideCancelAction"] boolValue];
}

%hook UIAlertController
-(bool)_canDismissWithGestureRecognizer {
	if ( enableTweak ) {
		return dismissByTappingOutside;
	} else {
		return %orig;
	}
}
%end

%hook UIAlertControllerVisualStyle
-(bool)hideCancelAction:(id)arg1 inAlertController:(id)arg2 {
	bool origValue = %orig; // == %orig(arg1, arg2);
	if ( enableTweak && dismissByTappingOutside ) {
		return hideCancelAction;
	} else {
		return origValue;
	}
}
%end

%ctor {
// Found in https://github.com/EthanRDoesMC/Dawn/commit/847cb5192dae9138a893e394da825e86be561a6b
	if ([[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"/Application"] || [[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"SpringBoard.app"]) {
		TweakSettingsChanged();
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)TweakSettingsChanged, CFSTR("com.tomaszpoliszuk.alertcontroller/TweakSettingsChanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		%init; // == %init(_ungrouped);
	}
}
