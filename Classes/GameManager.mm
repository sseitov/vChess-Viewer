//
//  GameManager.m
//  vChess
//
//  Created by Sergey Seitov on 6/29/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import "GameManager.h"
#import "StorageManager.h"
#import "MasterLoader.h"

@implementation GameManager

@synthesize masterPackages;

#pragma mark View lifecycle

- (id)init {
	
	if (self == [super initWithStyle:UITableViewStyleGrouped]) {
		self.title = @"Archive";
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
		[self updateRightButtons:NO];
		self.masterPackages = [[NSArray alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"packages" withExtension:@"plist"]];
	}
	return self;
}

- (void)updateRightButtons:(BOOL)bEdit {

	UIBarButtonItem *d = [[UIBarButtonItem alloc] initWithTitle:@"Download" style:UIBarButtonItemStyleBordered target:self action:@selector(loadArchive)];
	if (bEdit) {
		UIBarButtonItem *e = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editTable)];
		[self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:e, nil] animated:YES];
	} else {
		UIBarButtonItem *e = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTable)];
		if ([StorageManager sharedStorageManager].userPackages.count > 0) {
			[self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:d, e, nil] animated:YES];
		} else {
			[self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:d, nil] animated:YES];
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)cancel {

	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	return section ? @"Master's Games" : @"Downloaded Games";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return section ? self.masterPackages.count : [StorageManager sharedStorageManager].userPackages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString* CellIdentifier = @"PackageCellIdentifier";
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	cell.textLabel.textColor = [UIColor blackColor];
	cell.textLabel.text = indexPath.section ? [self.masterPackages objectAtIndex:indexPath.row] : [[StorageManager sharedStorageManager].userPackages objectAtIndex:indexPath.row];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	return cell;
}


#pragma mark Table view delegate

- (void)editTable {
	
	if(self.editing) {
		[self setEditing:NO animated:NO];
	} else {
		[self setEditing:YES animated:YES];
	}
	[self.tableView reloadData];
	[self updateRightButtons:self.editing];
}

- (void)finishDownload:(NSNumber*)count {
	
	if ([count intValue] <= 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
															message:@"Error load archive"
														   delegate:nil
												  cancelButtonTitle:@"Ok"
												  otherButtonTitles:nil];
		[alertView show];
	}
	[self.tableView reloadData];
}

- (void)loadArchive
{
	ChessComLoader *loader = [[ChessComLoader alloc] init];
	loader.delegate = self;
	[self.navigationController pushViewController:loader animated:YES];
}

- (void)loaderDidFinish:(UIViewController*)loader {
	
	[self.tableView reloadData];
	[self updateRightButtons:NO];
	[self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {

	return (section ? 80 : 0);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *package = indexPath.section ? [self.masterPackages objectAtIndex:indexPath.row] : [[StorageManager sharedStorageManager].userPackages objectAtIndex:indexPath.row];
	MasterLoader *manager = [[MasterLoader alloc] initWithNibName:@"MasterLoader" bundle:nil];;
	manager.title = package;
	manager.mMasterEco = [[StorageManager sharedStorageManager] ecoInPackage:package];
	[manager.mPickerView reloadAllComponents];
	[self.navigationController pushViewController:manager animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.editing && indexPath.section == 0) {
		return UITableViewCellEditingStyleDelete;
	} else {
		return UITableViewCellEditingStyleNone;
	}
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSArray *packages = [[StorageManager sharedStorageManager] userPackages];
		NSString *package = [packages objectAtIndex:indexPath.row];
		[[StorageManager sharedStorageManager] removePackage:package];
		[aTableView reloadData];
    }
}

@end

