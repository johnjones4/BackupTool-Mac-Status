//
//  BackupToolDatabase.h
//  BackupToolStatus
//
//  Created by John Jones on 1/3/16.
//  Copyright © 2016 John Jones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackupToolDatabase : NSObject

@property (nonatomic,readonly) float percentBackedUp;
@property (nonatomic,readonly) NSInteger totalFiles;
@property (nonatomic,readonly) NSInteger unBackedUpFiles;

- (id)initWithDatabasePath:(NSString*)pathToDB;

@end
