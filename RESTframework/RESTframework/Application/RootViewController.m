//
//  RootViewController.m
//  RESTframework
//
//  Created by ivan on 5.4.11..
//  Copyright 2011 MobileWasp. All rights reserved.
//

#import "RootViewController.h"
#import "RFService.h"
#import "RFRequest.h"
#import "RFResponse.h"

#define flikrAPIKey @"ENTER_YOUR_FLICKR_KEY"
#define flikrLink @"http://api.flickr.com/"

@implementation RootViewController
@synthesize testEchoButton;
@synthesize textField;
@synthesize responseTextField;
@synthesize scrollView;
@synthesize sbar, searchText;

- (void)searchImages {
	RFRequest *r = [[RFRequest requestWithURL:[NSURL URLWithString:flikrLink] type:RFRequestMethodGet resourcePathComponents:@"services", @"rest", @"", nil] retain];
	
	[r addParam:@"flickr.photos.search" forKey:@"method"];
	[r addParam:flikrAPIKey forKey:@"api_key"];
	[r addParam:sbar.text forKey:@"tags"];
	[r addParam:@"25" forKey:@"per_page"];
	[r addParam:@"json" forKey:@"format"];
	[r addParam:@"1" forKey:@"nojsoncallback"];
	
	[RFService execRequest:r completion:^(RFResponse *response){
		NSLog(@"%@", r);
		self.responseTextField.text = response.stringValue;
	}];
    [r release];
}

- (void)moveViewForKeyboard:(NSNotification *)info {
	CGRect t = [[info.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	t = CGRectMake(0, 0, 320, self.scrollView.frame.size.height - t.size.height);
	self.scrollView.frame = t;
	
	if ([self.textField isFirstResponder]) {
		[self.scrollView scrollRectToVisible:CGRectMake(self.testEchoButton.frame.origin.x, self.testEchoButton.frame.origin.y, self.testEchoButton.frame.size.width, self.testEchoButton.frame.size.height + 20) animated:YES];
	}
}

- (void)removeViewForKeyboard:(NSNotification *)info {
	self.scrollView.frame = self.view.bounds;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = NSLocalizedString(@"", @"");
	self.sbar.delegate = self;
	self.textField.delegate = self;
	self.scrollView.contentSize = self.scrollView.frame.size;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(moveViewForKeyboard:) 
												 name:UIKeyboardDidShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(removeViewForKeyboard:) 
												 name:UIKeyboardDidHideNotification
											   object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	self.sbar = nil;
	self.searchText = nil;
	[self setTestEchoButton:nil];
	[self setResponseTextField:nil];
	[self setTextField:nil];
	[self setScrollView:nil];
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
	self.sbar = nil;
	self.searchText = nil;
	[testEchoButton release];
	[responseTextField release];
	[textField release];
	[scrollView release];
    [super dealloc];
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	self.searchText = self.sbar.text;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.sbar setShowsCancelButton:NO animated:YES];
	[self.sbar resignFirstResponder];
	
	[self searchImages];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.sbar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	self.searchText = self.sbar.text;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self.sbar setShowsCancelButton:NO animated:YES];
	[self.sbar resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)tField {
	[self.textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)tField {
	self.searchText = self.textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.textField resignFirstResponder];
	return NO;
}

- (IBAction)testEchoButtonClicked:(id)sender {
	[self.textField resignFirstResponder];
	RFRequest *r = [[RFRequest requestWithURL:[NSURL URLWithString:flikrLink] type:RFRequestMethodPost resourcePathComponents:@"services", @"rest", @"", nil] retain];

	[r addParam:@"flickr.test.echo" forKey:@"method"];
	[r addParam:flikrAPIKey forKey:@"api_key"];
	[r addParam:@"json" forKey:@"format"];
	[r addParam:@"1" forKey:@"nojsoncallback"];
	[r addParam:self.textField.text forKey:@"test"];
	
	[RFService execRequest:r completion:^(RFResponse *response){
		NSLog(@"%@", r);
		self.responseTextField.text = response.stringValue;
	}];
    [r release];
}

@end
