//
//  ClifeProfileViewController.h
//  CLife
//
//  Created by Jasjeet Gill on 8/9/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UIPromptAlertView.h"
#import "ExportManager.h"

@interface ClifeProfileViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate, UIActionSheetDelegate, ExportManagerDelegate > {
    
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
    NSArray                 *m_bloodRhArray;
    
    UIView                  *m_v_disabledBackground;
    UILabel                 *m_lbl_disableTabBar;
    
    BOOL                    m_didRequestEdit;
    BOOL                    m_didRequestDelete;
    BOOL                    m_isEditing;
    BOOL                    m_isNewUser;
    
    NSString                *m_name;
    NSNumber                *m_birthday;
    NSNumber                *m_gender;
    NSNumber                *m_bloodType;
    NSNumber                *m_bloodRh;
    
    UIAlertView             *m_av_edit;
    UIPromptAlertView       *m_av_delete;
    
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
@property (nonatomic, retain)           NSArray                 *bloodRhArray;

@property (nonatomic, retain) IBOutlet  UIView                  *v_disabledBackground;
@property (nonatomic, retain)           UILabel                 *lbl_disableTabBar;

@property (nonatomic, assign)           BOOL                    didRequestEdit;
@property (nonatomic, assign)           BOOL                    didRequestDelete;
@property (nonatomic, assign)           BOOL                    isEditing;
@property (nonatomic, assign)           BOOL                    isNewUser;

@property (nonatomic, retain)           NSString                *name;
@property (nonatomic, retain)           NSNumber                *birthday;
@property (nonatomic, retain)           NSNumber                *gender;
@property (nonatomic, retain)           NSNumber                *bloodType;
@property (nonatomic, retain)           NSNumber                *bloodRh;

@property (nonatomic, retain)           UIAlertView             *av_edit;
@property (nonatomic, retain)           UIPromptAlertView       *av_delete;

#pragma mark - Static Initializers
+ (ClifeProfileViewController *)createInstance;

@end
