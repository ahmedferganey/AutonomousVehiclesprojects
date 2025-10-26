# Guide: Preserve Your Modifications in Git Submodules

This guide explains how to convert your existing Yocto layers (with modifications) into git submodules while preserving all your custom changes.

## 🎯 Your Situation

You have:
- ✅ Existing Yocto layers in `Yocto_sources/` (poky, meta-openembedded, etc.)
- ✅ **Custom modifications** inside these layers
- ✅ Want to use git submodules for version control
- ✅ Need to preserve all your changes

## 🚀 Automated Solution

We've created `convert_to_submodules.sh` to handle this automatically.

### Step 1: Update the Script

Edit `convert_to_submodules.sh` and set your GitHub username:

```bash
# Line 24 - UPDATE THIS!
GITHUB_USERNAME="ahmedferganey"
```

### Step 2: Run the Conversion Script

```bash
cd /media/fragello/06c3ca26-00fe-4e3b-8a98-931188810fc9/00_Embedded/AutonomousVehiclesprojects/AI_Voice_Assistant_using_Raspi4/Yocto

./convert_to_submodules.sh
```

### What the Script Does

For **each layer** (poky, meta-openembedded, etc.):

1. **Detects modifications**
   - Checks if it's a git repository
   - Identifies uncommitted changes
   - Counts custom commits

2. **Offers options:**
   - **Push to your fork** (preserves modifications)
   - Use upstream (discards modifications)
   - Skip for manual handling

3. **Sets up submodule:**
   - Creates git repository if needed
   - Commits any uncommitted changes
   - Pushes to your GitHub fork
   - Adds as git submodule

---

## 📋 Manual Process (Alternative)

If you prefer manual control:

### Step 1: Fork Repositories on GitHub

For each layer you've modified, create a fork:

1. Go to the original repository:
   - Poky: https://git.yoctoproject.org/poky
   - meta-openembedded: https://github.com/openembedded/meta-openembedded
   - meta-raspberrypi: https://github.com/agherzan/meta-raspberrypi
   - etc.

2. Click "Fork" → Create fork in your account

3. Copy your fork URL:
   ```
   https://github.com/ahmedferganey/poky.git
   https://github.com/ahmedferganey/meta-openembedded.git
   ```

### Step 2: Push Your Modifications

For **each modified layer**:

```bash
cd AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky

# Check if it's a git repo
if [ ! -d ".git" ]; then
    git init
    git checkout -b kirkstone-custom
fi

# Add remote to your fork
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/ahmedferganey/poky.git

# Commit any uncommitted changes
git add .
git commit -m "Custom modifications for AI Voice Assistant project"

# Push to your fork
git branch -M kirkstone-custom
git push -u origin kirkstone-custom
```

Repeat for each modified layer (meta-openembedded, meta-raspberrypi, etc.)

### Step 3: Remove Old Directories

```bash
cd /media/fragello/06c3ca26-00fe-4e3b-8a98-931188810fc9/00_Embedded/AutonomousVehiclesprojects

# Backup first (optional)
mv AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources \
   AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources.backup

# Or remove entirely (after confirming your forks are pushed)
# rm -rf AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources
```

### Step 4: Add as Submodules (Using Your Forks)

```bash
cd /media/fragello/06c3ca26-00fe-4e3b-8a98-931188810fc9/00_Embedded/AutonomousVehiclesprojects

# For modified layers - use YOUR forks
git submodule add -b kirkstone-custom \
    https://github.com/ahmedferganey/poky.git \
    AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky

git submodule add -b kirkstone-custom \
    https://github.com/ahmedferganey/meta-openembedded.git \
    AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/meta-openembedded

# For unmodified layers - use upstream
git submodule add -b kirkstone \
    https://github.com/agherzan/meta-raspberrypi.git \
    AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/meta-raspberrypi

git submodule add -b kirkstone \
    https://git.yoctoproject.org/meta-virtualization \
    AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/meta-virtualization

git submodule add -b kirkstone \
    https://code.qt.io/yocto/meta-qt6.git \
    AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/meta-qt6
```

