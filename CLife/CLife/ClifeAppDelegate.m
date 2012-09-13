//
//  ClifeAppDelegate.m
//  CLife
//
//  Created by Jasjeet Gill on 8/9/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "ClifeAppDelegate.h"
#import "ClifeProfileViewController.h"
#import "ClifePrescriptionsViewController.h"
#import "ClifeRemindersViewController.h"
#import "ClifeHistoryViewController.h"
#import "LocalNotificationManager.h"
#import "Attributes.h"
#import "ClifeHistoryDetailsViewController.h"

@implementation ClifeAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize applicationSettingsManager = __applicationSettingsManager;
@synthesize authenticationManager = __authenticationManager;
@synthesize facebook = __facebook;
@synthesize progressView = __progressView;
@synthesize deviceToken = m_deviceToken;
@synthesize av_reminder = m_av_reminder;
@synthesize prescriptionInstanceID = m_prescriptionInstanceID;

#define     kFACEBOOKAPPID  @""

- (UIProgressHUDView*)progressView {
    if (__progressView != nil) {
        return __progressView;
    }
    UIProgressHUDView* pv = [[UIProgressHUDView alloc]initWithWindow:self.window];
    __progressView = pv;
    
    
    return __progressView;
}

- (ApplicationSettingsManager*)applicationSettingsManager {
    if (__applicationSettingsManager != nil) {
        return __applicationSettingsManager;
    }
    __applicationSettingsManager = [ApplicationSettingsManager instance];
    return __applicationSettingsManager;
}

- (Facebook*) facebook {
    if (__facebook != nil) {
        return __facebook;
    }
    
    __facebook = [[Facebook alloc]initWithAppId:kFACEBOOKAPPID];
    
    return __facebook;
    
}

- (AuthenticationManager*) authenticationManager {
    if (__authenticationManager != nil) {
        return __authenticationManager;
    }
    
    __authenticationManager = [AuthenticationManager instance];
    return __authenticationManager;
}

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [_tabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    // Override point for customization after application launch.
    
    UIViewController *viewController1 = [ClifeProfileViewController createInstance];
    UINavigationController *navigationcontroller1 = [[[UINavigationController alloc] initWithRootViewController:viewController1] autorelease];
    
    UIViewController *viewController2 = [ClifePrescriptionsViewController createInstance];
    UINavigationController *navigationcontroller2 = [[[UINavigationController alloc] initWithRootViewController:viewController2] autorelease];
    
    UIViewController *viewController3 = [ClifeRemindersViewController createInstance];
    UINavigationController *navigationcontroller3 = [[[UINavigationController alloc] initWithRootViewController:viewController3] autorelease];
    
    UIViewController *viewController4 = [ClifeHistoryViewController createInstance];
    UINavigationController *navigationcontroller4 = [[[UINavigationController alloc] initWithRootViewController:viewController4] autorelease];
    
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:navigationcontroller1, navigationcontroller2, navigationcontroller3, navigationcontroller4, nil];
    
    self.window.rootViewController = self.tabBarController;
    
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    //lets check if a user is currently logged in 
    if (![authenticationManager isUserAuthenticated])
    {   
        //there is no user object currently logged in, we must be running on startup
        //we instruct the authenticatoin manager to create a new user object and log that in
        User* newUser = [authenticationManager createNewUserAndLogin];
        if (newUser != nil)
        {
            //success everything worked, force the user to create a profile
            [self.tabBarController setSelectedIndex:0];
            
        }
        else {
            //error condition
            [self.tabBarController setSelectedIndex:0];
        }
    }
    else {
        ResourceContext* resourceContext = [ResourceContext instance];
        User* loggedInUser = (User*)[resourceContext resourceWithType:USER withID:self.authenticationManager.m_LoggedInUserID];
        
        if (loggedInUser.username != nil &&
            ![loggedInUser.displayname isEqualToString:@""])
        {
            [self.tabBarController setSelectedIndex:3];
        }
        else {
            [self.tabBarController setSelectedIndex:0];
        }
    }
    
    // Determine if we have opened from a reminder notification
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        self.prescriptionInstanceID = [localNotification.userInfo objectForKey:PRESCRIPTIONINSTANCEID];
        [self showHistoryDetailsVC];
//        application.applicationIconBadgeNumber = localNotification.applicationIconBadgeNumber-1;
        application.applicationIconBadgeNumber = 0;
    }
    
    //we grab the local notification manager so it can be instantiated and process itself
    [LocalNotificationManager instance];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (NSString*) getImageCacheStorageDirectory {
    NSString *path = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ([paths count])
    {
        NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        path = [[paths objectAtIndex:0]stringByAppendingPathComponent:bundleName];
    }
    return path;
}

#pragma mark - Local Notification Handlers
- (void)showHistoryDetailsVC {
    ClifeHistoryDetailsViewController *historyDetailsVC = [ClifeHistoryDetailsViewController createInstanceForPrescriptionInstanceWithID:self.prescriptionInstanceID];
    historyDetailsVC.presentedAsModal = YES;
    [historyDetailsVC setHidesBottomBarWhenPushed:YES];
    
    UINavigationController *navigationcontroller = [[[UINavigationController alloc] initWithRootViewController:historyDetailsVC] autorelease];
    
    [self.tabBarController presentModalViewController:navigationcontroller animated:YES];
}

- (void) application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification *)notification  {

    // Get the prescription instance object associated with this notification
    self.prescriptionInstanceID = [notification.userInfo objectForKey:PRESCRIPTIONINSTANCEID];
    
    if (self.prescriptionInstanceID != nil) {
        ResourceContext *resourceContext = [ResourceContext instance];
        PrescriptionInstance *prescriptionInstance = (PrescriptionInstance *)[resourceContext resourceWithType:PRESCRIPTIONINSTANCE withID:self.prescriptionInstanceID];
        
        // Show alert for reminder
        // Promt user to backup data before editing profile information
        self.av_reminder = [[UIAlertView alloc]
                        initWithTitle:NSLocalizedString(@"PRESCRIPTION REMINDER", nil)
                        message:[NSString stringWithFormat:@"%@ %@. %@", NSLocalizedString(@"REMINDER ACTION PART 1", nil), prescriptionInstance.prescriptionname, NSLocalizedString(@"REMINDER ACTION PART 2 TYPE 2", nil)]
                        delegate:self
                        cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                        otherButtonTitles:NSLocalizedString(@"CONFIRM", nil), nil];
        [self.av_reminder show];
        [self.av_reminder release];
    }
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.av_reminder) {
        if (buttonIndex == 0) {
            // Do nothing, user canceled. Prescription Intance will remain in state kUNCONFIRMED
            
        }
        else {
            // Launch Prescription INstance Details VC so user can confirm
            UIApplication *application = [UIApplication sharedApplication];
            application.applicationIconBadgeNumber = 0;
            
            [self showHistoryDetailsVC];
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    //    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Mime_me" withExtension:@"momd"];
    //    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    __managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CLife.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
