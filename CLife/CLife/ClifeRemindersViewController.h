//
//  ClifeRemindersViewController.h
//  CLife
//
//  Created by Jordan Gurrieri on 9/13/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ClifeRemindersViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate > {
    
    UITableView             *m_tbl_history;
}

@property (nonatomic, retain)           NSFetchedResultsController  *frc_prescriptionInstances;

@property (nonatomic, retain) IBOutlet  UITableView                 *tbl_reminders;

#pragma mark - Static Initializers
+ (ClifeRemindersViewController *)createInstance;

@end
