# GMG - Good Morning Git 🌅

A command-line utility to start your development day with updated repositories.

## Overview

GMG (Good Morning Git) is an enhanced git repository management tool that helps developers quickly update their repositories at the start of each day. It automatically handles local changes, performs clean updates, and provides comprehensive reporting.

## Features

- 🔍 **Smart Change Detection**: Automatically detects and stashes local changes
- 🔄 **Clean Updates**: Uses `git pull --rebase` for clean commit history
- 📦 **Safe Stashing**: Automatically stashes and reapplies local changes
- 🎯 **Flexible Targeting**: Update single repositories or entire folders
- 📊 **Comprehensive Reporting**: Detailed status reports and error handling
- ⚡ **Fast Execution**: Efficient batch processing of multiple repositories

## Installation

1. Copy the `gmg.bat` file to a directory in your PATH, or
2. Create a shortcut to `gmg.bat` in a convenient location, or
3. Run directly from the `gmg-util` folder

## Usage

### Basic Commands

```cmd
# Update a specific repository
gmg -repo <repository-name>

# Update all repositories in a folder
gmg -folder <parent-folder-path>

# Show help information
gmg -help
```

### Examples

```cmd
# Update a single repository (relative path)
gmg -repo next-steps-idaho-2

# Update a single repository (absolute path)
gmg -repo "D:\Projects\my-app"

# Update all repositories in current folder
gmg -folder .

# Update all repositories in a specific folder
gmg -folder "D:\ParentFolder\Code"

# Update all repositories in a relative folder
gmg -folder "../other-projects"
```

## How It Works

For each repository, GMG performs these steps:

1. **🔍 Check for Changes**: Scans for uncommitted local changes
2. **📦 Stash if Needed**: Safely stashes any local modifications
3. **🔄 Fetch Updates**: Downloads latest changes from remote
4. **📈 Pull & Rebase**: Updates local branch with clean history
5. **📤 Restore Changes**: Reapplies previously stashed changes
6. **✅ Report Status**: Shows success/failure and final state

## Safety Features

- **Never Loses Work**: Local changes are always preserved via stashing
- **Conflict Detection**: Handles merge conflicts gracefully
- **Error Recovery**: Attempts to restore stashed changes on failure
- **Detailed Logging**: Shows exactly what happened in each repository
- **Rollback Support**: Provides recovery instructions when needed

## Output Symbols

- ✅ **Success**: Operation completed successfully
- ❌ **Error**: Operation failed
- ⚠️  **Warning**: Operation succeeded with caveats
- 📦 **Stash**: Local changes were stashed
- 📤 **Pop**: Stashed changes were reapplied
- 🔄 **Fetch**: Downloading remote changes
- 📈 **Rebase**: Updating with rebase
- 📋 **Status**: Repository status information

## Error Handling

GMG provides comprehensive error handling:

- **Repository Not Found**: Clear message with attempted path
- **Not a Git Repo**: Verification that target is actually a git repository
- **Stash Failures**: Detailed error reporting for stashing issues
- **Fetch/Pull Failures**: Network and merge conflict reporting
- **Recovery Instructions**: Step-by-step manual recovery when needed

## Return Codes

- `0`: All operations successful
- `1`: One or more repositories had errors
- `Exit codes match error count for automation scripts`

## Daily Workflow Integration

Add GMG to your daily startup routine:

1. **Morning Routine**: Run `gmg -folder .` in your main projects directory
2. **Project Switch**: Use `gmg -repo <name>` when switching between projects
3. **Pre-Development**: Ensure you're working with latest code before starting work

## Advanced Usage

### Batch Files Integration

Create project-specific batch files:

```cmd
@echo off
echo Starting work on NSI projects...
gmg -folder "D:\InTimeTec\NSI\Support"
pause
```

### Scheduled Tasks

Set up Windows scheduled tasks to run GMG automatically:

```cmd
# Task Scheduler command
gmg -folder "D:\Projects" > daily_update.log 2>&1
```

## Troubleshooting

### Common Issues

1. **"Repository not found"**: Check path spelling and existence
2. **"Not a git repository"**: Ensure the folder contains a `.git` directory
3. **"Failed to stash"**: May indicate file permission issues
4. **"Failed to reapply stash"**: Usually indicates merge conflicts

### Manual Recovery

If GMG fails to reapply stashed changes:

```cmd
cd <repository-path>
git stash list                    # See available stashes
git stash pop                     # Reapply most recent stash
git status                        # Check for conflicts
```

## Version History

- **v1.0.0**: Initial release with core functionality
  - Single repository updates
  - Folder-based bulk updates
  - Automatic stashing and recovery
  - Comprehensive error reporting

## Contributing

GMG is part of utilities. Suggestions and improvements are welcome!

---

**Good Morning Git** - Start your day right! 🌅☕