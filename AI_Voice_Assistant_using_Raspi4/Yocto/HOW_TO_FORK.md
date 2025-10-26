# How to Fork Repositories on GitHub - Step by Step

## 🎯 Quick Summary

You need to fork **5 repositories** to preserve your modifications.

---

## 📋 **The 5 Repositories to Fork:**

1. https://github.com/yoctoproject/poky
2. https://github.com/openembedded/meta-openembedded
3. https://github.com/agherzan/meta-raspberrypi
4. https://github.com/NobuoTsukamoto/meta-onnxruntime
5. https://github.com/NobuoTsukamoto/meta-tensorflow-lite

---

## 🔧 **Step-by-Step Process:**

### **For Each Repository:**

#### **Step 1: Open the Repository**

Click on the link or copy-paste into your browser:
```
https://github.com/yoctoproject/poky
```

#### **Step 2: Click "Fork" Button**

- Look at the **top-right** corner of the page
- You'll see: `[Watch] [Fork] [Star]` buttons
- Click the **"Fork"** button

#### **Step 3: Configure Fork Settings**

A page will appear with fork settings:

**IMPORTANT Settings:**

1. **Owner:** Select `ahmedferganey` (your account)

2. **Repository name:** Leave as-is (e.g., `poky`)

3. **Description:** (optional) You can add: "Fork for AI Voice Assistant project"

4. **Copy the default branch only:** 
   - ⚠️ **UNCHECK THIS BOX!**
   - ❌ Leave it UNCHECKED
   - This ensures ALL branches (including `kirkstone`) are copied

5. Click **"Create fork"** button (green button at bottom)

#### **Step 4: Wait for Fork to Complete**

- GitHub will create the fork (takes 10-30 seconds)
- You'll be redirected to your new fork
- URL will be: `https://github.com/ahmedferganey/poky`

#### **Step 5: Verify Fork**

Check that:
- ✅ Repository is under your account: `github.com/ahmedferganey/poky`
- ✅ It shows: "forked from yoctoproject/poky"
- ✅ Branches exist: Click "branches" and verify `kirkstone` exists

---

## 📝 **Detailed Instructions for All 5:**

### **1. Fork: yoctoproject/poky**

```
1. Open: https://github.com/yoctoproject/poky
2. Click "Fork" (top right)
3. UNCHECK "Copy the default branch only"
4. Click "Create fork"
5. Result: https://github.com/ahmedferganey/poky
```

**Why:** Your poky has modifications to .gitignore and core-image-base.bb

---

### **2. Fork: openembedded/meta-openembedded**

```
1. Open: https://github.com/openembedded/meta-openembedded
2. Click "Fork"
3. UNCHECK "Copy the default branch only"
4. Click "Create fork"
5. Result: https://github.com/ahmedferganey/meta-openembedded
```

**Why:** You have modified flatbuffers and opencv recipes

---

### **3. Fork: agherzan/meta-raspberrypi**

```
1. Open: https://github.com/agherzan/meta-raspberrypi
2. Click "Fork"
3. UNCHECK "Copy the default branch only"
4. Click "Create fork"
5. Result: https://github.com/ahmedferganey/meta-raspberrypi
```

**Why:** You have custom Linux kernel 6.6 recipes

---

### **4. Fork: NobuoTsukamoto/meta-onnxruntime**

```
1. Open: https://github.com/NobuoTsukamoto/meta-onnxruntime
2. Click "Fork"
3. (This one might not have multiple branches, but fork anyway)
4. Click "Create fork"
5. Result: https://github.com/ahmedferganey/meta-onnxruntime
```

**Why:** You modified layer.conf

---

### **5. Fork: NobuoTsukamoto/meta-tensorflow-lite**

```
1. Open: https://github.com/NobuoTsukamoto/meta-tensorflow-lite
2. Click "Fork"
3. (Fork with default settings)
4. Click "Create fork"
5. Result: https://github.com/ahmedferganey/meta-tensorflow-lite
```

**Why:** You modified layer.conf and removed flatbuffers bbappend

---

## ✅ **Verification Checklist:**

After forking all 5, verify you have:

- [ ] https://github.com/ahmedferganey/poky
- [ ] https://github.com/ahmedferganey/meta-openembedded
- [ ] https://github.com/ahmedferganey/meta-raspberrypi
- [ ] https://github.com/ahmedferganey/meta-onnxruntime
- [ ] https://github.com/ahmedferganey/meta-tensorflow-lite

---

## 🚀 **After Forking All 5:**

Run the setup script:

```bash
cd /media/fragello/06c3ca26-00fe-4e3b-8a98-931188810fc9/00_Embedded/AutonomousVehiclesprojects/AI_Voice_Assistant_using_Raspi4/Yocto

./setup_submodules_safe.sh
```

---

## 💡 **Tips:**

### **If Fork Button Says "You already forked this"**

- You've already forked it before
- Click to go to your existing fork
- Verify it's there and proceed

### **If Repository Doesn't Exist**

Some repositories might have been moved or renamed:
- The script will show an error
- We can update the URL to the correct location

### **Authentication**

Make sure you're **logged into GitHub** before forking!

---

## ⏱️ **Time Estimate:**

- **Per fork:** 1-2 minutes
- **Total for 5 forks:** 5-10 minutes
- Very straightforward process!

---

## 🎓 **What is a Fork?**

A **fork** creates a **copy** of a repository under your GitHub account:

```
Original:  github.com/yoctoproject/poky
Your Fork: github.com/ahmedferganey/poky
           ↑ Your own copy where you can push changes
```

Benefits:
- ✅ You can push your modifications
- ✅ You control the version
- ✅ Original repository stays pristine
- ✅ You can pull updates from original anytime

---

## 📸 **Visual Guide:**

### **What the Fork Button Looks Like:**

```
┌─────────────────────────────────────────┐
│  yoctoproject / poky                    │
│  ───────────────────────────────────    │
│  [🔔 Watch]  [🍴 Fork]  [⭐ Star]       │  ← Click "Fork"
└─────────────────────────────────────────┘
```

### **Fork Configuration Page:**

```
┌────────────────────────────────────────────┐
│  Create a new fork                         │
│                                            │
│  Owner:  [ahmedferganey ▼]                │
│  Repository name: [poky          ]        │
│  Description: (optional)                   │
│                                            │
│  [ ] Copy the default branch only         │  ← UNCHECK THIS!
│      ↑ Make sure this is UNCHECKED        │
│                                            │
│  [    Create fork    ]  ← Click this      │
└────────────────────────────────────────────┘
```

---

## ❓ **Need Help?**

If you encounter any issues:

1. **"Repository not found"** → Check the URL is correct
2. **"Fork failed"** → Try refreshing and forking again
3. **"Already forked"** → Good! Go to your existing fork
4. **Authentication issues** → Make sure you're logged in

---

## 📌 **Quick Reference Card:**

Copy this and keep it open:

```
FORK #1: https://github.com/yoctoproject/poky
FORK #2: https://github.com/openembedded/meta-openembedded
FORK #3: https://github.com/agherzan/meta-raspberrypi
FORK #4: https://github.com/NobuoTsukamoto/meta-onnxruntime
FORK #5: https://github.com/NobuoTsukamoto/meta-tensorflow-lite

For each:
1. Open URL
2. Click "Fork"
3. UNCHECK "Copy the default branch only"
4. Click "Create fork"
5. Wait ~30 seconds
```

---

**Ready? Start with the first one:** https://github.com/yoctoproject/poky

Good luck! 🍀

