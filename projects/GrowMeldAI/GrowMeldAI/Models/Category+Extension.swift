// Core/Models/Category+Database.swift
extension Category: FetchableRecord, PersistableRecord {
    static let databaseTableName = "categories"
    
    init(row: Row) throws {
        self.id = UUID(uuidString: row["id"]) ?? UUID()
        self.name = row["name"]
        self.icon = row["icon"]
        self.description = row["description"]
        self.questionCount = row["question_count"]
    }
    
    func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id.uuidString
        container["name"] = name
        container["icon"] = icon
        container["description"] = description
        container["question_count"] = questionCount
    }
}

// Core/Models/Question+Database.swift
extension Question: FetchableRecord, PersistableRecord {
    static let databaseTableName = "questions"
    
    static let answers = hasMany(Answer.self, using: ForeignKey(["question_id"]))
    
    init(row: Row) throws {
        self.id = UUID(uuidString: row["id"]) ?? UUID()
        self.categoryID = UUID(uuidString: row["category_id"]) ?? UUID()
        self.text = row["text"]
        self.imageURL = row["image_url"]
        self.difficulty = .init(rawValue: row["difficulty"]) ?? .medium
        self.explanation = row["explanation"]
        self.correctAnswerID = UUID(uuidString: row["correct_answer_id"]) ?? UUID()
        self.answers = []  // Load via association
    }
    
    func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id.uuidString
        container["category_id"] = categoryID.uuidString
        container["text"] = text
        container["image_url"] = imageURL
        container["difficulty"] = difficulty.rawValue
        container["explanation"] = explanation
        container["correct_answer_id"] = correctAnswerID.uuidString
    }
}

// Core/Models/Answer+Database.swift
extension Answer: FetchableRecord, PersistableRecord {
    static let databaseTableName = "answers"
    
    init(row: Row) throws {
        self.id = UUID(uuidString: row["id"]) ?? UUID()
        self.text = row["text"]
    }
    
    func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id.uuidString
        container["text"] = text
    }
}