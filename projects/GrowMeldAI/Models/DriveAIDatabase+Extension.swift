// Core/Database/Migrations/v2_CreateABTestTables.swift
import SQLite3

extension DriveAIDatabase {
    func migrateToV2_ABTesting() throws {
        // Create tables
        try execute("""
        CREATE TABLE IF NOT EXISTS ab_tests (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            active BOOLEAN DEFAULT 1,
            variants_json TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
        );
        """)
        
        try execute("""
        CREATE TABLE IF NOT EXISTS ab_results (
            id TEXT PRIMARY KEY,
            test_id TEXT NOT NULL,
            variant_id TEXT NOT NULL,
            user_id_hash TEXT NOT NULL,
            outcome TEXT NOT NULL,
            metadata_json TEXT,
            timestamp INTEGER NOT NULL,
            FOREIGN KEY (test_id) REFERENCES ab_tests(id) ON DELETE CASCADE
        );
        """)
        
        try execute("""
        CREATE TABLE IF NOT EXISTS ab_assignments (
            test_id TEXT PRIMARY KEY,
            variant_id TEXT NOT NULL,
            assigned_at INTEGER NOT NULL
        );
        """)
        
        // Create indices for query performance
        try execute("""
        CREATE INDEX IF NOT EXISTS idx_ab_results_test_variant
        ON ab_results(test_id, variant_id);
        """)
        
        try execute("""
        CREATE INDEX IF NOT EXISTS idx_ab_results_user
        ON ab_results(user_id_hash);
        """)
    }
}

// In DriveAIDatabase.swift, add to migration handler:
private func runMigrations() throws {
    let currentVersion = schemaVersion()
    
    if currentVersion < 2 {
        try migrateToV2_ABTesting()
        updateSchemaVersion(to: 2)
    }
}