# Git Submodules Setup Guide

This guide explains how to add Yocto meta layers as git submodules.

## What Are Git Submodules?

Git submodules allow you to keep a Git repository as a subdirectory of another Git repository. This is perfect for Yocto layers, which are separate projects maintained by different teams.

## Benefits

✅ **Track specific versions** - Lock to stable versions of external layers  
✅ **Easy updates** - Update layers with `git submodule update --remote`  
✅ **Clean separation** - Your code vs. external dependencies  
✅ **Reproducible builds** - Everyone gets the same layer versions  

## Initial Setup (One-Time)

Run these commands from the **project root**:

```bash
cd /path/to/AutonomousVehiclesprojects

# Add Poky (core Yocto distribution)
git submodule add -b kirkstone https://git.yoctoproject.org/poky \
    AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky

# Add meta-openembedded (common layers)
git submodule add -b kirkstone https://github.com/openembedded/meta-openembedded.git \
    AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/meta-openembedded

# Add meta-raspberrypi (Raspberry Pi BSP)
git submodule add -b kirkstone https://github.com/agherzan/meta-raspberrypi.git \
    AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/meta-raspberrypi

# Add meta-virtualization (Docker support)
git submodule add -b kirkstone https://git.yoctoproject.org/meta-virtualization \
    AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/meta-virtualization

# Add meta-qt6 (Qt6 framework)
git submodule add -b kirkstone https://code.qt.io/yocto/meta-qt6.git \
    AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/meta-qt6

# Commit the submodules
git add .gitmodules AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/
git commit -m "Add Yocto meta layers as submodules"
```

## Cloning the Repository (For Others)

When someone clones your repository, they need to initialize submodules:

```bash
# Clone the main repo
git clone https://github.com/ahmedferganey/AutonomousVehiclesprojects.git
cd AutonomousVehiclesprojects

# Initialize and fetch all submodules
git submodule init
git submodule update --recursive

# Or do it in one command
git clone --recurse-submodules https://github.com/ahmedferganey/AutonomousVehiclesprojects.git
```

## Updating Submodules

### Update to Latest Commit in Tracked Branch

```bash
cd AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky
git pull origin kirkstone
cd ../../../../

# Or update all submodules at once
git submodule update --remote --recursive

# Commit the new submodule references
git add AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/
git commit -m "Update Yocto layers to latest kirkstone"
```

### Update to Specific Commit/Tag

```bash
cd AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky
git fetch
git checkout <commit-hash-or-tag>
cd ../../../../

git add AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky
git commit -m "Update poky to specific version"
```

## Checking Submodule Status

```bash
# Show submodule status
git submodule status

# Show submodule details
git submodule

# Show which commit each submodule is on
git submodule foreach 'echo "$path: $(git rev-parse HEAD)"'
```

## Common Issues & Solutions

### Issue: "Submodule not initialized"

```bash
git submodule init
git submodule update
```

### Issue: "Detached HEAD in submodule"

This is normal! Submodules track specific commits. To work on a submodule:

```bash
cd AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky
git checkout kirkstone  # Switch to branch
# Make changes...
git add .
git commit -m "Custom changes"
cd ../../../../
git add AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky
git commit -m "Update poky submodule"
```

### Issue: "Modified submodule content"

```bash
# Reset submodule to committed version
git submodule update --init --recursive

# Or discard changes
cd AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky
git reset --hard
cd ../../../../
```

## Best Practices

1. **Lock to stable branches/tags** - Use released versions (e.g., `kirkstone`, `dunfell`)
2. **Document versions** - Note which Yocto release you're using
3. **Test updates** - Always test after updating submodules
4. **Keep custom changes separate** - Use `meta-userapp` for customizations, not patches to external layers
5. **Use `.bbappend` files** - Extend external recipes without modifying them

## Yocto Release Branches

| Release   | Codename  | Release Date | Status      |
|-----------|-----------|--------------|-------------|
| 4.0 LTS   | kirkstone | April 2022   | Supported   |
| 3.4 LTS   | honister  | Oct 2021     | Maintained  |
| 3.1 LTS   | dunfell   | April 2020   | LTS Support |

Use LTS (Long Term Support) releases for production projects.

## Alternative: If You Modified External Layers

If you've made custom changes to `poky` or other meta layers that you want to track:

### Option 1: Fork the Repository

```bash
# Fork on GitHub: https://git.yoctoproject.org/poky -> Your fork

# Add as submodule using your fork
git submodule add -b kirkstone https://github.com/YOUR_USERNAME/poky \
    AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky
```

### Option 2: Use Patches

Keep a `patches/` directory with your modifications:

```bash
mkdir -p AI_Voice_Assistant_using_Raspi4/Yocto/patches
# Store .patch files here
# Apply with: git apply patches/my-changes.patch
```

## Next Steps

After adding submodules:

1. Run the setup script: `./setup_yocto.sh`
2. Build your image: See `configs/README.md`
3. Commit your changes: `git push`

## Resources

- [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Yocto Project Documentation](https://docs.yoctoproject.org/)
- [Yocto Layer Index](https://layers.openembedded.org/)

