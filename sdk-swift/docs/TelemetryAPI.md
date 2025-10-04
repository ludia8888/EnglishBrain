# TelemetryAPI

All URIs are relative to *https://api.englishbrain.app/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**ingestTelemetryEvents**](TelemetryAPI.md#ingesttelemetryevents) | **POST** /telemetry/events | Ingest product telemetry events
[**syncSessions**](TelemetryAPI.md#syncsessions) | **POST** /sync/sessions | Upload offline-completed sessions and attempts


# **ingestTelemetryEvents**
```swift
    open class func ingestTelemetryEvents(telemetryBatch: TelemetryBatch, completion: @escaping (_ data: TelemetryIngestResponse?, _ error: Error?) -> Void)
```

Ingest product telemetry events

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let telemetryBatch = TelemetryBatch(events: [TelemetryEvent(eventId: 123, type: "type_example", occurredAt: Date(), sessionId: "sessionId_example", reviewId: "reviewId_example", liveActivityId: "liveActivityId_example", attributes: 123)], source: "source_example") // TelemetryBatch | 

// Ingest product telemetry events
TelemetryAPI.ingestTelemetryEvents(telemetryBatch: telemetryBatch) { (response, error) in
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
 **telemetryBatch** | [**TelemetryBatch**](TelemetryBatch.md) |  | 

### Return type

[**TelemetryIngestResponse**](TelemetryIngestResponse.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncSessions**
```swift
    open class func syncSessions(offlineSyncRequest: OfflineSyncRequest, completion: @escaping (_ data: OfflineSyncResponse?, _ error: Error?) -> Void)
```

Upload offline-completed sessions and attempts

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import EnglishBrainAPI

let offlineSyncRequest = OfflineSyncRequest(sessions: [Session(sessionId: 123, mode: "mode_example", status: "status_example", startedAt: Date(), expiresAt: Date(), source: "source_example", phases: [SessionPhase(phaseId: "phaseId_example", label: "label_example", phaseType: "phaseType_example", order: 123, targetSentences: 123, targetDurationSeconds: 123, itemIds: ["itemIds_example"], comboRules: SessionPhase_comboRules(base: 123, bonusPerStreak: 123), checkpointStatus: CheckpointStatus(reached: false, accuracy: 123, combosMax: 123, completedAt: Date()), hintBudget: 123)], items: [SessionItem(itemId: "itemId_example", prompt: ItemPrompt(ko: "ko_example", enReference: "enReference_example", audioUrl: "audioUrl_example"), frame: ItemFrame(slots: [FrameSlot(role: "role_example", label: "label_example", _optional: false)]), tokens: [FrameToken(tokenId: "tokenId_example", display: "display_example", role: "role_example", lemma: "lemma_example", audioUrl: "audioUrl_example")], distractors: [nil], correctSequence: ["correctSequence_example"], patternTags: ["patternTags_example"], difficultyBand: "difficultyBand_example", hints: [Hint(order: 123, type: "type_example", content: "content_example")], scoring: ScoringRules(basePoints: 123, comboBonus: 123, hintPenalty: 123))], summary: SessionSummary(accuracy: 123, totalItems: 123, correct: 123, incorrect: 123, hintsUsed: 123, comboMax: 123, brainTokensEarned: 123, durationSeconds: 123, patternImpact: [PatternImpact(patternId: "patternId_example", deltaConquestRate: 123, exposures: 123, severityBefore: 123, severityAfter: 123, hintRateBefore: 123, hintRateAfter: 123)], hintRate: 123, firstTryRate: 123, completedAt: Date(), brainBurstApplied: false, brainBurstMultiplier: 123, brainBurstEligibleAt: Date()), brainBurst: BrainBurstState(active: false, multiplier: 123, eligibleAt: Date(), sessionsUntilActivation: 123), liveActivity: LiveActivity(liveActivityId: 123, sessionId: 123, status: "status_example", activityToken: "activityToken_example", pushTokenExpiresAt: Date(), createdAt: Date(), updatedAt: Date()))], attempts: [Attempt(attemptId: "attemptId_example", itemId: "itemId_example", startedAt: Date(), completedAt: Date(), placements: [Placement(slot: "slot_example", tokenId: "tokenId_example")], verdict: "verdict_example", timeSpentMs: 123, hintsUsed: 123, comboCount: 123, errors: [AttemptError(code: "code_example", message: "message_example", details: "TODO")], retryNumber: 123, firstTryCorrect: false, sessionId: "sessionId_example")], checkpoints: [Checkpoint(checkpointId: "checkpointId_example", phaseId: "phaseId_example", reachedAt: Date(), accuracy: 123, comboMax: 123, hintsUsed: 123, durationSeconds: 123, brainTokensEarned: 123, freezeConsumed: false, sessionId: "sessionId_example")], pendingRewards: [PendingReward(rewardId: "rewardId_example", type: "type_example", status: "status_example", serverClockSnapshot: Date())]) // OfflineSyncRequest | 

// Upload offline-completed sessions and attempts
TelemetryAPI.syncSessions(offlineSyncRequest: offlineSyncRequest) { (response, error) in
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
 **offlineSyncRequest** | [**OfflineSyncRequest**](OfflineSyncRequest.md) |  | 

### Return type

[**OfflineSyncResponse**](OfflineSyncResponse.md)

### Authorization

[FirebaseAuth](../README.md#FirebaseAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

