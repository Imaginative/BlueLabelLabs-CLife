//
//  ClifeFilterViewController.h
//  CLife
//
//  Created by Jordan Gurrieri on 9/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClifeFilterPrescriptionsViewController.h"

@protocol ClifeFilterViewControllerDelegate <NSObject>

@end

@interface ClifeFilterViewController : UITableViewController < ClifeFilterPrescriptionsViewControllerDelegate > {
    id<ClifeFilterViewControllerDelegate> m_delegate;
    
    NSArray                 *m_sectionsArray;
    NSMutableArray          *m_filteredPrescriptions;
}

@property (nonatomic, assign) id<ClifeFilterViewControllerDelegate>  delegate;

@property (nonatomic, retain)           NSArray                 *sectionsArray;
@property (nonatomic, retain)           NSMutableArray          *filteredPrescriptions;

+ (ClifeFilterViewController *)createInstance;

@end
