//
//  ClifeHistoryDetailsViewController.h
//  CLife
//
//  Created by Jordan Gurrieri on 9/9/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ClifeHistoryDetailsViewController : BaseViewController < UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate > {
    UITableView             *m_tbl_historyDetails;
    
    NSArray                 *m_sectionsArray;
    
    NSNumber                *m_prescriptionInstanceID;
    
    NSDateFormatter         *m_dateAndTimeFormatter;
    
    BOOL                    m_isEditing;
    
    UISegmentedControl      *m_sc_confirmation;
    UITextField             *m_tf_dateTaken;
    UIDatePicker            *m_pv_dateTaken;
    UITextView              *m_tv_notes;
    
    UIView                  *m_v_disabledBackground;
    UITapGestureRecognizer  *m_gestureRecognizer;
    
    NSNumber                *m_dateTaken;
    NSString                *m_notes;
    int                     m_prescriptionInstanceState;
    
    BOOL                    m_dateTakenIsShown;
    
    UIAlertView             *m_av_edit;
}

@property (nonatomic, retain) IBOutlet  UITableView             *tbl_historyDetails;

@property (nonatomic, retain)           NSArray                 *sectionsArray;

@property (nonatomic, retain)           NSNumber                *prescriptionInstanceID;

@property (nonatomic, retain)           NSDateFormatter         *dateAndTimeFormatter;

@property (nonatomic, assign)           BOOL                    isEditing;

@property (nonatomic, retain)           UISegmentedControl      *sc_confirmation;
@property (nonatomic, retain)           UITextField             *tf_dateTaken;
@property (nonatomic, retain)           UIDatePicker            *pv_dateTaken;
@property (nonatomic, retain)           UITextView              *tv_notes;

@property (nonatomic, retain) IBOutlet  UIView                  *v_disabledBackground;
@property (nonatomic, retain)           UITapGestureRecognizer  *gestureRecognizer;

@property (nonatomic, retain)           NSNumber                *dateTaken;
@property (nonatomic, retain)           NSString                *notes;
@property (nonatomic, assign)           int                     prescriptionInstanceState;

@property (nonatomic, assign)           BOOL                    dateTakenIsShown;

@property (nonatomic, retain)           UIAlertView             *av_edit;

#pragma mark - Static Initializers
+ (ClifeHistoryDetailsViewController *)createInstanceForPrescriptionInstanceWithID:(NSNumber *)prescriptionInstanceID;

@end
