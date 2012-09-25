//
//  ClifeFilterPeriodViewController.h
//  CLife
//
//  Created by Jordan Gurrieri on 9/24/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClifeFilterPeriodViewControllerDelegate <NSObject>

@end

@interface ClifeFilterPeriodViewController : UITableViewController < UITextFieldDelegate > {
    id<ClifeFilterPeriodViewControllerDelegate> m_delegate;
    
    NSArray                 *m_sectionsArray;
    NSArray                 *m_periodArray;
    
    NSDateFormatter         *m_dateFormatter;
    
    UITextField             *m_tf_dateStart;
    UIDatePicker            *m_pv_dateStart;
    
    UITextField             *m_tf_dateEnd;
    UIDatePicker            *m_pv_dateEnd;
    
    UITapGestureRecognizer  *m_gestureRecognizer;
    UIView                  *m_v_disabledBackground;
}

@property (nonatomic, assign) id<ClifeFilterPeriodViewControllerDelegate>  delegate;

@property (nonatomic, retain)           NSArray                 *sectionsArray;
@property (nonatomic, retain)           NSArray                 *periodArray;

@property (nonatomic, retain)           NSDateFormatter         *dateFormatter;

@property (nonatomic, retain)           UITextField             *tf_dateStart;
@property (nonatomic, retain)           UIDatePicker            *pv_dateStart;

@property (nonatomic, retain)           UITextField             *tf_dateEnd;
@property (nonatomic, retain)           UIDatePicker            *pv_dateEnd;

@property (nonatomic, retain)           UITapGestureRecognizer  *gestureRecognizer;
@property (nonatomic, retain)           UIView                  *v_disabledBackground;

+ (ClifeFilterPeriodViewController *)createInstance;

@end
