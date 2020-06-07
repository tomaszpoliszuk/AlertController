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

%hook _UIAlertControllerView
-(bool)showsCancelAction {
	if ( enableTweak && !dismissByTappingOutside && !hideCancelAction ) {
		return !hideCancelAction;
	} else if ( enableTweak && dismissByTappingOutside && hideCancelAction ) {
		return !hideCancelAction;
	} else {
		return %orig;
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
