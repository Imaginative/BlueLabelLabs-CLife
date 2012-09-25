//
//  ClifeFilterViewController.h
//  CLife
//
//  Created by Jordan Gurrieri on 9/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClifeFilterPrescriptionsViewController.h"
#import "ClifeFilterPeriodViewController.h"

@protocol ClifeFilterViewControllerDelegate <NSObject>

@end

@interface ClifeFilterViewController : UITableViewController < ClifeFilterPrescriptionsViewControllerDelegate, ClifeFilterPeriodViewControllerDelegate > {
    id<ClifeFilterViewControllerDelegate> m_delegate;
    
    NSArray                 *m_sectionsArray;
    
    NSDateFormatter         *m_dateFormatter;
    
    NSMutableArray          *m_filteredPrescriptions;
    NSDate                  *m_filterDateStart;
    NSDate                  *m_filterDateEnd;
    NSString                *m_periodTextLabel;
    int                     m_selectedPeriodIndex;
}

@property (nonatomic, assign) id<ClifeFilterViewControllerDelegate> delegate;

@property (nonatomic, retain)           NSArray                     *sectionsArray;

@property (nonatomic, retain)           NSDateFormatter             *dateFormatter;

@property (nonatomic, retain)           NSMutableArray              *filteredPrescriptions;
@property (nonatomic, retain)           NSDate                      *filterDateStart;
@property (nonatomic, retain)           NSDate                      *filterDateEnd;
@property (nonatomic, retain)           NSString                    *periodTextLabel;
@property (nonatomic, assign)           int                         selectedPeriodIndex;

- (void)updatePeriodTextLabel;

+ (ClifeFilterViewController *)createInstance;

@end
