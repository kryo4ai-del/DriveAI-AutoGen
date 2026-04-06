class IDGenerator {
    var generateID: () -> String = { UUID().uuidString }
    
    // In tests:
    var idGenerator = IDGenerator()
    idGenerator.generateID = { "test-id-1" }
}