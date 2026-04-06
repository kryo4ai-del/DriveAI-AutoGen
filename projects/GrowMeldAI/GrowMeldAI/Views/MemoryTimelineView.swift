// ✅ ACCESSIBLE
struct MemoryTimelineView: View {
    @StateObject private var vm: EpisodicMemoryViewModel
    @AccessibilityFocusState private var focusedMemoryId: String?
    
    var body: some View {
        VStack {
            if vm.recentMemories.isEmpty && !vm.isLoading {
                // Empty state
                Text("No memories yet. Keep learning!")
                    .accessibilityLabel("No memories yet. Keep learning!")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                        ForEach(vm.recentMemories) { memory in
                            MemoryCardView(memory: memory)
                                .id(memory.id)  // ✅ Stable identity for focus
                                .accessibilityFocused($focusedMemoryId, equals: memory.id)
                                .onAppear {
                                    // Load more, announce to VoiceOver
                                    vm.loadMoreIfNeeded(item: memory)
                                    
                                    // Announce when reaching end
                                    if memory.id == vm.recentMemories.last?.id {
                                        UIAccessibility.post(
                                            notification: .announcement,
                                            argument: "End of memories. Load more memories available."
                                        )
                                    }
                                }
                        }
                        
                        // Load more button (explicit, not hidden)
                        if vm.canLoadMore {
                            Button(action: { vm.loadMore() }) {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Load older memories")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            }
                            .accessibilityLabel("Load older memories")
                            .accessibilityHint("Fetches memories from previous weeks")
                        }
                        
                        // End of list indicator
                        if !vm.canLoadMore && !vm.recentMemories.isEmpty {
                            Text("You've reached the beginning of your memory timeline")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                                .accessibilityLabel("End of memories")
                                .accessibilityAddTraits(.isSummaryElement)
                        }
                    }
                }
            }
            
            // Loading state announcement
            if vm.isLoading {
                ProgressView()
                    .accessibilityLabel("Loading memories")
                    .accessibilityValue("Please wait")
                    .padding()
            }
        }
        .navigationTitle("Memory Timeline")
        .accessibilityAddTraits(.isScrollable)
    }
}