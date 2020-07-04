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

- (void)showExampleAlert {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"(V)(;,;)(V)" message:@"Why Not Zoidberg?" preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:alert animated:YES completion:nil];
}
- (void)showExampleActionSheet {
	UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"( ͡° ͜ʖ ͡°)" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	[actionSheet addAction:[UIAlertAction actionWithTitle:@"(╯°益°)╯彡┻━┻" style:UIAlertActionStyleDefault handler:nil]];
	[actionSheet addAction:[UIAlertAction actionWithTitle:@"( ͡° ͜ʖ ͡°) ( ͡⊙ ͜ʖ ͡⊙) ( ͡◉ ͜ʖ ͡◉ )" style:UIAlertActionStyleDefault handler:nil]];
	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:actionSheet animated:YES completion:nil];
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
