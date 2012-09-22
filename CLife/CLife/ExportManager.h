//
//  ExportManager.h
//  CLife
//
//  Created by Jordan Gurrieri on 9/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ExportManager : NSObject < NSFetchedResultsControllerDelegate > {
    
}

@property (nonatomic, retain)           NSFetchedResultsController  *frc_prescriptions;
@property (nonatomic, retain)           NSFetchedResultsController  *frc_prescriptionInstances;

//- (void)exportDataFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (void)exportData;

// Static initializer
+ (ExportManager*) instance;

@end
