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
#import "GenderTypes.h"
#import "BloodTypes.h"
#import "BloodRhTypes.h"

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
@dynamic sexconstant;
@dynamic bloodtype;
@dynamic bloodtypeconstant;
@dynamic bloodrhconstant;

- (id) initFromJSONDictionary:(NSDictionary *)jsonDictionary {
    ResourceContext* resourceContext = [ResourceContext instance];
    NSManagedObjectContext* appContext = resourceContext.managedObjectContext;
    NSEntityDescription* entity = [NSEntityDescription entityForName:USER inManagedObjectContext:appContext];
    return [super initFromJSONDictionary:jsonDictionary withEntityDescription:entity insertIntoResourceContext:resourceContext];
}

#pragma mark - Static Methods
+ (void) updateGenderDataType {
    // Get the all the user objects
    ResourceContext *resourceContext = [ResourceContext instance];
    NSArray* users = [resourceContext resourcesWithType:USER];
    
    if ([users count] > 0) {
        for (User *user in users) {
            if ([user.sex isEqualToString:NSLocalizedString(@"MALE", nil)] == YES) {
                user.sexconstant = [NSNumber numberWithInt:kMALE];
            }
            else if ([user.sex isEqualToString:NSLocalizedString(@"FEMALE", nil)] == YES) {
                user.sexconstant = [NSNumber numberWithInt:kFEMALE];
            }
            else {
                // Default value
                user.sexconstant = [NSNumber numberWithInt:kMALE];
            }
        }
        
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
    }
}

+ (void) updateBloodTypeDataType {
    // Get the all the user objects
    ResourceContext *resourceContext = [ResourceContext instance];
    NSArray* users = [resourceContext resourcesWithType:USER];
    
    if ([users count] > 0) {
        for (User *user in users) {
            if ([user.bloodtype isEqualToString:NSLocalizedString(@"A POSITIVE", nil)] == YES) {
                user.bloodtypeconstant = [NSNumber numberWithInt:kA];
                user.bloodrhconstant = [NSNumber numberWithInt:kPOSITIVE];
            }
            else if ([user.bloodtype isEqualToString:NSLocalizedString(@"A NEGATIVE", nil)] == YES) {
                user.bloodtypeconstant = [NSNumber numberWithInt:kA];
                user.bloodrhconstant = [NSNumber numberWithInt:kNEGATIVE];
            }
            else if ([user.bloodtype isEqualToString:NSLocalizedString(@"B POSITIVE", nil)] == YES) {
                user.bloodtypeconstant = [NSNumber numberWithInt:kB];
                user.bloodrhconstant = [NSNumber numberWithInt:kPOSITIVE];
            }
            else if ([user.bloodtype isEqualToString:NSLocalizedString(@"B NEGATIVE", nil)] == YES) {
                user.bloodtypeconstant = [NSNumber numberWithInt:kB];
                user.bloodrhconstant = [NSNumber numberWithInt:kNEGATIVE];
            }
            else if ([user.bloodtype isEqualToString:NSLocalizedString(@"AB POSITIVE", nil)] == YES) {
                user.bloodtypeconstant = [NSNumber numberWithInt:kAB];
                user.bloodrhconstant = [NSNumber numberWithInt:kPOSITIVE];
            }
            else if ([user.bloodtype isEqualToString:NSLocalizedString(@"AB NEGATIVE", nil)] == YES) {
                user.bloodtypeconstant = [NSNumber numberWithInt:kAB];
                user.bloodrhconstant = [NSNumber numberWithInt:kNEGATIVE];
            }
            else if ([user.bloodtype isEqualToString:NSLocalizedString(@"O POSITIVE", nil)] == YES) {
                user.bloodtypeconstant = [NSNumber numberWithInt:kO];
                user.bloodrhconstant = [NSNumber numberWithInt:kPOSITIVE];
            }
            else if ([user.bloodtype isEqualToString:NSLocalizedString(@"O NEGATIVE", nil)] == YES) {
                user.bloodtypeconstant = [NSNumber numberWithInt:kO];
                user.bloodrhconstant = [NSNumber numberWithInt:kNEGATIVE];
            }
            else {
                // Default value
                user.bloodtypeconstant = [NSNumber numberWithInt:kA];
                user.bloodrhconstant = [NSNumber numberWithInt:kPOSITIVE];
            }
        }
        
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
    }
}

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
