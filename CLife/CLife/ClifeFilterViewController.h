//
//  ClifeFilterViewController.h
//  CLife
//
//  Created by Jordan Gurrieri on 9/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClifeFilterViewController : UITableViewController {
    NSArray                 *m_sectionsArray;
}

@property (nonatomic, retain)           NSArray                 *sectionsArray;

+ (ClifeFilterViewController *)createInstance;

@end
