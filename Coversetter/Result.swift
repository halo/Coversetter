import Foundation

enum Result {
  case success(code: String, attributes: [String: String])
  case failure(code: String, attributes: [String: String])

  var success: String? {
    if case let .success(code, _) = self { return code }
    return nil
  }

  var failure: String? {
    if case let .failure(code, _) = self { return code }
    return nil
  }

  var isSuccess: Bool {
    success != nil
  }

  var isFailure: Bool {
    failure != nil
  }

  func attributes(_ key: String) -> String? {
    switch self {
      case let .success(_, attrs), let .failure(_, attrs):
        return attrs[key]
    }
  }

  func onSuccess(_ block: (Result) -> Void) -> Result {
    if isSuccess { block(self) }
    return self
  }

  func onFailure(_ block: (Result) -> Void) -> Result {
    if isFailure { block(self) }
    return self
  }
}
