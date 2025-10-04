# OnboardingAPI

All URIs are relative to *https://api.englishbrain.app/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createTutorialCompletion**](OnboardingAPI.md#createtutorialcompletion) | **POST** /users/me/tutorial-completions | Record tutorial completion milestone
[**submitLevelTest**](OnboardingAPI.md#submitleveltest) | **POST** /level-tests | Submit level test answers and compute recommended level


# **createTutorialCompletion**
```swift
    open class func createTutorialCompletion(tutorialCompletionRequest: TutorialCompletionRequest, completion: @escaping (_ data: TutorialCompletionResponse?, _ error: Error?) -> Void)
```

Record tutorial completion milestone

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let tutorialCompletionRequest = TutorialCompletionRequest(tutorialId: "tutorialId_example", completedAt: Date(), liveActivityId: 123) // TutorialCompletionRequest | 

// Record tutorial completion milestone
OnboardingAPI.createTutorialCompletion(tutorialCompletionRequest: tutorialCompletionRequest) { (response, error) in
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
 **tutorialCompletionRequest** | [**TutorialCompletionRequest**](TutorialCompletionRequest.md) |  | 

### Return type

[**TutorialCompletionResponse**](TutorialCompletionResponse.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **submitLevelTest**
```swift
    open class func submitLevelTest(levelTestSubmission: LevelTestSubmission, completion: @escaping (_ data: LevelTestResult?, _ error: Error?) -> Void)
```

Submit level test answers and compute recommended level

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let levelTestSubmission = LevelTestSubmission(attempts: [LevelTestAttempt(itemId: "itemId_example", selectedTokenIds: ["selectedTokenIds_example"], timeSpentMs: 123, hintsUsed: 123)], startedAt: Date(), completedAt: Date()) // LevelTestSubmission | 

// Submit level test answers and compute recommended level
OnboardingAPI.submitLevelTest(levelTestSubmission: levelTestSubmission) { (response, error) in
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
 **levelTestSubmission** | [**LevelTestSubmission**](LevelTestSubmission.md) |  | 

### Return type

[**LevelTestResult**](LevelTestResult.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

