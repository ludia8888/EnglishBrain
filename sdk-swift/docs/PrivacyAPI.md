# PrivacyAPI

All URIs are relative to *https://api.englishbrain.app/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createDataDeletionRequest**](PrivacyAPI.md#createdatadeletionrequest) | **POST** /users/me/data-deletion-requests | Submit a user-initiated data deletion request
[**createDataExportRequest**](PrivacyAPI.md#createdataexportrequest) | **POST** /users/me/data-export-requests | Submit a user-initiated data export request


# **createDataDeletionRequest**
```swift
    open class func createDataDeletionRequest(dataDeletionRequest: DataDeletionRequest? = nil, completion: @escaping (_ data: DataDeletionResponse?, _ error: Error?) -> Void)
```

Submit a user-initiated data deletion request

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let dataDeletionRequest = DataDeletionRequest(reason: "reason_example") // DataDeletionRequest |  (optional)

// Submit a user-initiated data deletion request
PrivacyAPI.createDataDeletionRequest(dataDeletionRequest: dataDeletionRequest) { (response, error) in
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
 **dataDeletionRequest** | [**DataDeletionRequest**](DataDeletionRequest.md) |  | [optional] 

### Return type

[**DataDeletionResponse**](DataDeletionResponse.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createDataExportRequest**
```swift
    open class func createDataExportRequest(dataExportRequest: DataExportRequest? = nil, completion: @escaping (_ data: DataExportResponse?, _ error: Error?) -> Void)
```

Submit a user-initiated data export request

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let dataExportRequest = DataExportRequest(deliveryChannel: "deliveryChannel_example") // DataExportRequest |  (optional)

// Submit a user-initiated data export request
PrivacyAPI.createDataExportRequest(dataExportRequest: dataExportRequest) { (response, error) in
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
 **dataExportRequest** | [**DataExportRequest**](DataExportRequest.md) |  | [optional] 

### Return type

[**DataExportResponse**](DataExportResponse.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

