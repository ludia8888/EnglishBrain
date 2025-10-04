# PatternsAPI

All URIs are relative to *https://api.englishbrain.app/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getPatternConquests**](PatternsAPI.md#getpatternconquests) | **GET** /users/me/pattern-conquests | Get personalized pattern conquest data
[**listPatterns**](PatternsAPI.md#listpatterns) | **GET** /patterns | List pattern definitions available to clients


# **getPatternConquests**
```swift
    open class func getPatternConquests(completion: @escaping (_ data: GetPatternConquests200Response?, _ error: Error?) -> Void)
```

Get personalized pattern conquest data

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI


// Get personalized pattern conquest data
PatternsAPI.getPatternConquests() { (response, error) in
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

[**GetPatternConquests200Response**](GetPatternConquests200Response.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPatterns**
```swift
    open class func listPatterns(completion: @escaping (_ data: ListPatterns200Response?, _ error: Error?) -> Void)
```

List pattern definitions available to clients

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI


// List pattern definitions available to clients
PatternsAPI.listPatterns() { (response, error) in
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

[**ListPatterns200Response**](ListPatterns200Response.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

