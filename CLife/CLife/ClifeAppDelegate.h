//
//  ClifeAppDelegate.h
//  CLife
//
//  Created by Jasjeet Gill on 8/9/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "AuthenticationManager.h"
#import "ApplicationSettingsManager.h"
#import "UIProgressHUDView.h"

@interface ClifeAppDelegate : UIResponder < UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate >
{
     NSString*                  m_deviceToken;
    
    UIAlertView                 *m_av_reminder;
    NSNumber                    *m_prescriptionInstanceID;
}

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext          *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel            *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator    *persistentStoreCoordinator;
@property (nonatomic, retain)           Facebook                        *facebook;
@property (nonatomic, retain)           AuthenticationManager*          authenticationManager;
@property (nonatomic, retain)           ApplicationSettingsManager*     applicationSettingsManager;
@property (nonatomic, retain)           UIProgressHUDView*              progressView;
@property (nonatomic, retain)           NSString*                       deviceToken;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (nonatomic, retain)           UIAlertView                     *av_reminder;
@property (nonatomic, retain)           NSNumber                        *prescriptionInstanceID;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString*) getImageCacheStorageDirectory;
@end
