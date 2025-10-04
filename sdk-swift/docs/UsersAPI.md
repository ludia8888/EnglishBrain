# UsersAPI

All URIs are relative to *https://api.englishbrain.app/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getCurrentUser**](UsersAPI.md#getcurrentuser) | **GET** /users/me | Get current user profile
[**getHomeSummary**](UsersAPI.md#gethomesummary) | **GET** /users/me/home | Get home dashboard summary
[**getWidgetSnapshot**](UsersAPI.md#getwidgetsnapshot) | **GET** /users/me/widget-snapshot | Get compact snapshot for WidgetKit timelines
[**updateCurrentUser**](UsersAPI.md#updatecurrentuser) | **PATCH** /users/me | Update mutable profile fields


# **getCurrentUser**
```swift
    open class func getCurrentUser(completion: @escaping (_ data: UserProfile?, _ error: Error?) -> Void)
```

Get current user profile

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI


// Get current user profile
UsersAPI.getCurrentUser() { (response, error) in
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

[**UserProfile**](UserProfile.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getHomeSummary**
```swift
    open class func getHomeSummary(completion: @escaping (_ data: HomeSummary?, _ error: Error?) -> Void)
```

Get home dashboard summary

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI


// Get home dashboard summary
UsersAPI.getHomeSummary() { (response, error) in
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

[**HomeSummary**](HomeSummary.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getWidgetSnapshot**
```swift
    open class func getWidgetSnapshot(completion: @escaping (_ data: WidgetSnapshot?, _ error: Error?) -> Void)
```

Get compact snapshot for WidgetKit timelines

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI


// Get compact snapshot for WidgetKit timelines
UsersAPI.getWidgetSnapshot() { (response, error) in
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

[**WidgetSnapshot**](WidgetSnapshot.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateCurrentUser**
```swift
    open class func updateCurrentUser(userProfileUpdate: UserProfileUpdate, completion: @escaping (_ data: UserProfile?, _ error: Error?) -> Void)
```

Update mutable profile fields

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let userProfileUpdate = UserProfileUpdate(displayName: "displayName_example", timezone: "timezone_example", locale: "locale_example", preferences: UserPreferencesUpdate(hapticsEnabled: false, soundEnabled: false, pushOptIn: false, effectMode: "effectMode_example", dailyGoalSentences: 123, dailyGoalMinutes: 123)) // UserProfileUpdate | 

// Update mutable profile fields
UsersAPI.updateCurrentUser(userProfileUpdate: userProfileUpdate) { (response, error) in
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
 **userProfileUpdate** | [**UserProfileUpdate**](UserProfileUpdate.md) |  | 

### Return type

[**UserProfile**](UserProfile.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

