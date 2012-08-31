//
//  ClifePrescriptionDetailsViewController.h
//  CLife
//
//  Created by Jordan Gurrieri on 8/17/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ClifePrescriptionDetailsViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate, UIActionSheetDelegate, UITextViewDelegate > {
    
    UITableView             *m_tbl_prescriptionDetails;
    NSArray                 *m_sectionsArray;
    
    NSNumber                *m_prescriptionID;
    
    UITextField             *m_tf_medicationName;
    
    UITapGestureRecognizer  *m_gestureRecognizer;
    
    UITextField             *m_tf_method;
    UIPickerView            *m_pv_method;
    NSArray                 *m_methodArray;
    
    UITextField             *m_tf_dosageAmount;
    UITextField             *m_tf_dosageUnit;
    UIPickerView            *m_pv_dosageUnit;
    NSArray                 *m_dosageUnitArray;
    
    UITextField             *m_tf_scheduleStartDate;
    UIDatePicker            *m_pv_startDate;
    NSDateFormatter         *m_dateFormatter;
    NSArray                 *m_numberArray;
    UITextField             *m_tf_scheduleAmount;
    UIPickerView            *m_pv_scheduleAmount;
    UITextField             *m_tf_scheduleRepeat;
    UIPickerView            *m_pv_scheduleRepeat;
    UITextField             *m_tf_scheduleDuration;
    UIPickerView            *m_pv_scheduleDuration;
    UITextField             *m_tf_scheduleReminder;
    UIPickerView            *m_pv_scheduleReminder;
    
    UITextView              *m_tv_reason;
    
    UIView                  *m_v_disabledBackground;
    
    BOOL                    m_isEditing;
    
    NSString                *m_medicationName;
    NSNumber                *m_scheduleStartDate;
    NSString                *m_scheduleAmount;
    NSString                *m_scheduleRepeat;
    NSString                *m_scheduleDuration;
    NSString                *m_scheduleReminder;
    NSString                *m_method;
    NSString                *m_dosageAmount;
    NSString                *m_dosageUnit;
    NSString                *m_reason;
    
}

@property (nonatomic, retain) IBOutlet  UITableView             *tbl_prescriptionDetails;
@property (nonatomic, retain)           NSArray                 *sectionsArray;

@property (nonatomic, retain)           NSNumber                *prescriptionID;

@property (nonatomic, retain)           UITextField             *tf_medicationName;

@property (nonatomic, retain)           UITapGestureRecognizer  *gestureRecognizer;

@property (nonatomic, retain)           UITextField             *tf_method;
@property (nonatomic, retain)           UIPickerView            *pv_method;
@property (nonatomic, retain)           NSArray                 *methodArray;

@property (nonatomic, retain)           UITextField             *tf_dosageAmount;
@property (nonatomic, retain)           UITextField             *tf_dosageUnit;
@property (nonatomic, retain)           UIPickerView            *pv_dosageUnit;
@property (nonatomic, retain)           NSArray                 *dosageUnitArray;

@property (nonatomic, retain)           UITextField             *tf_scheduleStartDate;
@property (nonatomic, retain)           UIDatePicker            *pv_startDate;
@property (nonatomic, retain)           NSDateFormatter         *dateFormatter;
@property (nonatomic, retain)           NSArray                 *numberArray;
@property (nonatomic, retain)           UITextField             *tf_scheduleAmount;
@property (nonatomic, retain)           UIPickerView            *pv_scheduleAmount;
@property (nonatomic, retain)           UITextField             *tf_scheduleRepeat;
@property (nonatomic, retain)           UIPickerView            *pv_scheduleRepeat;
@property (nonatomic, retain)           UITextField             *tf_scheduleDuration;
@property (nonatomic, retain)           UIPickerView            *pv_scheduleDuration;
@property (nonatomic, retain)           UITextField             *tf_scheduleReminder;
@property (nonatomic, retain)           UIPickerView            *pv_scheduleReminder;

@property (nonatomic, retain)           UITextView              *tv_reason;

@property (nonatomic, retain) IBOutlet  UIView                  *v_disabledBackground;

@property (nonatomic, assign)           BOOL                    isEditing;

@property (nonatomic, retain)           NSString                *medicationName;
@property (nonatomic, retain)           NSNumber                *sheduleStartDate;
@property (nonatomic, retain)           NSString                *method;
@property (nonatomic, retain)           NSString                *dosageAmount;
@property (nonatomic, retain)           NSString                *dosageUnit;
@property (nonatomic, retain)           NSString                *reason;

#pragma mark - Static Initializers
+ (ClifePrescriptionDetailsViewController *)createInstanceForPrescriptionWithID:(NSNumber *)prescriptionID;

@end
