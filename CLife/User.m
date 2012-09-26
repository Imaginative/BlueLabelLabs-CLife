//
//  User.m
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "User.h"
#import <CoreData/CoreData.h>
#import "ResourceContext.h"
#import "DateTimeHelper.h"
#import "Feed.h"
#import "Attributes.h"
#import "IDGenerator.h"
#import "ApplicationSettingsManager.h"
#import "Prescription.h"

@implementation User


@dynamic app_version;
@dynamic devicetoken;
@dynamic displayname;
@dynamic email;
@dynamic fb_user_id;
@dynamic imageurl;

@dynamic twitter_user_id;
@dynamic username;
@dynamic thumbnailurl;

@dynamic dateborn;
@dynamic sex;
@dynamic bloodtype;

- (id) initFromJSONDictionary:(NSDictionary *)jsonDictionary {
    ResourceContext* resourceContext = [ResourceContext instance];
    NSManagedObjectContext* appContext = resourceContext.managedObjectContext;
    NSEntityDescription* entity = [NSEntityDescription entityForName:USER inManagedObjectContext:appContext];
    return [super initFromJSONDictionary:jsonDictionary withEntityDescription:entity insertIntoResourceContext:resourceContext];
}

#pragma mark - Static Methods
+ (void) deleteUserWithID:(NSNumber *)userID {
//    NSString* activityName = @"User.deleteUserWithID:";
    
    // First delete all associated prescription objects
    [Prescription deleteAllPrescriptions];
    
    // Now delete the user object
    ResourceContext *resourceContext = [ResourceContext instance];
    [resourceContext delete:userID withType:USER];
    
    [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
//    LOG_USER(0,@"%@ Committed deletions to the local store", activityName);
    
}

+ (User*)createNewDefaultUser
{
    //creates and returns an empty user object to log in as the default profile
    ResourceContext* resourceContext = [ResourceContext instance];
    User* retVal = (User*)[Resource createInstanceOfType:USER withResourceContext:resourceContext];
    
    IDGenerator* idGenerator = [IDGenerator instance];
    NSNumber* userID = [idGenerator generateNewId:USER];
    retVal.objectid = userID;
    retVal.app_version = [ApplicationSettingsManager getApplicationVersion];
    
    return retVal;
}

@end
