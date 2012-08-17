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
    
    UIDatePicker            *m_pv_startDate;
    NSDateFormatter         *m_dateFormatter;
    
    UIPickerView            *m_pv_method;
    NSArray                 *m_methodArray;
    
    UITextField             *m_tf_dosageAmount;
    UIPickerView            *m_pv_dosageUnit;
    NSArray                 *m_dosageUnitArray;
    
    UITextView              *m_tv_reason;
    
    UIView                  *m_v_disabledBackground;
    
    BOOL                    m_isEditing;
    
}

@property (nonatomic, retain) IBOutlet  UITableView             *tbl_prescriptionDetails;
@property (nonatomic, retain)           NSArray                 *sectionsArray;

@property (nonatomic, retain)           NSNumber                *prescriptionID;

@property (nonatomic, retain)           UITextField             *tf_medicationName;
@property (nonatomic, retain)           UITapGestureRecognizer  *gestureRecognizer;

@property (nonatomic, retain)           UIDatePicker            *pv_startDate;
@property (nonatomic, retain)           NSDateFormatter         *dateFormatter;

@property (nonatomic, retain)           UIPickerView            *pv_method;
@property (nonatomic, retain)           NSArray                 *methodArray;

@property (nonatomic, retain)           UITextField             *tf_dosageAmount;
@property (nonatomic, retain)           UIPickerView            *pv_dosageUnit;
@property (nonatomic, retain)           NSArray                 *dosageUnitArray;

@property (nonatomic, retain)           UITextView              *tv_reason;

@property (nonatomic, retain) IBOutlet  UIView                  *v_disabledBackground;

@property (nonatomic, assign)           BOOL                    isEditing;

#pragma mark - Static Initializers
+ (ClifePrescriptionDetailsViewController *)createInstanceForPrescriptionWithID:(NSNumber *)prescriptionID;

@end
