enum LLMError: Error {
       case badURL
       case networkError(Error)
       case invalidResponse
       case dataDecodingFailed
   }