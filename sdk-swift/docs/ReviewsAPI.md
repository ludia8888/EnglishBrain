# ReviewsAPI

All URIs are relative to *https://api.englishbrain.app/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createReview**](ReviewsAPI.md#createreview) | **POST** /reviews | Create a personalized review plan
[**getReview**](ReviewsAPI.md#getreview) | **GET** /reviews/{reviewId} | Retrieve a review plan by identifier
[**listReviews**](ReviewsAPI.md#listreviews) | **GET** /reviews | List active review plans
[**updateReview**](ReviewsAPI.md#updatereview) | **PATCH** /reviews/{reviewId} | Update review progress and outcomes


# **createReview**
```swift
    open class func createReview(reviewCreateRequest: ReviewCreateRequest, completion: @escaping (_ data: ReviewPlan?, _ error: Error?) -> Void)
```

Create a personalized review plan

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let reviewCreateRequest = ReviewCreateRequest(trigger: "trigger_example", patternId: "patternId_example", targetSentences: 123) // ReviewCreateRequest | 

// Create a personalized review plan
ReviewsAPI.createReview(reviewCreateRequest: reviewCreateRequest) { (response, error) in
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
 **reviewCreateRequest** | [**ReviewCreateRequest**](ReviewCreateRequest.md) |  | 

### Return type

[**ReviewPlan**](ReviewPlan.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getReview**
```swift
    open class func getReview(reviewId: UUID, completion: @escaping (_ data: ReviewPlan?, _ error: Error?) -> Void)
```

Retrieve a review plan by identifier

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let reviewId = 987 // UUID | Unique identifier for the review plan.

// Retrieve a review plan by identifier
ReviewsAPI.getReview(reviewId: reviewId) { (response, error) in
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
 **reviewId** | **UUID** | Unique identifier for the review plan. | 

### Return type

[**ReviewPlan**](ReviewPlan.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listReviews**
```swift
    open class func listReviews(completion: @escaping (_ data: ListReviews200Response?, _ error: Error?) -> Void)
```

List active review plans

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI


// List active review plans
ReviewsAPI.listReviews() { (response, error) in
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

[**ListReviews200Response**](ListReviews200Response.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateReview**
```swift
    open class func updateReview(reviewId: UUID, reviewUpdateRequest: ReviewUpdateRequest, completion: @escaping (_ data: ReviewPlan?, _ error: Error?) -> Void)
```

Update review progress and outcomes

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let reviewId = 987 // UUID | Unique identifier for the review plan.
let reviewUpdateRequest = ReviewUpdateRequest(status: "status_example", accuracy: 123, durationSeconds: 123, completedAt: Date(), patternImpact: [PatternImpact(patternId: "patternId_example", deltaConquestRate: 123, exposures: 123, severityBefore: 123, severityAfter: 123, hintRateBefore: 123, hintRateAfter: 123)]) // ReviewUpdateRequest | 

// Update review progress and outcomes
ReviewsAPI.updateReview(reviewId: reviewId, reviewUpdateRequest: reviewUpdateRequest) { (response, error) in
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
 **reviewId** | **UUID** | Unique identifier for the review plan. | 
 **reviewUpdateRequest** | [**ReviewUpdateRequest**](ReviewUpdateRequest.md) |  | 

### Return type

[**ReviewPlan**](ReviewPlan.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

