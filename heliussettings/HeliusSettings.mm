#import <Preferences/Preferences.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#include <MessageUI/MessageUI.h>
#include <spawn.h>
#include <signal.h>

#define TAGB 2

@interface HeliusSettingsListController : PSListController <UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {
	NSBundle *bundle;
}
@end

@implementation HeliusSettingsListController

-(id) specifiers {
	if(_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"HeliusSettings" target:self];
	}
	return _specifiers;
}

-(void) loadView {
	[super loadView];
	((UIViewController *) self).navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(confirmRespring)];
	bundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/HeliusSettings.bundle"];
}

-(void) email {
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = (char*)malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
	MFMailComposeViewController *compose = [[MFMailComposeViewController alloc] init];
	compose.mailComposeDelegate = self;
	if ([MFMailComposeViewController canSendMail]){
		NSArray *toRecipients = [NSArray arrayWithObjects:@"s1ris@icloud.com", nil];
		[compose setToRecipients:toRecipients];
		[compose setSubject:[NSString stringWithFormat:@"Helius v1.0-1, %@", platform]];
		[compose setMessageBody:@"" isHTML:0];
		[self presentViewController:compose animated:1 completion:nil];
	}
}

-(void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissViewControllerAnimated:1 completion:nil];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == TAGB && buttonIndex == 1) {
		[self respring];
	}
}

-(void) confirmRespring {
	UIAlertView *avb = [[UIAlertView alloc] initWithTitle:@"Respring" message:[bundle localizedStringForKey:@"RESPRING" value:nil table:nil] delegate:self cancelButtonTitle:[bundle localizedStringForKey:@"NO" value:nil table:nil] otherButtonTitles:[bundle localizedStringForKey:@"YES" value:nil table:nil], nil];
	avb.tag = TAGB;
	[avb show];
}

-(void) respring {
	pid_t pid;
	int status;
	const char *argv[] = {"killall", "backboardd", NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)argv, NULL);
	waitpid(pid, &status, WEXITED);
}

@end
