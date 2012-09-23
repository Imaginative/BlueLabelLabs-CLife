//
//  ClifeFilterPrescriptionsViewController.h
//  CLife
//
//  Created by Jordan Gurrieri on 9/23/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol ClifeFilterPrescriptionsViewControllerDelegate <NSObject>

@end

@interface ClifeFilterPrescriptionsViewController : BaseViewController < NSFetchedResultsControllerDelegate > {
    id<ClifeFilterPrescriptionsViewControllerDelegate> m_delegate;
    
    BOOL                    m_allSelected;
}

@property (nonatomic, assign) id<ClifeFilterPrescriptionsViewControllerDelegate>  delegate;

@property (nonatomic, retain)           NSFetchedResultsController  *frc_prescriptions;

@property (nonatomic, assign)           BOOL                        allSelected;

+ (ClifeFilterPrescriptionsViewController *)createInstance;

@end
