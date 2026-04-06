enum QuestionStringParam {
    case current(Int)
    case total(Int)
}

func localizedString(
    _ key: LocalizationKey,
    params: [QuestionStringParam]
) -> String {
    let template = NSLocalizedString(key.rawValue, bundle: bundle, comment: "")
    
    var replacements: [String: String] = [:]
    params.forEach {
        switch $0 {
        case .current(let num): replacements["current"] = "\(num)"
        case .total(let num): replacements["total"] = "\(num)"
        }
    }
    
    var result = template
    replacements.forEach { k, v in
        result = result.replacingOccurrences(of: "{\(k)}", with: v)
    }
    return result
}