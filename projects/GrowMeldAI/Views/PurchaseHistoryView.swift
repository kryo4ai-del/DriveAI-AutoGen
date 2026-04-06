// PurchaseHistoryView.swift
struct PurchaseHistoryView: View {
    var body: some View {
        List {
            ForEach(groupedPurchases, id: \.key) { monthYear, transactions in
                Section {
                    // ACCESSIBILITY: Month header
                    Text(monthYear)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityHeading(.h3)
                        .accessibilityLabel(
                            dateFormatter.string(from: monthYear)
                        ) // "April 2025"
                    
                    ForEach(transactions) { transaction in
                        HStack {
                            // Feature name
                            VStack(alignment: .leading) {
                                Text(transaction.featureName)
                                    .accessibilityLabel(transaction.featureName)
                                
                                Text(transaction.dateFormatted)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .accessibilityHidden(true) // Handled by parent
                            }
                            
                            Spacer()
                            
                            // Status badge with accessible label
                            Group {
                                switch transaction.status {
                                case .completed:
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .accessibilityLabel(
                                            NSLocalizedString(
                                                "purchase.status.completed",
                                                comment: "Transaction completed"
                                            ) // "Abgeschlossen"
                                        )
                                
                                case .pending:
                                    ProgressView()
                                        .accessibilityLabel(
                                            NSLocalizedString(
                                                "purchase.status.pending",
                                                comment: "Transaction pending"
                                            ) // "Verarbeitung läuft"
                                        )
                                
                                case .refunded:
                                    Image(systemName: "arrow.uturn.left.circle.fill")
                                        .foregroundColor(.orange)
                                        .accessibilityLabel(
                                            NSLocalizedString(
                                                "purchase.status.refunded",
                                                comment: "Transaction refunded"
                                            ) // "Erstattet"
                                        )
                                }
                            }
                            .accessibilityAddTraits(.isButton)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityValue(
                            String(
                                format: NSLocalizedString(
                                    "purchase.voiceover.value",
                                    comment: "Transaction price and date"
                                ),
                                transaction.formattedPrice,
                                transaction.dateFormatted
                            ) // "€4,99, 15. April 2025"
                        )
                        .onTapGesture {
                            showDetails(transaction)
                        }
                        .contextMenu {
                            if transaction.canRefund {
                                Button(
                                    role: .destructive,
                                    action: { refund(transaction) }
                                ) {
                                    Label(
                                        NSLocalizedString(
                                            "purchase.refund",
                                            comment: "Refund action"
                                        ), // "Rückgängig machen"
                                        systemImage: "arrow.uturn.left"
                                    )
                                }
                                .accessibilityHint(
                                    String(
                                        format: NSLocalizedString(
                                            "purchase.refund.hint",
                                            comment: "Refund window info"
                                        ),
                                        transaction.daysUntilRefundExpires
                                    ) // "Verfügbar für 9 weitere Tage"
                                )
                            } else {
                                Text(
                                    NSLocalizedString(
                                        "purchase.refund.expired",
                                        comment: "Refund window closed"
                                    ) // "Zeitfenster abgelaufen"
                                )
                                .foregroundColor(.secondary)
                                .accessibilityLabel(
                                    NSLocalizedString(
                                        "purchase.refund.unavailable",
                                        comment: "Cannot refund"
                                    )
                                )
                            }
                        }
                    }
                } header: {
                    // Handled in section content above
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            NSLocalizedString(
                "purchase.history.title",
                comment: "Purchase history screen"
            ) // "Kaufverlauf"
        )
        .accessibilityHint(
            String(
                format: NSLocalizedString(
                    "purchase.history.hint",
                    comment: "Total purchases"
                ),
                totalPurchaseCount
            ) // "Sie haben X Käufe getätigt"
        )
    }
}