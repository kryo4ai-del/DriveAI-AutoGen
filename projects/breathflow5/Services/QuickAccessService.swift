protocol QuickAccessService {
       func resolveNavigationPath(
           from accessPoint: AccessPoint,
           userState: UserState
       ) async throws -> NavigationPath
       
       func createLaunchContext(
           for path: NavigationPath
       ) async throws -> QuizLaunchContext
       
       func trackAccessPoint(_ point: AccessPoint)
   }