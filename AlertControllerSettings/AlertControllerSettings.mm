//#import <Preferences/PSViewController.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface PSControlTableCell : PSTableCell
- (UIControl *)control;
@end

@interface PSSwitchTableCell : PSControlTableCell
@end

@interface PSListController (AlertController)
-(BOOL)containsSpecifier:(id)arg1;
@end

@interface AlertControllerMainSettings : PSListController
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
@end

@implementation AlertControllerMainSettings
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

- (void) showExampleAlert
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Example Alert" message:@"(V)(;,;)(V) Why Not Zoidberg?" preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
	}];

	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
	[alert addAction:ok];
	[alert addAction:cancel];
	[self presentViewController:alert animated:YES completion:nil];
}

-(void)TweakSourceCode {
	NSURL *tweakSourceCode = [NSURL URLWithString:@"https://github.com/tomaszpoliszuk/AlertController"];
	[[UIApplication sharedApplication] openURL:tweakSourceCode options:@{} completionHandler:nil];
}

-(void)TweakReportIssue {
	NSURL *tweakReportIssue = [NSURL URLWithString:@"https://github.com/tomaszpoliszuk/AlertController/issues/new"];
	[[UIApplication sharedApplication] openURL:tweakReportIssue options:@{} completionHandler:nil];
}

-(void)TomaszPoliszukOnGithub {
	NSURL *tomaszPoliszukOnGithub = [NSURL URLWithString:@"https://github.com/tomaszpoliszuk/"];
	[[UIApplication sharedApplication] openURL:tomaszPoliszukOnGithub options:@{} completionHandler:nil];
}

@end
