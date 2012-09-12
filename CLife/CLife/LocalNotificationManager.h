//
//  LocalNotificationManager.h
//  CLife
//
//  Created by Jasjeet Gill on 9/2/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrescriptionInstance.h"
@interface LocalNotificationManager : NSObject

- (BOOL) isScheduledForLocalNotification:(PrescriptionInstance*)prescriptionInstance;
- (void) scheduleNotifications;


+ (LocalNotificationManager*)instance;

@end
