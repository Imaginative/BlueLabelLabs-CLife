//
//  ExportManager.h
//  CLife
//
//  Created by Jordan Gurrieri on 9/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>

@protocol ExportManagerDelegate < NSObject >

@end

@interface ExportManager : NSObject < NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate > {
    id<ExportManagerDelegate> m_delegate;
    
    NSDateFormatter     *m_dateAndTimeFormatter;
}

@property (nonatomic, assign)           id<ExportManagerDelegate> delegate;

@property (nonatomic, retain)           NSFetchedResultsController  *frc_prescriptions;
@property (nonatomic, retain)           NSFetchedResultsController  *frc_prescriptionInstances;

@property (nonatomic, retain)           NSDateFormatter             *dateAndTimeFormatter;

//- (void)exportDataFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (void)exportData;

// Static initializer
+ (ExportManager*) instance;

@end
