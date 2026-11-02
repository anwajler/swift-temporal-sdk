//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Temporal SDK open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift Temporal SDK project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift Temporal SDK project authors
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import GRPCCore
import GRPCOTelTracingInterceptors
import OTelSemanticConventions
import TemporalInstrumentation

// MARK: Temporal Interceptors

extension TemporalClient {
    package struct Interceptor: InterceptorImplementation, Sendable {
        package let workflowService: WorkflowService
        let interceptors: [any ClientOutboundInterceptor]
    }
}

// MARK: GRPC Interceptors

extension TemporalClient {
    static func grpcClientInterceptors(serverHostname: String) -> [any GRPCCore.ClientInterceptor] {
        // Request metadata carries the API key in `authorization`, so it must stay out of spans and logs.
        [
            ClientOTelTracingInterceptor(
                serverHostname: serverHostname,
                networkTransportMethod: "tcp",
                traceEachMessage: true,
                includeRequestMetadata: false,
                includeResponseMetadata: true
            ),
            ClientOTelMetricsInterceptor(
                serverHostname: serverHostname,
                networkTransportMethod: .tcp
            ),
            ClientOTelLoggingInterceptor(
                serverHostname: serverHostname,
                networkTransportMethod: .tcp,
                includeRequestMetadata: false,
                includeResponseMetadata: true
            ),
        ]
    }
}
