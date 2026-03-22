"""One-time migration: Create project.json for existing projects."""
if __name__ == "__main__":
    from factory.shared.project_registry import bootstrap_existing_projects
    bootstrap_existing_projects()
