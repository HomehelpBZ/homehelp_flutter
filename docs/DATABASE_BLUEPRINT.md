# HomeHelp Database Blueprint

## Collections

users familyProfiles housekeeperProfiles organizations jobs applications
bookings conversations reviews favorites payments adminActions reports
settings serviceTypes locations verificationQueue

## Subcollections

users/{userId}/documents users/{userId}/notifications
users/{userId}/fcmTokens users/{userId}/guarantors
conversations/{conversationId}/messages

## Key Design Decisions

-   One user document per person
-   Profiles separated by responsibility
-   Messages stored under conversations
-   Notifications stored under users
-   Future-ready service categories
