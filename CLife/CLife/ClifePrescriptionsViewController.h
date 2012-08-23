//
//  ClifePrescriptionsViewController.h
//  CLife
//
//  Created by Jasjeet Gill on 8/9/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ClifePrescriptionsViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate > {
    
    UITableView             *m_tbl_prescriptions;
    
}

@property (nonatomic, retain)           NSFetchedResultsController  *frc_prescriptions;

@property (nonatomic, retain) IBOutlet  UITableView                 *tbl_prescriptions;

#pragma mark - Static Initializers
+ (ClifePrescriptionsViewController *)createInstance;

@end
