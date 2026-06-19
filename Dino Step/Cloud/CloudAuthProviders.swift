//
//  CloudAuthProviders.swift
//  Dino Step
//

import AuthenticationServices
import Foundation
import UIKit

enum CloudAuthError: LocalizedError {
    case missingIdentityToken
    case cancelled

    var errorDescription: String? {
        switch self {
        case .missingIdentityToken:
            return "Sign-in did not return an identity token"
        case .cancelled:
            return "Sign-in was cancelled"
        }
    }
}

@MainActor
final class AppleSignInCoordinator: NSObject {
    private var continuation: CheckedContinuation<String, Error>?

    func signIn() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.email]
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let token = String(data: tokenData, encoding: .utf8) else {
            continuation?.resume(throwing: CloudAuthError.missingIdentityToken)
            continuation = nil
            return
        }
        continuation?.resume(returning: token)
        continuation = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

@MainActor
final class GoogleOAuthCoordinator: NSObject {
    private var session: ASWebAuthenticationSession?
    private var continuation: CheckedContinuation<CloudSession, Error>?

    func signIn(config: SupabaseConfig, httpClient: SupabaseHTTPClient) async throws -> CloudSession {
        let redirect = config.googleOAuthRedirect
        let encodedRedirect = redirect.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? redirect
        let base = config.url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: "\(base)/auth/v1/authorize?provider=google&redirect_to=\(encodedRedirect)") else {
            throw SupabaseHTTPError.invalidResponse
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: URL(string: redirect)?.scheme) { [weak self] callbackURL, error in
                guard let self else { return }
                if let error {
                    self.continuation?.resume(throwing: error)
                    self.continuation = nil
                    return
                }
                guard let callbackURL,
                      let fragment = callbackURL.fragment,
                      let partial = Self.parsePartialSession(fromFragment: fragment) else {
                    self.continuation?.resume(throwing: SupabaseHTTPError.invalidResponse)
                    self.continuation = nil
                    return
                }
                Task {
                    do {
                        let session = try await httpClient.fetchUser(
                            accessToken: partial.accessToken,
                            refreshToken: partial.refreshToken,
                            provider: "google"
                        )
                        self.continuation?.resume(returning: session)
                    } catch {
                        self.continuation?.resume(throwing: error)
                    }
                    self.continuation = nil
                }
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            self.session = session
            session.start()
        }
    }

    private static func parsePartialSession(fromFragment fragment: String) -> (accessToken: String, refreshToken: String)? {
        var values: [String: String] = [:]
        for pair in fragment.split(separator: "&") {
            let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
            if parts.count == 2 {
                values[parts[0]] = parts[1].removingPercentEncoding ?? parts[1]
            }
        }
        guard let accessToken = values["access_token"],
              let refreshToken = values["refresh_token"] else {
            return nil
        }
        return (accessToken, refreshToken)
    }
}

extension GoogleOAuthCoordinator: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