### Step 5: Commit Submodules

```bash
git add .gitmodules AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/
git commit -m "Add Yocto layers as submodules (with custom modifications)"
git push origin main
```

---

## 🔄 Workflow After Conversion

### Making Changes to a Submodule

```bash
# Navigate to the submodule
cd AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky

# Make sure you're on a branch (not detached HEAD)
git checkout kirkstone-custom

# Make your changes
echo "# Custom change" >> some-file.txt
git add some-file.txt
git commit -m "Add custom change"

# Push to your fork
git push origin kirkstone-custom

# Go back to main repo
cd /media/fragello/06c3ca26-00fe-4e3b-8a98-931188810fc9/00_Embedded/AutonomousVehiclesprojects

# Update the submodule reference
git add AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky
git commit -m "Update poky submodule to latest custom changes"
git push origin main
```

### Updating Submodules

```bash
# Update all submodules to latest on tracked branch
git submodule update --remote --recursive

# Or update specific submodule
git submodule update --remote AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky

# Commit the updates
git add AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/
git commit -m "Update Yocto layers to latest versions"
```

### Pulling Project with Submodules

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/ahmedferganey/AutonomousVehiclesprojects.git

# Or if already cloned
git pull
git submodule update --init --recursive
```

---

## 📦 Recommended Structure

```
Modified Layers (use YOUR forks):
├── poky → https://github.com/ahmedferganey/poky.git (branch: kirkstone-custom)
├── meta-openembedded → YOUR_FORK if modified
└── (any layer you modified)

Unmodified Layers (use upstream):
├── meta-raspberrypi → https://github.com/agherzan/meta-raspberrypi.git (branch: kirkstone)
├── meta-virtualization → https://git.yoctoproject.org/meta-virtualization (branch: kirkstone)
├── meta-qt6 → https://code.qt.io/yocto/meta-qt6.git (branch: kirkstone)
└── (any pristine layer)
```

---

## 🛡️ Best Practices

### 1. **Use Custom Branches**
- Name your branches clearly: `kirkstone-custom`, `kirkstone-voice-assistant`
- Don't use `main`/`master` for your modifications

### 2. **Document Changes**
- Keep a MODIFICATIONS.md in each forked layer
- List what you changed and why

### 3. **Prefer meta-userapp**
- Put customizations in `meta-userapp` when possible
- Only modify external layers when absolutely necessary

### 4. **Stay Synchronized**
- Periodically merge upstream changes into your forks
- Test thoroughly after updates

### 5. **Branch Naming**
```bash
upstream/kirkstone → your-fork/kirkstone-voiceassistant
upstream/dunfell  → your-fork/dunfell-voiceassistant
```

---

## ❓ Troubleshooting

### "Permission denied" when pushing

```bash
# Make sure you've created the repository on GitHub first
# Then try again with the correct URL
git remote set-url origin https://github.com/ahmedferganey/REPO_NAME.git
git push -u origin kirkstone-custom
```

### "Submodule already exists"

```bash
# Remove from git but keep files
git rm --cached AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky

# Remove the entry from .gitmodules
# Then add again
```

### "Detached HEAD" in submodule

```bash
cd AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky
git checkout kirkstone-custom
```

---

## 📚 See Also

- `SUBMODULES_GUIDE.md` - Complete submodules reference
- `configs/README.md` - Configuration management
- `setup_yocto.sh` - Build environment setup

---

## ⚡ Quick Start

**Fastest way to get started:**

```bash
cd /media/fragello/06c3ca26-00fe-4e3b-8a98-931188810fc9/00_Embedded/AutonomousVehiclesprojects/AI_Voice_Assistant_using_Raspi4/Yocto

# Edit and run the automated script
./convert_to_submodules.sh
```

The script will guide you through the process interactively! 🎉

