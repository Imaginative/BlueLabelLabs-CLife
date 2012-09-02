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
    }
    return self;
}

///returns a boolean indicating whether this particular prescriptionInstance is scheduled
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


//will iterate through the list of PrescriptionInstances and schedule a local notification
//for all of the prescription instances
- (void) scheduleNotificationsFor:(NSArray *)prescriptionInstances
{
    NSString* activityName = @"LocalNotificationManager.scheduleNotificationsFor:";
    
    //iterates through all of the PrescriptionInstances and schedules them
    UIApplication* applicationObj = [UIApplication sharedApplication];
    for (PrescriptionInstance* prescriptionInstance in prescriptionInstances) {
        if (![self isScheduledForLocalNotification:prescriptionInstance])
        {
            //this particular notification has not been scheduled, so we schedule it
            UILocalNotification* localNotificationForPrescriptionInstance = [prescriptionInstance createLocalNotification];
            
            //now we have a local notification object, we now schedule it
            [applicationObj scheduleLocalNotification:localNotificationForPrescriptionInstance];
            
            LOG_LOCALNOTIFICATIONMANAGER(0,@"%@Scheduled local notification for prescriptionInstance %@",activityName, prescriptionInstance.objectid);
        }
        else {
            LOG_LOCALNOTIFICATIONMANAGER(0,@"%@Skipping scheduling of local notification for prescriptionInstance %@ as it has already been scheduled",activityName,prescriptionInstance.objectid);
        }
    }
}


@end
