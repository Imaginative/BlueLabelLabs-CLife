//
//  LocalNotificationManager.m
//  CLife
//
//  Created by Jasjeet Gill on 9/2/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "LocalNotificationManager.h"
#import "Attributes.h"
#import "Macros.h"
#import "PrescriptionInstanceState.h"

#define kMAXNUMBEROFLOCALNOTIFICATIONS  64

@implementation LocalNotificationManager

static LocalNotificationManager* sharedManager;

+ (LocalNotificationManager*) instance {
    @synchronized (self) {
        if (!sharedManager) {
            sharedManager = [[LocalNotificationManager alloc]init];
        }
        return sharedManager;
    }
    
}

- (id) init
{
    self = [super init];
    if (self)
    {
        //when the notification manager starts up, it will need to go through
        //and schedule the necessary batch of new notification messages for outstanding
        //prescription instances
        [self scheduleNotifications];
    }
    return self;
}

//returns a boolean indicating whether this particular prescriptionInstance is scheduled
//for a local notificaton
- (BOOL) isScheduledForLocalNotification:(PrescriptionInstance*)prescriptionInstance
{
    BOOL retVal = NO;
    
    //get all scheduled local notifications for this application
    UIApplication* applicationObject = [UIApplication sharedApplication];
    NSArray* scheduledNotifications = applicationObject.scheduledLocalNotifications;
    
    
    
    for (UILocalNotification* notification in scheduledNotifications)
    {
        //we check the user info property to see if the prescription instance id
        //matches the one passed in
        NSDictionary* userInfo = notification.userInfo;
        NSNumber* prescriptionInstanceID = [userInfo valueForKey:PRESCRIPTIONINSTANCEID];
        
        if (prescriptionInstanceID != nil)
        {
            if ([prescriptionInstanceID isEqualToNumber:prescriptionInstance.objectid])
            {
                //this notification corresponds to the passed in prescription instance;
                retVal = YES;
                break;
            }
        }
    }
    return retVal;
}

//returns an array of Local Notification objects accociated to a particular prescriptionInstance
- (NSArray *) localNotificationsForPrescriptionInstance:(PrescriptionInstance*)prescriptionInstance
{
    NSMutableArray *retVal = nil;
    
    //get all scheduled local notifications for this application
    UIApplication* applicationObject = [UIApplication sharedApplication];
    NSArray* scheduledNotifications = applicationObject.scheduledLocalNotifications;
    
    for (UILocalNotification* notification in scheduledNotifications)
    {
        //we check the user info property to see if the prescription instance id
        //matches the one passed in
        NSDictionary* userInfo = notification.userInfo;
        NSNumber* prescriptionInstanceID = [userInfo valueForKey:PRESCRIPTIONINSTANCEID];
        
        if (prescriptionInstanceID != nil)
        {
            if ([prescriptionInstanceID isEqualToNumber:prescriptionInstance.objectid])
            {
                //this notification corresponds to the passed in prescription instance, add it to the array
                [retVal addObject:notification];
            }
        }
    }
    return retVal;
}



- (NSArray*) getFirst:(int)count from:(NSArray*)prescriptionInstances
{
    NSMutableArray* retVal = [[NSMutableArray alloc]init];
    
    int i = 0;
    
    while (i < count)
    {
        if (i >= [prescriptionInstances count])
        {
            break;
        }
        else {
            PrescriptionInstance* obj = [prescriptionInstances objectAtIndex:i];
            [retVal addObject:obj];
        }
        i++;
    }
    return retVal;
}


