//
//  BackupToolDatabase.m
//  BackupToolStatus
//
//  Created by John Jones on 1/3/16.
//  Copyright © 2016 John Jones. All rights reserved.
//

#import "BackupToolDatabase.h"
#import <sqlite3.h>

@interface BackupToolDatabase() {
    sqlite3* _database;
}

@end

@implementation BackupToolDatabase

- (id)initWithDatabasePath:(NSString*)pathToDB {
    if (self = [super init]) {
        if (sqlite3_open([pathToDB UTF8String], &_database) != SQLITE_OK) {
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    sqlite3_close(_database);
}

- (NSInteger)totalFiles {
    NSInteger count = 0;
    NSString *query = @"SELECT count(*) as c FROM File";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    return count;
}

- (NSInteger)unBackedUpFiles {
    NSInteger count = 0;
    NSString *query = @"SELECT count(*) as c FROM File WHERE modified >= backedup";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    return count;
}

- (float)percentBackedUp {
    NSInteger total = self.totalFiles;
    return (float)(total - self.unBackedUpFiles) / (float)total;
}

@end
