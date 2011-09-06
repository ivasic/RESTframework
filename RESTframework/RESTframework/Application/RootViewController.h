//
//  RootViewController.h
//  RESTframework
//
//  Created by ivan on 5.4.11..
//  Copyright 2011 MobileWasp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController <UISearchBarDelegate, UITextFieldDelegate> {
	
	IBOutlet UISearchBar *sbar;
	UIButton *testEchoButton;
	UITextField *textField;
	UITextView *responseTextField;
	UIScrollView *scrollView;
}
@property (nonatomic, retain) UISearchBar *sbar;
@property (nonatomic, retain) NSString *searchText;
@property (nonatomic, retain) IBOutlet UIButton *testEchoButton;
@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) IBOutlet UITextView *responseTextField;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction)testEchoButtonClicked:(id)sender;
@end
