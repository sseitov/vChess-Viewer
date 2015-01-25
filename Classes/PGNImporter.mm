//
//  PGNImporter.m
//  vChess
//
//  Created by Sergey Seitov on 13.03.13.
//  Copyright (c) 2013 V-Channel. All rights reserved.
//

#import "PGNImporter.h"
#import "ZipArchive.h"
#import "StorageManager.h"

#include "game.h"

@implementation PGNImporter

SYNTHESIZE_SINGLETON_FOR_CLASS(PGNImporter);

- (BOOL)appendGame:(NSString*)package header:(NSString*)header pgn:(NSString*)pgn {
	
	header = [header stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
	
	NSError *err = nil;
	NSString *pattern = @"(?:\\[\\s*(\\w+)\\s*\"([^\"]*)\"\\s*\\]\\s*)+";
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&err];
	if (err) {
		NSLog(@"ERROR: %@", err.localizedDescription);
		return NO;
	}
	NSArray *matches = [regex matchesInString:header options:0 range:NSMakeRange(0, [header length])];
	NSMutableDictionary *headerDict = [NSMutableDictionary dictionary];
	for (NSTextCheckingResult *match in matches) {
		[headerDict setValue:[header substringWithRange:[match rangeAtIndex:2]]
					  forKey:[header substringWithRange:[match rangeAtIndex:1]]];
	}
	
	// remove comments
	pattern = @"(?:\\{([^\\}]*?)\\}\\s*)?";
	regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&err];
	if (err) {
		NSLog(@"ERROR: %@", err.localizedDescription);
		return NO;
	}
	pgn = [regex stringByReplacingMatchesInString:pgn options:0 range:NSMakeRange(0, [pgn length]) withTemplate:@""];
	
	// remove variations
	pattern = @"(?:\\(([^\\)]*?)\\)\\s*)?";
	regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&err];
	if (err) {
		NSLog(@"ERROR: %@", err.localizedDescription);
		return NO;
	}
	pgn = [regex stringByReplacingMatchesInString:pgn options:0 range:NSMakeRange(0, [pgn length]) withTemplate:@""];

	// remove ($5)
	pattern = @"(?:\\$\\d\\s+)?";
	regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&err];
	if (err) {
		NSLog(@"ERROR: %@", err.localizedDescription);
		return NO;
	}
	pgn = [regex stringByReplacingMatchesInString:pgn options:0 range:NSMakeRange(0, [pgn length]) withTemplate:@""];

	// remove rest of variations (5...)
	pattern = @"(?:\\d+\\.{3}\\s+)?";
	regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&err];
	if (err) {
		NSLog(@"ERROR: %@", err.localizedDescription);
		return NO;
	}
	pgn = [regex stringByReplacingMatchesInString:pgn options:0 range:NSMakeRange(0, [pgn length]) withTemplate:@""];

	// get result
	pattern = @"(1\\-0|0\\-1|1/2\\-1/2|\\*)";
	regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&err];
	if (err) {
		NSLog(@"ERROR: %@", err.localizedDescription);
		return NO;
	}
	NSTextCheckingResult *match = [regex firstMatchInString:pgn options:0 range:NSMakeRange(0, [pgn length])];
	NSString *result = @"";
	if (match && match.numberOfRanges > 0) {
		result = [pgn substringWithRange:[match rangeAtIndex:0]];
		pgn = [regex stringByReplacingMatchesInString:pgn options:0 range:NSMakeRange(0, [pgn length]) withTemplate:@""];
	} else {
		return NO;
	}

	// get turns array
	std::vector<std::string> turns;
	if (![StorageManager parseTurns:pgn into:&turns]) {
		return NO;
	}
	
	try {
		// check game
		vchess::Game* game = new vchess::Game(turns, "White", "Black");
		delete game;
		// save into DB
		return [[StorageManager sharedStorageManager] insertGameWithHeader:headerDict turns:pgn intoPackage:package];
	} catch (std::exception& e) {
		NSLog(@"ERROR GAME: %s", e.what());
		return NO;
	}
}

- (int)gamesInFile:(NSString*)path {
	
	NSError *error = nil;
	NSString *gameText = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
	if (error) {
		NSLog(@"ERROR: %@", [error localizedDescription]);
		return nil;
	}
	NSArray *elements = [gameText componentsSeparatedByString:@"\r\n\r\n"];
	if (!elements || elements.count < 2) {
		elements = [gameText componentsSeparatedByString:@"\n\n"];
	}
	return (elements.count / 2);
}

- (int)addPGNFromDir:(NSString*)path toArray:(NSMutableArray*)catalog {
	
	NSFileManager *manager = [NSFileManager defaultManager];
	NSError *error = nil;
	int count = 0;
	NSArray *contents = [manager contentsOfDirectoryAtPath:path error:&error];
	if (error) {
		NSLog(@"ERROR: %@", error.localizedDescription);
		return count;
	}
	for (NSString *file in contents) {
		NSString *filePath = [NSString stringWithFormat:@"%@%@", path, file];
		NSDictionary *attr = [manager attributesOfItemAtPath:filePath error:&error];
		if (error) {
			NSLog(@"ERROR: %@", error.localizedDescription);
			error = nil;
		}
		if ([[attr valueForKey:NSFileType] isEqual:NSFileTypeDirectory]) {
			count += [self addPGNFromDir:[filePath stringByAppendingString:@"/"] toArray:catalog];
		} else if ([[filePath.pathExtension lowercaseString] isEqual:@"pgn"]) {
			[catalog addObject:filePath];
			count += [self gamesInFile:filePath];
		}
	}
	return count;
}

- (BOOL)clearDir {
	
	NSFileManager *manager = [NSFileManager defaultManager];
	NSError *error = nil;
	NSString *path = NSTemporaryDirectory();
	NSArray *contents = [manager contentsOfDirectoryAtPath:path error:&error];
	if (error) {
		NSLog(@"ERROR: %@", error.localizedDescription);
		return NO;
	}
	for (NSString *file in contents) {
		NSString *filePath = [NSString stringWithFormat:@"%@%@", path, file];
		[manager removeItemAtPath:filePath error:&error];
		if (error) {
			NSLog(@"ERROR: %@", error.localizedDescription);
			return NO;
		}
	}
	return YES;
}

- (BOOL)downloadArchive:(NSURL*)url {
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url
													   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
												   timeoutInterval:5];
	[req setHTTPMethod:@"GET"];
	
	NSHTTPURLResponse *response = nil;
	NSError *error = nil;
	NSData *zipData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
	if (error || response.statusCode != 200 || !zipData) {
		NSLog(@"DOWNLOAD ERROR");
		return NO;
	}
	
	NSString *path = [NSTemporaryDirectory() stringByAppendingString:@"archive.zip"];
	if (![zipData writeToFile:path atomically:YES]) {
		NSLog(@"WRITE ERROR");
		return NO;
	}
	
	ZipArchive *archiver = [[ZipArchive alloc] init];
	if ([archiver UnzipOpenFile:path]) {
		if (![archiver UnzipFileTo:NSTemporaryDirectory() overWrite:YES]) {
			[archiver UnzipCloseFile];
			NSLog(@"UNZIP ERROR");
			return NO;
		}
		[archiver UnzipCloseFile];
	} else {
		NSLog(@"UNZIP ERROR");
		return NO;
	}
	
	return YES;
}

- (int)fillImportCatalog:(NSMutableArray*)catalog fromURL:(NSURL*)url {

	[self clearDir];
	[self downloadArchive:url];
	return [self addPGNFromDir:NSTemporaryDirectory() toArray:catalog];
}

@end
