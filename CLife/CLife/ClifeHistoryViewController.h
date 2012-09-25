//
//  ClifeHistoryViewController.h
//  CLife
//
//  Created by Jordan Gurrieri on 8/16/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BaseViewController.h"
#import "ExportManager.h"
#import "ClifeFilterViewController.h"

@interface ClifeHistoryViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, ExportManagerDelegate, UIAlertViewDelegate, ClifeFilterViewControllerDelegate > {
    
    UITableView             *m_tbl_history;
    
    UIAlertView             *m_av_export;
    
    NSMutableArray          *m_filteredPrescriptions;
    NSDate                  *m_filterDateStart;
    NSDate                  *m_filterDateEnd;
    NSString                *m_periodTextLabel;
    int                     m_selectedPeriodIndex;
    
    BOOL                    m_isFiltered;
}

@property (nonatomic, retain)           NSFetchedResultsController  *frc_prescriptionInstances;

@property (nonatomic, retain) IBOutlet  UITableView                 *tbl_history;

@property (nonatomic, retain)           UIAlertView                 *av_export;

@property (nonatomic, retain)           NSMutableArray              *filteredPrescriptions;
@property (nonatomic, retain)           NSDate                      *filterDateStart;
@property (nonatomic, retain)           NSDate                      *filterDateEnd;
@property (nonatomic, retain)           NSString                    *periodTextLabel;
@property (nonatomic, assign)           int                         selectedPeriodIndex;

@property (nonatomic, assign)           BOOL                        isFiltered;

#pragma mark - Static Initializers
+ (ClifeHistoryViewController *)createInstance;

@end
