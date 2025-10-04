//
//  Error+UserFriendly.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import Foundation

extension Error {
    /// 사용자 친화적 에러 메시지로 변환
    var userFriendlyMessage: String {
        // URLError 처리
        if let urlError = self as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "인터넷 연결을 확인해주세요"

            case .timedOut:
                return "서버 응답이 지연되고 있어요\n잠시 후 다시 시도해주세요"

            case .cannotFindHost, .cannotConnectToHost:
                return "서버에 연결할 수 없어요\n잠시 후 다시 시도해주세요"

            case .networkConnectionLost:
                return "네트워크 연결이 끊어졌어요\n다시 시도해주세요"

            case .badServerResponse:
                return "서버 오류가 발생했어요\n잠시 후 다시 시도해주세요"

            default:
                return "네트워크 오류가 발생했어요\n다시 시도해주세요"
            }
        }

        // DecodingError 처리 (API 응답 파싱 실패)
        if self is DecodingError {
            return "데이터를 불러오는 중 문제가 발생했어요"
        }

        // 기본 에러 메시지
        return "일시적인 오류가 발생했어요\n다시 시도해주세요"
    }

    /// 개발자용 상세 에러 정보 (로깅용)
    var detailedDescription: String {
        if let urlError = self as? URLError {
            return "URLError: \(urlError.code.rawValue) - \(urlError.localizedDescription)"
        }

        if let decodingError = self as? DecodingError {
            switch decodingError {
            case .keyNotFound(let key, let context):
                return "DecodingError: Key '\(key.stringValue)' not found - \(context.debugDescription)"
            case .typeMismatch(let type, let context):
                return "DecodingError: Type mismatch for \(type) - \(context.debugDescription)"
            case .valueNotFound(let type, let context):
                return "DecodingError: Value not found for \(type) - \(context.debugDescription)"
            case .dataCorrupted(let context):
                return "DecodingError: Data corrupted - \(context.debugDescription)"
            @unknown default:
                return "DecodingError: \(decodingError.localizedDescription)"
            }
        }

        return localizedDescription
    }
}
