# AttemptsAPI

All URIs are relative to *https://api.englishbrain.app/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createAttempt**](AttemptsAPI.md#createattempt) | **POST** /sessions/{sessionId}/attempts | Log an item attempt within a session
[**listAttempts**](AttemptsAPI.md#listattempts) | **GET** /sessions/{sessionId}/attempts | Retrieve attempts for a session
[**recordCheckpoint**](AttemptsAPI.md#recordcheckpoint) | **POST** /sessions/{sessionId}/checkpoints | Record a phase checkpoint outcome


# **createAttempt**
```swift
    open class func createAttempt(sessionId: UUID, attemptSubmission: AttemptSubmission, completion: @escaping (_ data: Attempt?, _ error: Error?) -> Void)
```

Log an item attempt within a session

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let sessionId = 987 // UUID | Unique identifier for the session.
let attemptSubmission = AttemptSubmission(attemptId: "attemptId_example", itemId: "itemId_example", startedAt: Date(), completedAt: Date(), placements: [Placement(slot: "slot_example", tokenId: "tokenId_example")], verdict: "verdict_example", timeSpentMs: 123, hintsUsed: 123, comboCount: 123, errors: [AttemptError(code: "code_example", message: "message_example", details: "TODO")], retryNumber: 123, firstTryCorrect: false) // AttemptSubmission | 

// Log an item attempt within a session
AttemptsAPI.createAttempt(sessionId: sessionId, attemptSubmission: attemptSubmission) { (response, error) in
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
 **attemptSubmission** | [**AttemptSubmission**](AttemptSubmission.md) |  | 

### Return type

[**Attempt**](Attempt.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAttempts**
```swift
    open class func listAttempts(attemptType: AttemptType_listAttempts? = nil, completion: @escaping (_ data: ListAttempts200Response?, _ error: Error?) -> Void)
```

Retrieve attempts for a session

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let attemptType = "attemptType_example" // String | Filter attempts by verdict classification. (optional) (default to .all)

// Retrieve attempts for a session
AttemptsAPI.listAttempts(attemptType: attemptType) { (response, error) in
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
 **attemptType** | **String** | Filter attempts by verdict classification. | [optional] [default to .all]

### Return type

[**ListAttempts200Response**](ListAttempts200Response.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recordCheckpoint**
```swift
    open class func recordCheckpoint(sessionId: UUID, checkpointSubmission: CheckpointSubmission, completion: @escaping (_ data: Checkpoint?, _ error: Error?) -> Void)
```

Record a phase checkpoint outcome

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let sessionId = 987 // UUID | Unique identifier for the session.
let checkpointSubmission = CheckpointSubmission(checkpointId: "checkpointId_example", phaseId: "phaseId_example", reachedAt: Date(), accuracy: 123, comboMax: 123, hintsUsed: 123, durationSeconds: 123, brainTokensEarned: 123, freezeConsumed: false) // CheckpointSubmission | 

// Record a phase checkpoint outcome
AttemptsAPI.recordCheckpoint(sessionId: sessionId, checkpointSubmission: checkpointSubmission) { (response, error) in
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
 **checkpointSubmission** | [**CheckpointSubmission**](CheckpointSubmission.md) |  | 

### Return type

[**Checkpoint**](Checkpoint.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

