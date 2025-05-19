TAGS = {
    "rhel8": "-ubi8",
    "rhel9": "-ubi9",
    "rhel10": "-ubi10",
}

def is_test_allowed(os, version):
    if os == "rhel8" and version == "5.26":
        return True
    if os == "rhel8" and version == "5.32":
        return True
    if os == "rhel9" and version == "5.32":
        return True
    if os == "rhel10" and version == "5.40":
        return True
    return False