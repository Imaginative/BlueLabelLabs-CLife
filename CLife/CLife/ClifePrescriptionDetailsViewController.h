//
//  ClifePrescriptionDetailsViewController.h
//  CLife
//
//  Created by Jordan Gurrieri on 8/17/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UIPromptAlertView.h"
#import "ExportManager.h"

@interface ClifePrescriptionDetailsViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate, UIActionSheetDelegate, UITextViewDelegate, ExportManagerDelegate, UIProgressHUDViewDelegate > {
    
    UITableView             *m_tbl_prescriptionDetails;
    
    UIAlertView             *m_av_edit;
    UIPromptAlertView       *m_av_delete;
    
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
    
    NSDateFormatter         *m_dateOnlyFormatter;
    NSDateFormatter         *m_dateAndTimeFormatter;
    
    UITextField             *m_tf_scheduleStartDate;
    UIDatePicker            *m_pv_scheduleStartDate;
    
    NSArray                 *m_scheduleAmountArray;
    UITextField             *m_tf_scheduleAmount;
    UIPickerView            *m_pv_scheduleAmount;
    
    NSArray                 *m_schedulePeriodSingularArray;
    NSArray                 *m_schedulePeriodPluralArray;
    
    UITextField             *m_tf_scheduleRepeat;
    UIPickerView            *m_pv_scheduleRepeat;
    
    UITextField             *m_tf_scheduleDuration;
    UIPickerView            *m_pv_scheduleDuration;
    
    UITextField             *m_tf_scheduleEndDate;
    UIDatePicker            *m_pv_scheduleEndDate;
    
    UITextView              *m_tv_reason;
    
    UIView                  *m_v_disabledBackground;
    
    BOOL                    m_didRequestEdit;
    BOOL                    m_didRequestDelete;
    BOOL                    m_isEditing;
    BOOL                    m_occurancesRowIsShown;
    
    NSString                *m_medicationName;
    NSNumber                *m_method;
    NSNumber                *m_dosageAmount;
    NSString                *m_dosageUnit;
    NSString                *m_reason;
    
    NSNumber                *m_scheduleStartDate;
    NSNumber                *m_scheduleAmount;
    NSNumber                *m_scheduleRepeatNumber;
    NSNumber                *m_scheduleRepeatPeriod;
    NSNumber                *m_scheduleOccurenceNumber;
    NSNumber                *m_scheduleEndDate;
    
}

@property (nonatomic, retain) IBOutlet  UITableView             *tbl_prescriptionDetails;

@property (nonatomic, retain)           UIAlertView             *av_edit;
@property (nonatomic, retain)           UIPromptAlertView       *av_delete;

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

@property (nonatomic, retain)           NSDateFormatter         *dateOnlyFormatter;
@property (nonatomic, retain)           NSDateFormatter         *dateAndTimeFormatter;

@property (nonatomic, retain)           UITextField             *tf_scheduleStartDate;
@property (nonatomic, retain)           UIDatePicker            *pv_scheduleStartDate;

@property (nonatomic, retain)           UITextField             *tf_scheduleAmount;
@property (nonatomic, retain)           NSArray                 *scheduleAmountArray;
@property (nonatomic, retain)           UIPickerView            *pv_scheduleAmount;

@property (nonatomic, retain)           NSArray                 *schedulePeriodSingularArray;
@property (nonatomic, retain)           NSArray                 *schedulePeriodPluralArray;

@property (nonatomic, retain)           UITextField             *tf_scheduleRepeat;
@property (nonatomic, retain)           UIPickerView            *pv_scheduleRepeat;

@property (nonatomic, retain)           UITextField             *tf_scheduleOccurences;
@property (nonatomic, retain)           UIPickerView            *pv_scheduleOccurences;

@property (nonatomic, retain)           UITextField             *tf_scheduleEndDate;
@property (nonatomic, retain)           UIDatePicker            *pv_scheduleEndDate;

@property (nonatomic, retain)           UITextView              *tv_reason;

@property (nonatomic, retain) IBOutlet  UIView                  *v_disabledBackground;

@property (nonatomic, assign)           BOOL                    didRequestEdit;
@property (nonatomic, assign)           BOOL                    didRequestDelete;
@property (nonatomic, assign)           BOOL                    isEditing;
@property (nonatomic, assign)           BOOL                    occurancesRowIsShown;

@property (nonatomic, retain)           NSString                *medicationName;
@property (nonatomic, retain)           NSNumber                *method;
@property (nonatomic, retain)           NSNumber                *dosageAmount;
@property (nonatomic, retain)           NSString                *dosageUnit;
@property (nonatomic, retain)           NSString                *reason;

@property (nonatomic, retain)           NSNumber                *scheduleStartDate;
@property (nonatomic, retain)           NSNumber                *scheduleAmount;
@property (nonatomic, retain)           NSNumber                *scheduleRepeatNumber;
@property (nonatomic, retain)           NSNumber                *scheduleRepeatPeriod;
@property (nonatomic, retain)           NSNumber                *scheduleOccurenceNumber;
@property (nonatomic, retain)           NSNumber                *scheduleEndDate;

#pragma mark - Static Initializers
+ (ClifePrescriptionDetailsViewController *)createInstanceForPrescriptionWithID:(NSNumber *)prescriptionID;

@end
