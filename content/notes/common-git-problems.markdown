---
title: "Recovering from common Git predicaments"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/git_more.html"]
categories: ["git", "project-management"]

menu:
  notes:
    parent: Project management
    weight: 6
---

## I don't want a bunch of these files committed

Which files should you commit in your Git repository, and which files are safe to ignore?

## What you should commit

* Source files - things like R Markdown (`.Rmd`), R scripts (`.R`), etc. These are almost always plain-text files which are very amenable to tracking changes in Git
* For R Markdown documents, also commit the rendered Markdown (`.md`) files. GitHub automatically renders `.md` files on the website, so you don't need to commit the `.html` file in your repository
    * Unless you absolutely need the final output file stored in the repo. Perhaps the end result of your project will be an HTML report or a PDF (`.pdf`) document. If so, commit to your repository. **But make sure any time you change the source file you render and commit the final output too. Don't get these files out-of-sync.**
* Data files
    * These may be **plain-text files** like comma-separated files (`.csv`) or tab-separated files (`.tsv`). Plain-text files can be opened in any regular text editor and their contents viewed.
    * They may also be **binary** files, such as Excel spreadsheets (`.xlsx`), R data files (.`Rdata`), or feather files (`.feather`). Binary files cannot be viewed directly in a text editor, and must be opened by a specific software program such as R.
    * [GitHub requires data files to be under 100 megabytes](https://help.github.com/articles/conditions-for-large-files/). So as long as you meet that requirement, you can commit and store data files in your repository without a problem. If your data file is larger than that, you need to use a workaround which is introduced below.

## What you should not commit

* Temporary files - files such as `~$*.xls*` or `.utf8.md` that are generated only when a program is open (such as Microsoft Excel) or rendering a script (such as R rendering an R Markdown document)
* Log files - `.log`
* Files with private details - for example, [`.Rprofile` which contains proprietary API keys](/notes/application-program-interface/#api-authentication). Access to these files should be restricted only to you and no one else. Keep them out of your repository
* Any file greater than 100 megabytes - see above

## How to use `.gitignore`

`.gitignore` is a special file inside a Git repository that tells Git specific types of files/directories that should be **ignored**. The name is literally `.gitignore`. The period at the beginning tells the computer it is a special **system file**. Typically these files are hidden inside File Explorer or Finder.

Any file or directory identified in `.gitignore` cannot be staged or committed to the repository. When you first create a repository on GitHub, you have the option to initialize the repo with a `.gitignore` template. For instance, the template for R is this:

```
# History files
.Rhistory
.Rapp.history

# Session Data files
.RData

# User-specific files
.Ruserdata

# Example code in package build process
*-Ex.R

# Output files from R CMD build
/*.tar.gz

# Output files from R CMD check
/*.Rcheck/

# RStudio files
.Rproj.user/

# produced vignettes
vignettes/*.html
vignettes/*.pdf

# OAuth2 token, see https://github.com/hadley/httr/releases/tag/v0.3
.httr-oauth

# knitr and R markdown default cache directories
*_cache/
/cache/

# Temporary files created by R markdown
*.utf8.md
*.knit.md
```

You can modify this file in RStudio to include additional arguments. If we wanted to exclude any `.log` files, we could add a new line:

```
*.log
```

The `*` tells the computer to identify any file regardless of what its name starts with, as long as it ends in `.log`. Or if there was a directory called `temp` containing only temporary files that are safe to ignore, we could add

```
temp/
```

to exclude that folder from the Git repository.

## Committing large data files

Because of how Git tracks changes in files, GitHub will not allow you to commit and push a file larger than 100mb. If you try to do so, you will get an error message and the commit will not push. Worse yet, you now have to find a way to strip all trace of the data file from the Git repo (including previous commits) before you can sync up your fork. This is a pain in the ass. Avoid it as much as possible. If you follow option 1 and 2, then you do not need to store the data file in the repo because it is automatically downloaded by your script/R Markdown document.

If you have to store a large data file in your repo, use [**Git Large File Storage**](https://git-lfs.github.com/). It is a separate program you need to install via the shell, but the instructions are straight-forward. It integrates smoothly into GitHub, and makes version tracking of large files far easier. If you include it in a course-related repo (i.e. a fork of the homework repos), then there is no cost. If you want to use Git LFS for your own work, [there are separate fees charged by GitHub for storage and bandwidth usage.](https://help.github.com/articles/about-storage-and-bandwidth-usage/)

## Accidentially added a large data file

Say you added a file to your repo called `large_file.csv` which is 125 megabytes. Furthermore, you did not setup Git LFS for the repo. If you attempt to commit and push this file to GitHub, you will get the following error:

```shell
remote: warning: Large files detected.
remote: error: File giant_file is 125.00 MB; this exceeds GitHub's file size limit of 100 MB
```

You need to remove this file from your repo, setup Git LFS, and then re-stage and commit the file before you can push to GitHub.

* [If your large file is in the most recent unpushed commit](https://help.github.com/articles/removing-files-from-a-repository-s-history/) - this is relatively easy to perform
* [If your large file is in an older unpushed commit](https://help.github.com/articles/removing-sensitive-data-from-a-repository/) - this is much harder to perform, but can be done

## Accidentally cloned from the master, not the fork

Make sure whenever you clone a homework repository, use the url for the forked version, not the master repository. So for the first homework, I would use `https://github.com/bensoltoff/hw01` when I clone the repo, not `https://github.com/uc-cfss/hw01`. If you use the master repo url, you will get an error when you try to push your changes to GitHub.

For an example, let's say I wanted to make a contribution to [`ggplot2`](https://github.com/hadley/ggplot2). I should fork the repo and clone the fork. Instead I goofed and cloned the original repo. When I try to push my change, I get an error message:

```bash
remote: Permission to hadley/ggplot2.git denied to bensoltoff.
fatal: unable to access 'https://github.com/hadley/ggplot2.git/': The requested URL returned error: 403
```

I don't have permission to edit the master repo on Hadley Wickham's account.

How do I fix this? I could go back and clone the correct fork, but if I've already made several commits then I'll lose all my work. Instead, I can change the `upstream` url: this changes the location Git tries to push my changes. To do this:

1. Open up the [shell](/setup/shell/)
1. Change the current working directory to your local project (should use the `cd` command)
1. List your existing remotes in order to get the name of the remote you want to change.
    ```bash
    git remote -v
    ```
    
    ```bash
    origin	https://github.com/hadley/ggplot2.git (fetch)
    origin	https://github.com/hadley/ggplot2.git (push)
    ```
    
1. Change your remote's URL to the fork with the `git remote set-url` command.
    ```bash
    git remote set-url origin https://github.com/bensoltoff/ggplot2.git
    ```
    
1. Verify that the remote URL has changed.
    ```bash
    git remote -v
    ```
    
    ```bash
    origin	https://github.com/bensoltoff/ggplot2 (fetch)
    origin	https://github.com/bensoltoff/ggplot2 (push)
    ```

Now I can push successfully to my fork, then submit a pull request.

## Resetting from my last commit

What do you need to do if you want to undo your last commit? Use the following [shell](/setup/shell/) commands:

### Undo it completely

```bash
git reset --hard HEAD^
```

This rolls back your repository to the previous commit - any changes not reflected in the commit-before-last will be lost **forever**.

### Undo the commit, but leave the files in that state (but unstaged)

```bash
git reset HEAD^
```

This rolls back your repository to the previous commit - any changes not reflected in the commit-before-last will remain but the commit will be undone and nothing will be staged.

### Undo the last commit, but leave the files in that state and staged

```bash
git reset --soft HEAD^
```

This rolls back your repository to the previous commit - any changes not reflected in the commit-before-last will remain as staged changes. If you had any changes staged but not committed prior to the reset, these will also still remain.

### I just want to fiddle with the most recent commit or its message

You can [**amend**](https://www.atlassian.com/git/tutorials/rewriting-history) it from within RStudio. Amending a commit allows you to change the contents or message of the commit without creating a new commit. This is a powerful tool, but be careful. Once you push a commit to GitHub, you cannot amend it. Doing so will create an error the next time you try and push to GitHub.

To amend from the command line:

```bash
git commit --amend -m "New commit message"
```

## Merge conflicts

[Merge conflicts](https://help.github.com/articles/about-merge-conflicts/) occur when there are differences between merged files. When the changes are on different lines or in different files, Git will usually fix the problem itself. But sometimes Git needs manual intervention to solve a conflict, such as one person modifying a file and another person deleting that same file, or two people independently modifying the same line of a file. In that situation, you need to resolve the conflict before you can incorporate your unpushed commits.

Fortunately Git will tell you of these problems when a merge conflict occurs. Follow [these steps](https://help.github.com/articles/resolving-a-merge-conflict-using-the-command-line/) to resolve the merge conflict.

## Burn it all down

![[Git (via xkcd)](https://xkcd.com/1597/)](https://imgs.xkcd.com/comics/git.png)

While Git can be simple to work with at times, it can also be extremely frustrating. Once errors are introduced into a repository, sometimes it proves exceedingly difficult to fix the repository. The most drastic solution is to start over. If you are [committing early and often](https://sethrobertson.github.io/GitBestPractices/#commit), this is not necessarily a terrible solution.

1. Commit early and often as you revise and update your project
1. Push regularly to GitHub
1. Each successful push results in a new "worst case scenario"
1. If you screw things up badly on your local machine, copy all the files in your repo to a safe place on your computer (i.e. a new folder)
1. Rename the existing local repository as a temporary measure
1. Clone the repository from GitHub to your local machine. This version of the repository works as intended
1. Copy all relevant files back over from your safe space. That is, the ones whose updated state you need to commit
1. Stage, commit, and push

### Acknowledgements

* Inspired by Jenny Bryan's [*Happy Git with R*](http://happygitwithr.com/) and corresponding [tweet](https://twitter.com/JennyBryan/status/743457387730735104)
