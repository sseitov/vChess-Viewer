//
//  DBConverter.m
//  DBConverter
//
//  Created by Sergey Seitov on 7/1/10.
//  Copyright 2010 Progorod Ltd. All rights reserved.
//

#import "DBConverter.h"
#include <sqlite3.h>
#import "RegexKitLite.h"

@implementation DBConverter

- (void)awakeFromNib {
	
	[progress setUsesThreadedAnimation:YES];
}

- (sqlite3*)createDatabase:(NSString*)dbPath {
	
	NSError *error;
	[[NSFileManager defaultManager] removeItemAtPath:dbPath error:&error];
	BOOL success = [[NSFileManager defaultManager] createFileAtPath:dbPath contents:nil attributes:nil];
	if (!success) {
		return nil;
	}
	
	sqlite3 *db = NULL;
	if (sqlite3_open([dbPath UTF8String], &db) != SQLITE_OK) {
		sqlite3_close(db);
		return nil;
	}
	
	sqlite3_stmt *pStmt;
	NSString *sql = @"\
	CREATE TABLE games (id integer PRIMARY KEY AUTOINCREMENT, \
	Event varchar(64), \
	Site varchar(64), \
	Date varchar(16), \
	Round varchar(4), \
	White varchar(64), \
	Black varchar(64), \
	Result varchar(8), \
	WhiteElo varchar(8), \
	BlackElo varchar(8), \
	ECO varchar(8), \
	PGN text)";
	
	if(sqlite3_prepare(db, [sql UTF8String], -1, &pStmt, NULL) != SQLITE_OK) {
		NSLog(@"SQL %@ Error: '%s'", sql, sqlite3_errmsg(db));
		sqlite3_finalize(pStmt);
		sqlite3_close(db);
		return nil;
	}
	sqlite3_step(pStmt);
	sqlite3_finalize(pStmt);
	
	return db;
}

