# LiveActivitiesAPI

All URIs are relative to *https://api.englishbrain.app/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteLiveActivity**](LiveActivitiesAPI.md#deleteliveactivity) | **DELETE** /live-activities/{liveActivityId} | Deregister a Live Activity
[**registerLiveActivity**](LiveActivitiesAPI.md#registerliveactivity) | **POST** /live-activities | Register a Live Activity for a session
[**updateLiveActivity**](LiveActivitiesAPI.md#updateliveactivity) | **PATCH** /live-activities/{liveActivityId} | Update Live Activity lifecycle state


# **deleteLiveActivity**
```swift
    open class func deleteLiveActivity(liveActivityId: UUID, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Deregister a Live Activity

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let liveActivityId = 987 // UUID | Unique identifier for the Live Activity registration.

// Deregister a Live Activity
LiveActivitiesAPI.deleteLiveActivity(liveActivityId: liveActivityId) { (response, error) in
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
 **liveActivityId** | **UUID** | Unique identifier for the Live Activity registration. | 

### Return type

Void (empty response body)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **registerLiveActivity**
```swift
    open class func registerLiveActivity(liveActivityRegisterRequest: LiveActivityRegisterRequest, completion: @escaping (_ data: LiveActivity?, _ error: Error?) -> Void)
```

Register a Live Activity for a session

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let liveActivityRegisterRequest = LiveActivityRegisterRequest(sessionId: 123, activityToken: "activityToken_example", pushToken: "pushToken_example", deviceCapabilities: LiveActivityRegisterRequest_deviceCapabilities(supportsLiveActivities: false, supportsDynamicIsland: false)) // LiveActivityRegisterRequest | 

// Register a Live Activity for a session
LiveActivitiesAPI.registerLiveActivity(liveActivityRegisterRequest: liveActivityRegisterRequest) { (response, error) in
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
 **liveActivityRegisterRequest** | [**LiveActivityRegisterRequest**](LiveActivityRegisterRequest.md) |  | 

### Return type

[**LiveActivity**](LiveActivity.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateLiveActivity**
```swift
    open class func updateLiveActivity(liveActivityId: UUID, liveActivityUpdateRequest: LiveActivityUpdateRequest, completion: @escaping (_ data: LiveActivity?, _ error: Error?) -> Void)
```

Update Live Activity lifecycle state

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let liveActivityId = 987 // UUID | Unique identifier for the Live Activity registration.
let liveActivityUpdateRequest = LiveActivityUpdateRequest(status: "status_example", summary: SessionSummary(accuracy: 123, totalItems: 123, correct: 123, incorrect: 123, hintsUsed: 123, comboMax: 123, brainTokensEarned: 123, durationSeconds: 123, patternImpact: [PatternImpact(patternId: "patternId_example", deltaConquestRate: 123, exposures: 123, severityBefore: 123, severityAfter: 123, hintRateBefore: 123, hintRateAfter: 123)], hintRate: 123, firstTryRate: 123, completedAt: Date(), brainBurstApplied: false, brainBurstMultiplier: 123, brainBurstEligibleAt: Date())) // LiveActivityUpdateRequest | 

// Update Live Activity lifecycle state
LiveActivitiesAPI.updateLiveActivity(liveActivityId: liveActivityId, liveActivityUpdateRequest: liveActivityUpdateRequest) { (response, error) in
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
 **liveActivityId** | **UUID** | Unique identifier for the Live Activity registration. | 
 **liveActivityUpdateRequest** | [**LiveActivityUpdateRequest**](LiveActivityUpdateRequest.md) |  | 

### Return type

[**LiveActivity**](LiveActivity.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

