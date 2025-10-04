# SessionsAPI

All URIs are relative to *https://api.englishbrain.app/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createSession**](SessionsAPI.md#createsession) | **POST** /sessions | Create a new learning session package
[**getSession**](SessionsAPI.md#getsession) | **GET** /sessions/{sessionId} | Fetch a session by identifier
[**listSessions**](SessionsAPI.md#listsessions) | **GET** /sessions | List recent sessions
[**updateSession**](SessionsAPI.md#updatesession) | **PATCH** /sessions/{sessionId} | Update session lifecycle metadata


# **createSession**
```swift
    open class func createSession(sessionCreateRequest: SessionCreateRequest, completion: @escaping (_ data: Session?, _ error: Error?) -> Void)
```

Create a new learning session package

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let sessionCreateRequest = SessionCreateRequest(mode: "mode_example", entryPoint: "entryPoint_example", patternFocus: ["patternFocus_example"], includeAudio: false, seedSessionId: "seedSessionId_example") // SessionCreateRequest | 

// Create a new learning session package
SessionsAPI.createSession(sessionCreateRequest: sessionCreateRequest) { (response, error) in
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
 **sessionCreateRequest** | [**SessionCreateRequest**](SessionCreateRequest.md) |  | 

### Return type

[**Session**](Session.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSession**
```swift
    open class func getSession(sessionId: UUID, completion: @escaping (_ data: Session?, _ error: Error?) -> Void)
```

Fetch a session by identifier

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let sessionId = 987 // UUID | Unique identifier for the session.

// Fetch a session by identifier
SessionsAPI.getSession(sessionId: sessionId) { (response, error) in
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
 **sessionId** | **UUID** | Unique identifier for the session. | 

### Return type

[**Session**](Session.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listSessions**
```swift
    open class func listSessions(cursor: String? = nil, limit: Int? = nil, completion: @escaping (_ data: SessionCollection?, _ error: Error?) -> Void)
```

List recent sessions

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let cursor = "cursor_example" // String | Opaque pagination cursor provided by a previous result page. (optional)
let limit = 987 // Int | Number of resources to return per page. (optional) (default to 20)

// List recent sessions
SessionsAPI.listSessions(cursor: cursor, limit: limit) { (response, error) in
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
 **cursor** | **String** | Opaque pagination cursor provided by a previous result page. | [optional] 
 **limit** | **Int** | Number of resources to return per page. | [optional] [default to 20]

### Return type

[**SessionCollection**](SessionCollection.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateSession**
```swift
    open class func updateSession(sessionId: UUID, sessionUpdateRequest: SessionUpdateRequest, completion: @escaping (_ data: Session?, _ error: Error?) -> Void)
```

Update session lifecycle metadata

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let sessionId = 987 // UUID | Unique identifier for the session.
let sessionUpdateRequest = SessionUpdateRequest(status: "status_example", summary: SessionSummary(accuracy: 123, totalItems: 123, correct: 123, incorrect: 123, hintsUsed: 123, comboMax: 123, brainTokensEarned: 123, durationSeconds: 123, patternImpact: [PatternImpact(patternId: "patternId_example", deltaConquestRate: 123, exposures: 123, severityBefore: 123, severityAfter: 123, hintRateBefore: 123, hintRateAfter: 123)], hintRate: 123, firstTryRate: 123, completedAt: Date(), brainBurstApplied: false, brainBurstMultiplier: 123, brainBurstEligibleAt: Date())) // SessionUpdateRequest | 

// Update session lifecycle metadata
SessionsAPI.updateSession(sessionId: sessionId, sessionUpdateRequest: sessionUpdateRequest) { (response, error) in
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
 **sessionId** | **UUID** | Unique identifier for the session. | 
 **sessionUpdateRequest** | [**SessionUpdateRequest**](SessionUpdateRequest.md) |  | 

### Return type

[**Session**](Session.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

