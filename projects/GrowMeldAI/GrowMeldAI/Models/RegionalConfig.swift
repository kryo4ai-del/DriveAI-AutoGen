struct RegionalConfig {
    let region: Region // .germany, .australia, .canada
    let authority: String // "TÜV", "VicRoads", "MTO"
    let language: String // "de", "en-AU", "en-CA"
    let privacyPolicyURL: URL
    let tosURL: URL
    let disclaimerText: String
  }