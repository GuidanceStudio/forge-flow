# Threat model

The repository is public and its `forge-flow/` folder is copied onto other people's
machines, where an assistant follows it as instructions. Content crosses from the
maintainer's machine to the public remote, and from the remote to the reader's
assistant; the CI workflow crosses from a pushed or proposed change to a hosted runner.

### THREAT-LEAK
Asset: names, hosts, paths and identifiers of work outside forge-flow. STRIDE: information disclosure.
A commit puts a machine path or a foreign project identifier into a file that ships.
Control: the rule in `CLAUDE.md` and the staged-diff grep before every commit; DEC-1
keeps name matching manual. Verify `RepoSecurityTests.test_tracked_files_carry_no_machine_paths`
for the generic part (home-directory paths), and the manual grep for names.

### THREAT-MUTABLE-REF
Asset: the instructions an assistant follows after installation. STRIDE: tampering.
An install route fetches a moving branch, so the instructions change after the reader
reviewed them. Control: the README installs from a tag or commit, never `main`.
Verify `RepoSecurityTests.test_readme_install_routes_do_not_track_main`.

### THREAT-CI-TOKEN
Asset: the repository and its default-branch history. STRIDE: elevation of privilege.
A workflow with a write-capable token or a privileged trigger lets a proposed change
or a compromised action push to the repository. Control: the workflow declares
read-only contents permission, uses `pull_request` and references no secrets.
Verify `RepoSecurityTests.test_workflow_is_read_only_and_secretless`.