//will iterate through the list of PrescriptionInstances and schedule a local notification
//for all of the prescription instances
- (void) scheduleNotifications
{
    NSString* activityName = @"LocalNotificationManager.scheduleNotificationsFor:";
    
    //iterates through all of the PrescriptionInstances and schedules them
    UIApplication* applicationObj = [UIApplication sharedApplication];
    
    
    //we need to grab all existing notifications for this app
    NSArray* scheduledLocalNotifications = [applicationObj scheduledLocalNotifications];
    
    LOG_LOCALNOTIFICATIONMANAGER(0,@"%@Detected %d existing notifications scheduled",activityName,[scheduledLocalNotifications count]);
    
    //now we cancel all of the outstanding local notifications
    [applicationObj cancelAllLocalNotifications];
    LOG_LOCALNOTIFICATIONMANAGER(0,@"%@Cancelled all outstanding notifications for this app",activityName);
    
    //we need to create a sorted list of all unconfirmed PrescriptionInstances
    ResourceContext* resourceContext = [ResourceContext instance];
    
    
    //grab all unconfirmed prescription instance objects sorted by date ascending
    NSDate* date = [NSDate date];
    NSArray* allPrescriptionInstanceObjects = [PrescriptionInstance unconfirmedPrescriptionInstancesAfter:date];
    
    //now we have a list of all unconfirmed prescription instance objects sorted by datescheduled
    //ascending
    LOG_LOCALNOTIFICATIONMANAGER(0,@"%@Retrieved %d existing unconfirmed PrescriptionInstances",activityName,[allPrescriptionInstanceObjects count]);
    
    
    //we iterate through all of them and mark them as being not scheduled
    for (PrescriptionInstance* prescriptionInstance in allPrescriptionInstanceObjects)
    {
        if ([prescriptionInstance.hasnotificationbeenscheduled boolValue])
        {
            prescriptionInstance.hasnotificationbeenscheduled = [NSNumber numberWithBool:NO];
        }
    }
    
    //we take the first X of these prescription instance objects
    NSArray* prescriptionInstanceObjectsToBeScheduled = [self getFirst:kMAXNUMBEROFLOCALNOTIFICATIONS from:allPrescriptionInstanceObjects];
    
    LOG_LOCALNOTIFICATIONMANAGER(0,@"%@Scheduling %d local notifications for prescription instances",activityName,[prescriptionInstanceObjectsToBeScheduled count]);
    
    //we now loop through and schedule these notifications
    int numberOfPrescriptionInstancesScheduled = 0;
    for (PrescriptionInstance* prescriptionInstance in prescriptionInstanceObjectsToBeScheduled)
    {
        //this particular notification has not been scheduled, so we schedule it
        UILocalNotification* localNotificationForPrescriptionInstance = [prescriptionInstance createLocalNotification];
        
        [applicationObj scheduleLocalNotification:localNotificationForPrescriptionInstance];
        prescriptionInstance.hasnotificationbeenscheduled = [NSNumber numberWithBool:YES];
        
        
        LOG_LOCALNOTIFICATIONMANAGER(0,@"%@Scheduled local notification for Prescription: %@  (instance:%@) at %@",activityName, prescriptionInstance.prescriptionid, prescriptionInstance.objectid,localNotificationForPrescriptionInstance.fireDate);
        
        numberOfPrescriptionInstancesScheduled++;
    }
    
    //we now save all of our changes to the resource context
    [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
    LOG_LOCALNOTIFICATIONMANAGER(0,@"%@Finished scheduling %d notifications",activityName,numberOfPrescriptionInstancesScheduled);
    
//  
//    for (PrescriptionInstance* prescriptionInstance in prescriptionInstances) {
//        if (![self isScheduledForLocalNotification:prescriptionInstance])
//        {
//            //this particular notification has not been scheduled, so we schedule it
//            UILocalNotification* localNotificationForPrescriptionInstance = [prescriptionInstance createLocalNotification];
//            
//            //now we have a local notification object, we now schedule it
//            [applicationObj scheduleLocalNotification:localNotificationForPrescriptionInstance];
//            
//            prescriptionInstance.hasnotificationbeenscheduled = [NSNumber numberWithBool:YES];
//            
//            LOG_LOCALNOTIFICATIONMANAGER(0,@"%@Scheduled local notification for prescriptionInstance %@",activityName, prescriptionInstance.objectid);
//        }
//        else {
//            LOG_LOCALNOTIFICATIONMANAGER(0,@"%@Skipping scheduling of local notification for prescriptionInstance %@ as it has already been scheduled",activityName,prescriptionInstance.objectid);
//        }
//    }
}


@end
