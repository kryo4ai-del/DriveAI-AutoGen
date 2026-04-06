// OptionButtonView.swift
struct OptionButtonView: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isIncorrect: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(text)
                        .font(.body)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if isIncorrect {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                } else if isSelected && !isDisabled {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .disabled(isDisabled)
    }
    
    private var backgroundColor: Color {
        if isCorrect {
            return Color.green.opacity(0.1)
        } else if isIncorrect {
            return Color.red.opacity(0.1)
        } else if isSelected && !isDisabled {
            return Color.blue.opacity(0.1)
        }
        return Color(.systemGray6)
    }
    
    private var borderColor: Color {
        if isCorrect {
            return Color.green
        } else if isIncorrect {
            return Color.red
        } else if isSelected {
            return Color.blue
        }
        return Color(.systemGray3)
    }
}

// ProgressBar.swift

// DifficultyBadge.swift
struct DifficultyBadge: View {
    let level: Int  // 1-5
    
    var label: String {
        switch level {
        case 1: return "Easy"
        case 2: return "Medium"
        case 3: return "Challenging"
        case 4, 5: return "Difficult"
        default: return "Unknown"
        }
    }
    
    var color: Color {
        switch level {
        case 1: return .green
        case 2: return .yellow
        case 3: return .orange
        case 4, 5: return .red
        default: return .gray
        }
    }
    
    var body: some View {
        Text(label)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}