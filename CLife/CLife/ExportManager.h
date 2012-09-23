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

@required

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error;

@end

@interface ExportManager : NSObject < NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate > {
    id<ExportManagerDelegate> m_delegate;
    
    NSDateFormatter         *m_dateAndTimeFormatter;
    
    NSArray                 *m_filteredPrescriptions;
}

@property (nonatomic, assign)           id<ExportManagerDelegate> delegate;

@property (nonatomic, retain)           NSFetchedResultsController  *frc_prescriptions;
@property (nonatomic, retain)           NSFetchedResultsController  *frc_prescriptionInstances;

@property (nonatomic, retain)           NSDateFormatter             *dateAndTimeFormatter;

@property (nonatomic, retain)           NSArray                     *filteredPrescriptions;

//- (void)exportDataFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (void)exportData;

// Static initializer
+ (ExportManager *) instanceWithDelegate:(id)delegate forPrescriptions:(NSArray *)prescriptions;

@end
