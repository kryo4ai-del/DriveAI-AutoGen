enum class SortOption(val displayName: String, val a11yDescription: String) {
    COMPETENCE_ASC(
        "Lowest Score First",
        "Sort categories by competence ascending, showing your weakest areas first"
    ),
    COMPETENCE_DESC(
        "Highest Score First",
        "Sort categories by competence descending, showing your strongest areas first"
    ),
    NAME_ASC(
        "A to Z",
        "Sort categories alphabetically from A to Z"
    ),
    NAME_DESC(
        "Z to A",
        "Sort categories alphabetically from Z to A"
    ),
}
