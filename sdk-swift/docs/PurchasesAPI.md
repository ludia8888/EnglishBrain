# PurchasesAPI

All URIs are relative to *https://api.englishbrain.app/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createPurchase**](PurchasesAPI.md#createpurchase) | **POST** /purchases | Create or update subscription purchase
[**getOwnPurchase**](PurchasesAPI.md#getownpurchase) | **GET** /purchases/me | Retrieve current subscription state for user


# **createPurchase**
```swift
    open class func createPurchase(purchaseRequest: PurchaseRequest, completion: @escaping (_ data: Purchase?, _ error: Error?) -> Void)
```

Create or update subscription purchase

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let purchaseRequest = PurchaseRequest(receipt: "receipt_example", platform: "platform_example", plan: "plan_example", storeTransactionId: "storeTransactionId_example", promoCode: "promoCode_example") // PurchaseRequest | 

// Create or update subscription purchase
PurchasesAPI.createPurchase(purchaseRequest: purchaseRequest) { (response, error) in
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
 **purchaseRequest** | [**PurchaseRequest**](PurchaseRequest.md) |  | 

### Return type

[**Purchase**](Purchase.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOwnPurchase**
```swift
    open class func getOwnPurchase(completion: @escaping (_ data: Purchase?, _ error: Error?) -> Void)
```

Retrieve current subscription state for user

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI


// Retrieve current subscription state for user
PurchasesAPI.getOwnPurchase() { (response, error) in
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

[**Purchase**](Purchase.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

