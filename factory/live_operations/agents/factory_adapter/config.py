"""FactoryAdapter configuration."""

# Submission storage
SUBMISSIONS_DIR_NAME = "submissions"

# Submission statuses
STATUS_CREATED = "created"
STATUS_SUBMITTED = "submitted"        # Sent to Factory (STUB)
STATUS_ACCEPTED = "accepted"          # Factory confirmed receipt
STATUS_IN_PROGRESS = "in_progress"    # Factory is building
STATUS_COMPLETED = "completed"        # Factory build done
STATUS_FAILED = "failed"              # Factory rejected or build failed

# Valid transitions
VALID_TRANSITIONS = {
    STATUS_CREATED: [STATUS_SUBMITTED, STATUS_FAILED],
    STATUS_SUBMITTED: [STATUS_ACCEPTED, STATUS_FAILED],
    STATUS_ACCEPTED: [STATUS_IN_PROGRESS, STATUS_FAILED],
    STATUS_IN_PROGRESS: [STATUS_COMPLETED, STATUS_FAILED],
}

# Auto-submit threshold (severity above this = auto-submit)
AUTO_SUBMIT_SEVERITY = 80.0
