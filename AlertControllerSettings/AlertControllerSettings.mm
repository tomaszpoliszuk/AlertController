#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

#define isiOS13Up (kCFCoreFoundationVersionNumber >= 1665.15)

@interface PSListController (AlertController)
@end
@interface AlertControllerSettings : PSListController {
	NSMutableArray *removeSpecifiers;
}
@end

NSString *const domainString = @"com.tomaszpoliszuk.alertcontroller";

@implementation AlertControllerSettings
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
		if (!isiOS13Up) {
			removeSpecifiers = [[NSMutableArray alloc]init];
			for(PSSpecifier* specifier in _specifiers) {
				NSString* key = [specifier propertyForKey:@"key"];
				if([key isEqualToString:@"uiStyleInAlert"] || [key isEqualToString:@"showSeparatorsInAlert"] || [key isEqualToString:@"uiStyleInActionSheet"] || [key isEqualToString:@"showSeparatorsInActionSheet"]) {
					[removeSpecifiers addObject:specifier];
				}
			}
			[_specifiers removeObjectsInArray:removeSpecifiers];
		}
	}
	return _specifiers;
}
- (void)loadView {
	[super loadView];
	((UITableView *)[self table]).keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}
- (void)showExampleAlert {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Title of Example Alert" message:@"This is message of example Alert feel free to ignore what is written here, more words to make it a litle bit longer. \n \n All glory Hypnotoad." preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:alert animated:YES completion:nil];
}
- (void)showExampleTextAlert {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Title of Example Text Alert" message:@"This is example of Alert with ability to type text in it (like login alerts)." preferredStyle:UIAlertControllerStyleAlert];
	[alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		textField.placeholder = @"Username";
	}];
	[alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		textField.placeholder = @"Password";
		textField.secureTextEntry = YES;
	}];
	[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:alert animated:YES completion:nil];
}
- (void)showExampleActionSheet {
	UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Title of Example Action Sheet" message:@"This is message of example Action Sheet feel free to ignore what is written here, more words to make it a litle bit longer. \n \n All glory Hypnotoad." preferredStyle:UIAlertControllerStyleActionSheet];
	[actionSheet addAction:[UIAlertAction actionWithTitle:@"(•_•)" style:UIAlertActionStyleDefault handler:nil]];
	[actionSheet addAction:[UIAlertAction actionWithTitle:@"( •_•)>⌐■-■" style:UIAlertActionStyleDefault handler:nil]];
	[actionSheet addAction:[UIAlertAction actionWithTitle:@"(⌐■_■)" style:UIAlertActionStyleDefault handler:nil]];
	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:actionSheet animated:YES completion:nil];
}
- (void)resetSettings {
	NSUserDefaults *tweakSettings = [[NSUserDefaults alloc] initWithSuiteName:domainString];
	UIAlertController *resetSettingsAlert = [UIAlertController alertControllerWithTitle:@"Reset Alert Controller Settings" message:@"Do you want to reset settings?" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		for(NSString* key in [[tweakSettings dictionaryRepresentation] allKeys]) {
			[tweakSettings removeObjectForKey:key];
		}
		[tweakSettings synchronize];
		[self reloadSpecifiers];
	}];
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
	[resetSettingsAlert addAction:cancel];
	[resetSettingsAlert addAction:confirm];
	[self presentViewController:resetSettingsAlert animated:YES completion:nil];
}
-(void)sourceCode {
	NSURL *sourceCode = [NSURL URLWithString:@"https://github.com/tomaszpoliszuk/AlertController"];
	[[UIApplication sharedApplication] openURL:sourceCode options:@{} completionHandler:nil];
}
-(void)knownIssues {
	NSURL *knownIssues = [NSURL URLWithString:@"https://github.com/tomaszpoliszuk/AlertController/issues"];
	[[UIApplication sharedApplication] openURL:knownIssues options:@{} completionHandler:nil];
}
-(void)TomaszPoliszukAtBigBoss {
	UIApplication *application = [UIApplication sharedApplication];
	NSString *tweakName = @"Alert+Controller";
	NSURL *twitterWebsite = [NSURL URLWithString:[@"http://apt.thebigboss.org/developer-packages.php?name=" stringByAppendingString:tweakName]];
	[application openURL:twitterWebsite options:@{} completionHandler:nil];
}
-(void)TomaszPoliszukAtGithub {
	UIApplication *application = [UIApplication sharedApplication];
	NSString *username = @"tomaszpoliszuk";
	NSURL *githubWebsite = [NSURL URLWithString:[@"https://github.com/" stringByAppendingString:username]];
	[application openURL:githubWebsite options:@{} completionHandler:nil];
}
-(void)TomaszPoliszukAtTwitter {
	UIApplication *application = [UIApplication sharedApplication];
	NSString *username = @"tomaszpoliszuk";
	NSURL *twitterWebsite = [NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:username]];
	[application openURL:twitterWebsite options:@{} completionHandler:nil];
}
@end