- (BOOL)insertGame:(NSDictionary*)header pgn:(NSString*)pgn intoDB:(sqlite3*)db {
	
	sqlite3_stmt *pStmt;
	NSString *sql = @"insert into games(Event, Site, Date, Round, White, Black, Result, WhiteElo, BlackElo, ECO, PGN) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
	if(sqlite3_prepare(db, [sql UTF8String], -1, &pStmt, NULL) != SQLITE_OK) {
		NSLog(@"SQL %@ Error: '%s'", sql, sqlite3_errmsg(db));
		sqlite3_finalize(pStmt);
		return NO;
	}
	
	NSString *event = [header valueForKey:@"Event"];
	if (!event) event = @"";
	int result = sqlite3_bind_text(pStmt, 1, [event UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 1");
	
	NSString *site = [header valueForKey:@"Site"];
	if (!site) site = @"";
	result = sqlite3_bind_text(pStmt, 2, [site UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 2");
	
	NSString *date = [header valueForKey:@"Date"];
	if (!date) date = @"";
	result = sqlite3_bind_text(pStmt, 3, [date UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 3");
	
	NSString *round = [header valueForKey:@"Round"];
	if (!round) round = @"";
	result = sqlite3_bind_text(pStmt, 4, [round UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 4");
	
	NSString *white = [header valueForKey:@"White"];
	if (!white) white = @"";
	result = sqlite3_bind_text(pStmt, 5, [white UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 5");
	
	NSString *black = [header valueForKey:@"Black"];
	if (!black) black = @"";
	result = sqlite3_bind_text(pStmt, 6, [black UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 6");
	
	NSString *Result = [header valueForKey:@"Result"];
	if (!Result) Result = @"";
	result = sqlite3_bind_text(pStmt, 7, [Result UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 7");
	
	NSString *WhiteElo = [header valueForKey:@"WhiteElo"];
	if (!WhiteElo) WhiteElo = @"";
	result = sqlite3_bind_text(pStmt, 8, [WhiteElo UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 8");
	
	NSString *BlackElo = [header valueForKey:@"BlackElo"];
	if (!BlackElo) BlackElo = @"";
	result = sqlite3_bind_text(pStmt, 9, [BlackElo UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 9");
	
	NSString *ECO = [header valueForKey:@"ECO"];
	if (!ECO) ECO = @"";
	result = sqlite3_bind_text(pStmt, 10, [ECO UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 10");
	
	result = sqlite3_bind_text(pStmt, 11, [pgn UTF8String], -1, SQLITE_TRANSIENT);
	if(result != SQLITE_OK)
		NSLog(@"Not OK in bind column 11");
	
	if(sqlite3_step(pStmt) != SQLITE_DONE) {
		NSLog(@"SQL %@ Error: '%s'", sql, sqlite3_errmsg(db));
		sqlite3_finalize(pStmt);
		return NO;
	} else {
		sqlite3_finalize(pStmt);
		return YES;
	}
}
- (BOOL)appendGame:(NSString*)header pgn:(NSString*)pgn intoDB:(sqlite3*)db {
	
	NSArray *lines = [header componentsSeparatedByString:@"\r\n"];
	NSMutableDictionary *gameHeader = [NSMutableDictionary dictionary];
	for (int i=0; i < [lines count]; i++) {
		NSRange range = [[lines objectAtIndex:i] rangeOfString:@" "];
		if (range.location != NSNotFound) {
			NSString *key = [[[lines objectAtIndex:i] substringToIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]\""]];
			NSString *val = [[[lines objectAtIndex:i] substringFromIndex:range.location+1] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]\""]];
			[gameHeader setValue:val forKey:key];
		}
	}
	if ([gameHeader count] == 0) {
		NSLog(@"ERROR header: %@", header);
		return NO;
	}
	
	pgn = [pgn stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
	NSString *regexString  = @"\\d+\\.";
	NSArray  *splitArray   = [pgn componentsSeparatedByRegex:regexString];
	if ([splitArray count] < 2) {
		NSLog(@"ERROR header: %@\n pgn: %@", header, pgn);
		return NO;
	}
	NSString *gamePGN = [splitArray objectAtIndex:1];
	for (int i=2; i<[splitArray count]; i++) {
		gamePGN = [gamePGN stringByAppendingString:[[splitArray objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]]];
	}
	return [self insertGame:gameHeader pgn:gamePGN intoDB:db];
}

- (IBAction)openPGN:(id)sender {
	
	NSOpenPanel *op = [NSOpenPanel openPanel];
	[op setAllowsMultipleSelection:YES];
	[op setAllowedFileTypes:[NSArray arrayWithObject:@"pgn"]];
    if ([op runModal] != NSOKButton)
		return;
	
	[progress startAnimation:self];
	
	NSArray *urls = [op URLs];
	for (int i=0; i<[urls count]; i++) {
		NSString *fileName = [[urls objectAtIndex:i] path];		
		NSString *dbName = [fileName stringByReplacingOccurrencesOfString:@".pgn" withString:@".sqlite"];
		sqlite3* db = [self createDatabase:dbName];
		if (!db) {
			NSLog(@"Error create database %@", dbName);
			break;
		}
		NSError *error = NULL;
		NSString *gameText = [NSString stringWithContentsOfFile:fileName encoding:NSASCIIStringEncoding error:&error];
		if (error) {
			NSLog(@"ERROR: %@", [error localizedDescription]);
			break;
		}
		NSString *separator = @"\r\n\r\n";
		NSArray *elements = [gameText componentsSeparatedByString:separator];
		BOOL success;
		for (int i=0; i < [elements count]; i++) {
			success = [self appendGame:[elements objectAtIndex:i] pgn:[elements objectAtIndex:(i+1)] intoDB:db];
			i++;
			if (!success) {
				break;
			}
		}
		
		sqlite3_close(db);
		if (!success) {
			NSLog(@"ERROR: %@", fileName);
			break;
		} else {
			NSLog(@"%@ SUCCESS", fileName);
		}
	}

	[progress stopAnimation:self];
}

@end
