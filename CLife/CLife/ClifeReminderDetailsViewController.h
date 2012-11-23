//
//  ClifeReminderDetailsViewController.h
//  CLife
//
//  Created by Jordan Gurrieri on 11/23/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ClifeReminderDetailsViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate > {
    UITableView             *m_tbl_reminderDetails;
    
    NSArray                 *m_sectionsArray;
    
    NSNumber                *m_prescriptionInstanceID;
    
    NSDateFormatter         *m_dateAndTimeFormatter;
    
    BOOL                    m_isEditing;
    
    UITextField             *m_tf_dateScheduled;
    UIDatePicker            *m_pv_dateScheduled;
    
    UIView                  *m_v_disabledBackground;
    UITapGestureRecognizer  *m_gestureRecognizer;
    
    NSNumber                *m_dateScheduled;
    
    UIBarButtonItem*        m_doneButton;
    UIBarButtonItem*        m_editButton;
}

@property (nonatomic, retain) IBOutlet  UITableView             *tbl_reminderDetails;

@property (nonatomic, retain)           NSArray                 *sectionsArray;

@property (nonatomic, retain)           NSNumber                *prescriptionInstanceID;

@property (nonatomic, retain)           NSDateFormatter         *dateAndTimeFormatter;

@property (nonatomic, assign)           BOOL                    isEditing;

@property (nonatomic, retain)           UITextField             *tf_dateScheduled;
@property (nonatomic, retain)           UIDatePicker            *pv_dateScheduled;

@property (nonatomic, retain) IBOutlet  UIView                  *v_disabledBackground;
@property (nonatomic, retain)           UITapGestureRecognizer  *gestureRecognizer;

@property (nonatomic, retain)           NSNumber                *dateScheduled;

@property (nonatomic, retain)           UIBarButtonItem         *doneButton;
@property (nonatomic, retain)           UIBarButtonItem         *editButton;

#pragma mark - Static Initializers
+ (ClifeReminderDetailsViewController *)createInstanceForPrescriptionInstanceWithID:(NSNumber *)prescriptionInstanceID;

@end
