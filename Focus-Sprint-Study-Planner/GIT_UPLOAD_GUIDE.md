# GitHub upload — commit-by-commit guide

Create an **empty** GitHub repository named `focus-sprint-study-planner`. Do not add a README, `.gitignore`, or license on GitHub because these files are already in this folder.

Open PowerShell in this folder and run the following commands in order. Replace the URL with your own GitHub repository URL.

## 1. Initialize the repository

```powershell
git init
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/focus-sprint-study-planner.git
```

## 2. Commit the project documentation and preview

```powershell
git add README.md GIT_UPLOAD_GUIDE.md screenshots/app-preview.png
git commit -m "docs: add project overview and app preview"
```

## 3. Commit the planner app

```powershell
git add Focus_Sprint_Study_Planner_PC.html
git commit -m "feat: add Focus Sprint study planner"
```

## 4. Commit the Windows launcher

```powershell
git add START_FOCUS_SPRINT.bat Start_Focus_Sprint.ps1
git commit -m "feat: add Windows launcher for the planner"
```

## 5. Commit Git ignore rules

```powershell
git add .gitignore
git commit -m "chore: ignore local runtime files and private backups"
```

## 6. Push all commits to GitHub

```powershell
git push -u origin main
```

## Check the commit history

```powershell
git log --oneline
```

If Git asks for your identity, set it once (use the name and email associated with your GitHub account):

```powershell
git config --global user.name "YOUR NAME"
git config --global user.email "YOUR GITHUB EMAIL"
```
