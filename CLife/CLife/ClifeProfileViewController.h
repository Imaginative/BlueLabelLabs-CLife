//
//  ClifeProfileViewController.h
//  CLife
//
//  Created by Jasjeet Gill on 8/9/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ClifeProfileViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate, UIActionSheetDelegate > {
    
    UITableView             *m_tbl_profile;
    NSArray                 *m_sectionsArray;
    
    UITextField             *m_tf_name;
    UITextField             *m_tf_birthday;
    UITextField             *m_tf_gender;
    UITextField             *m_tf_bloodType;
    
    UITapGestureRecognizer  *m_gestureRecognizer;
    
    UIDatePicker            *m_pv_birthday;
    NSDateFormatter         *m_dateFormatter;
    
    UIPickerView            *m_pv_gender;
    UIPickerView            *m_pv_bloodType;
    NSArray                 *m_genderArray;
    NSArray                 *m_bloodTypeArray;
    
    UIView                  *m_v_disabledBackground;
    
    BOOL                    m_isEditing;
    BOOL                    m_isNewUser;
    
    NSString                *m_name;
    NSNumber                *m_birthday;
    NSString                *m_gender;
    NSString                *m_bloodType;
    
}

@property (nonatomic, retain) IBOutlet  UITableView             *tbl_profile;
@property (nonatomic, retain)           NSArray                 *sectionsArray;

@property (nonatomic, retain)           UITextField             *tf_name;
@property (nonatomic, retain)           UITextField             *tf_birthday;
@property (nonatomic, retain)           UITextField             *tf_gender;
@property (nonatomic, retain)           UITextField             *tf_bloodType;

@property (nonatomic, retain)           UITapGestureRecognizer  *gestureRecognizer;

@property (nonatomic, retain)           UIDatePicker            *pv_birthday;
@property (nonatomic, retain)           NSDateFormatter         *dateFormatter;

@property (nonatomic, retain)           UIPickerView            *pv_gender;
@property (nonatomic, retain)           UIPickerView            *pv_bloodType;
@property (nonatomic, retain)           NSArray                 *genderArray;
@property (nonatomic, retain)           NSArray                 *bloodTypeArray;

@property (nonatomic, retain) IBOutlet  UIView                  *v_disabledBackground;

@property (nonatomic, assign)           BOOL                    isEditing;
@property (nonatomic, assign)           BOOL                    isNewUser;

@property (nonatomic, retain)           NSString                *name;
@property (nonatomic, retain)           NSNumber                *birthday;
@property (nonatomic, retain)           NSString                *gender;
@property (nonatomic, retain)           NSString                *bloodType;

#pragma mark - Static Initializers
+ (ClifeProfileViewController *)createInstance;

@end
