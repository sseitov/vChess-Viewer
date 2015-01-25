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

@interface MasterLoader () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSDictionary	*mEcoCodes;
@property (strong, nonatomic) NSDictionary	*mInfo;
@property (strong, nonatomic) NSMutableArray *mGames;

@property (weak, nonatomic) IBOutlet UITableView *gameTable;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace;

@end

@implementation MasterLoader

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_7_0) {
		_verticalSpace.constant = 44.0;
	} else {
		_gameTable.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
	}
	
	_mEcoCodes = [[NSDictionary alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"ecoCodes" withExtension:@"plist"]];
	_mGames = [[NSMutableArray alloc] init];
	[_pickerView reloadAllComponents];

	if (_mMasterEco && [_mMasterEco count] > 0) {
		NSString *eco = [_mMasterEco objectAtIndex:0];
		[_mGames removeAllObjects];
		[_mGames addObjectsFromArray:[[StorageManager sharedStorageManager] gamesWithEco:eco inPackage:self.title]];
		[_gameTable reloadData];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	[_mGames removeAllObjects];
	if (_mMasterEco.count > 0) {
		NSString *eco = [_mMasterEco objectAtIndex:[_pickerView selectedRowInComponent:0]];
		[_mGames addObjectsFromArray:[[StorageManager sharedStorageManager] gamesWithEco:eco inPackage:self.title]];
	} else {
		_pickerView.hidden = YES;
		_gameTable.frame = self.view.bounds;
		[_mGames addObjectsFromArray:[[StorageManager sharedStorageManager] gamesInPackage:self.title]];
	}
	[_gameTable reloadData];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	
	return [_mMasterEco count];
}

- (UIView *)pickerView:(UIPickerView *)thePickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	
	if (view == nil) {
		view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 32)];
	}
	NSString *code = [_mMasterEco objectAtIndex:row];
	NSString *val = [_mEcoCodes valueForKey:code];
	
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	NSString *eco = [_mMasterEco objectAtIndex:row];
	[_mGames removeAllObjects];
	[_mGames addObjectsFromArray:[[StorageManager sharedStorageManager] gamesWithEco:eco inPackage:self.title]];
	[_gameTable reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[_searchBar resignFirstResponder];
	std::string searchText([[textField.text uppercaseString] UTF8String]);
	NSInteger index = [_mMasterEco indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
		NSString *str = (NSString*)obj;
		std::string text([str UTF8String]);
		if (idx >= [_mMasterEco count]) {
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
		textField.text = [_mMasterEco objectAtIndex:index];
		[_pickerView selectRow:index inComponent:0 animated:YES];
		[self pickerView:_pickerView didSelectRow:index inComponent:0];
	} else {
		textField.text = @"";
		[_pickerView selectRow:([_mMasterEco count] - 1) inComponent:0 animated:YES];
	}
	
	return YES;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [_mGames count];
}

- (void)configureCell:(UITableViewCell*)cell forIndex:(int)index {
	
	NSDictionary *game = [_mGames objectAtIndex:index];
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
	
	ChessGame *game = [_mGames objectAtIndex:[indexPath indexAtPosition:1]];
	[[NSNotificationCenter defaultCenter] postNotificationName:LoadGameNotification object:game];
}

@end
