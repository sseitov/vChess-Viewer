//
//  MasterLoader.mm
//  vChess
//
//  Created by Sergey Seitov on 10/2/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import "MasterLoader.h"
#import "StorageManager.h"
#import "ChessGame.h"
#import "DeskController.h"
#include <string>

@implementation MasterLoader

@synthesize mMasterEco;
@synthesize mPickerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
		mEcoCodes = [[NSDictionary alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"ecoCodes" withExtension:@"plist"]];

		mGames = [[NSMutableArray alloc] init];
		mSearchBar = [[UITextField alloc] initWithFrame:CGRectMake(0, 7, 60, 30)];
		mSearchBar.borderStyle = UITextBorderStyleRoundedRect;
		mSearchBar.delegate = self;
		mSearchBar.placeholder = @"ECO";
		mSearchBar.textAlignment = UITextAlignmentCenter;
		mSearchBar.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
		mSearchBar.backgroundColor = [UIColor whiteColor];
		mSearchBar.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
		mSearchBar.keyboardType = UIKeyboardTypeASCIICapable;
		mSearchBar.returnKeyType = UIReturnKeySearch;
		mSearchBar.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:mSearchBar];
    }
    return self;
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	if (mMasterEco && [mMasterEco count] > 0) {		
		NSString *eco = [mMasterEco objectAtIndex:0];
		[mGames removeAllObjects];
		[mGames addObjectsFromArray:[[StorageManager sharedStorageManager] gamesWithEco:eco inPackage:self.title]];
		[mGameTable reloadData];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	[mGames removeAllObjects];
	if (mMasterEco.count > 0) {
		NSString *eco = [mMasterEco objectAtIndex:[mPickerView selectedRowInComponent:0]];
		[mGames addObjectsFromArray:[[StorageManager sharedStorageManager] gamesWithEco:eco inPackage:self.title]];
	} else {
		mPickerView.hidden = YES;
		mGameTable.frame = self.view.bounds;
		[mGames addObjectsFromArray:[[StorageManager sharedStorageManager] gamesInPackage:self.title]];
	}
	[mGameTable reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	
    [super viewDidUnload];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	
	return [mMasterEco count];
}

- (UIView *)pickerView:(UIPickerView *)thePickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	
	if (view == nil) {
		view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 32)];
	}
	NSString *code = [mMasterEco objectAtIndex:row];
	NSString *val = [mEcoCodes valueForKey:code];
	
	UILabel *label1 = (UILabel*)[view viewWithTag:1];
	if (label1 == nil) {
		label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 32)];
		label1.backgroundColor = [UIColor clearColor];
		label1.textColor = [UIColor brownColor];
		label1.adjustsFontSizeToFitWidth = true;
		label1.font = [UIFont fontWithName:@"Verdana-Bold" size:16];
		label1.textAlignment = UITextAlignmentLeft;
		label1.tag = 1;
		label1.text = code;
		[view addSubview:label1];
	} else {
		label1.text = code;
	}
	
	if (val) {
		UILabel *label2 = (UILabel*)[view viewWithTag:2];
		if (label2 == nil) {
			label2 = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 240, 32)];
			label2.backgroundColor = [UIColor clearColor];
			label2.textColor = [UIColor blackColor];
			label2.adjustsFontSizeToFitWidth = true;
			label2.font = [UIFont fontWithName:@"Verdana-Bold" size:12];
			label2.textAlignment = UITextAlignmentCenter;
			label2.numberOfLines = 2;
			label2.tag = 2;
			label2.text = val;
			[view addSubview:label2];
		} else {
			label2.text = val;
		}
	} else {
		UILabel *label2 = (UILabel*)[view viewWithTag:2];
		if (label2) {
			[label2 removeFromSuperview];
		}
	}
	
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	
	return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	NSString *eco = [mMasterEco objectAtIndex:row];
	[mGames removeAllObjects];
	[mGames addObjectsFromArray:[[StorageManager sharedStorageManager] gamesWithEco:eco inPackage:self.title]];
	[mGameTable reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[mSearchBar resignFirstResponder];
	std::string searchText([[textField.text uppercaseString] UTF8String]);
	NSInteger index = [mMasterEco indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
		NSString *str = (NSString*)obj;
		std::string text([str UTF8String]);
		if (idx >= [mMasterEco count]) {
			*stop = YES;
		} else {
			if (text >= searchText) {
				*stop = YES;
				return YES;
			}
		}
		return NO;
	}];
	if (index != NSNotFound) {
		textField.text = [mMasterEco objectAtIndex:index];
		[mPickerView selectRow:index inComponent:0 animated:YES];
		[self pickerView:mPickerView didSelectRow:index inComponent:0];
	} else {
		textField.text = @"";
		[mPickerView selectRow:([mMasterEco count] - 1) inComponent:0 animated:YES];
	}
	
	return YES;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [mGames count];
}

- (void)configureCell:(UITableViewCell*)cell forIndex:(int)index {
	
	NSDictionary *game = [mGames objectAtIndex:index];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, 220, 20)];
	label.text = [game valueForKey:@"White"];
	label.textAlignment = UITextAlignmentCenter;
	label.adjustsFontSizeToFitWidth = true;
	[cell.contentView addSubview:label];
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(5, 21, 220, 20)];
	label.text = [game valueForKey:@"Black"];
	label.textAlignment = UITextAlignmentCenter;
	label.adjustsFontSizeToFitWidth = true;
	[cell.contentView addSubview:label];
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(220, 2, 80, 40)];
	label.font = [UIFont boldSystemFontOfSize:16];
	label.text = [game valueForKey:@"Result"];
	label.textAlignment = UITextAlignmentCenter;
	label.adjustsFontSizeToFitWidth = true;
	[cell.contentView addSubview:label];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[self configureCell:cell forIndex:(int)[indexPath indexAtPosition:1]];
	return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ChessGame *game = [mGames objectAtIndex:[indexPath indexAtPosition:1]];
	[[NSNotificationCenter defaultCenter] postNotificationName:LoadGameNotification object:game];
}

@end
