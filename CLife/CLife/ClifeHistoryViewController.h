//
//  ClifeHistoryViewController.h
//  CLife
//
//  Created by Jordan Gurrieri on 8/16/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ClifeHistoryViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate > {
    
    UITableView             *m_tbl_history;
}

@property (nonatomic, retain)           NSFetchedResultsController  *frc_prescriptionInstances;

@property (nonatomic, retain) IBOutlet  UITableView                 *tbl_history;

#pragma mark - Static Initializers
+ (ClifeHistoryViewController *)createInstance;

@end
