# NotificationsAPI

All URIs are relative to *https://api.englishbrain.app/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createStreakFreeze**](NotificationsAPI.md#createstreakfreeze) | **POST** /streaks/freeze | Consume a brain token to freeze the streak
[**getNotificationDigest**](NotificationsAPI.md#getnotificationdigest) | **GET** /notifications/digest | Retrieve pending notification digest for rendering
[**openNotification**](NotificationsAPI.md#opennotification) | **POST** /notifications/{notificationId}/open | Record notification open and resulting action


# **createStreakFreeze**
```swift
    open class func createStreakFreeze(streakFreezeRequest: StreakFreezeRequest, completion: @escaping (_ data: StreakFreezeResponse?, _ error: Error?) -> Void)
```

Consume a brain token to freeze the streak

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let streakFreezeRequest = StreakFreezeRequest(targetDate: Date(), reason: "reason_example", consumeTokenId: "consumeTokenId_example") // StreakFreezeRequest | 

// Consume a brain token to freeze the streak
NotificationsAPI.createStreakFreeze(streakFreezeRequest: streakFreezeRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **streakFreezeRequest** | [**StreakFreezeRequest**](StreakFreezeRequest.md) |  | 

### Return type

[**StreakFreezeResponse**](StreakFreezeResponse.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getNotificationDigest**
```swift
    open class func getNotificationDigest(completion: @escaping (_ data: NotificationDigest?, _ error: Error?) -> Void)
```

Retrieve pending notification digest for rendering

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI


// Retrieve pending notification digest for rendering
NotificationsAPI.getNotificationDigest() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**NotificationDigest**](NotificationDigest.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **openNotification**
```swift
    open class func openNotification(notificationId: UUID, notificationOpenRequest: NotificationOpenRequest, completion: @escaping (_ data: NotificationOpenResponse?, _ error: Error?) -> Void)
```

Record notification open and resulting action

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let notificationId = 987 // UUID | Unique identifier of the notification record.
let notificationOpenRequest = NotificationOpenRequest(openedAt: Date(), surface: "surface_example", actionTaken: "actionTaken_example") // NotificationOpenRequest | 

// Record notification open and resulting action
NotificationsAPI.openNotification(notificationId: notificationId, notificationOpenRequest: notificationOpenRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **notificationId** | **UUID** | Unique identifier of the notification record. | 
 **notificationOpenRequest** | [**NotificationOpenRequest**](NotificationOpenRequest.md) |  | 

### Return type

[**NotificationOpenResponse**](NotificationOpenResponse.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

