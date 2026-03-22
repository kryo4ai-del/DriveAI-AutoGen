protocol QuickAccessService {
       func resolveNavigationPath(
           from accessPoint: Any,
           userState: UserState
       ) async throws -> Any
       
       func createLaunchContext(
           for path: Any
       ) async throws -> QuizLaunchContext
       
       func trackAccessPoint(_ point: Any)
   }