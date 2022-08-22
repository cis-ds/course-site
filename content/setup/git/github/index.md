---
date: "2018-09-09T00:00:00-05:00"
draft: false
weight: 50
title: "Setup Git and GitHub"
toc: true
type: book
aliases: ["/git04.html", "/setup/github/"]
---



**You only have to do this once per machine.**

## Make a repository in GitHub

* Go to [GitHub.com](https://www.github.com) and login.
* Click the green "New Repository" button
    * Repository name: `myrepo`
    * Public
    * Check **Initialize this repository with a README**
    * Click the green "Create repository" button
* Copy the HTTPS clone URL to your clipboard via the green "Clone or Download" button.

## Clone the repository to your computer

* Go to the [shell](/setup/shell/) (one way to open: In RStudio, **Tools > Shell**).
* Determine where you are in the file directory (`pwd`). `cd` to move around. You can clone this repository wherever you want, though eventually you'll want to develop a system for storing your repos in a consistent manner. Here, I stored mine in `/Users/benjamin/Github/`.
* Clone `myrepo` from GitHub to your computer. Cloning simply downloads a copy of the repository to your computer. Remember the URL you copied? It should contain your GitHub username and the name of your practice repository. Either copy + paste the URL into your shell, or if the clipboard doesn't work retype it manually. Make sure it is accurate.


```bash
git clone https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git
```

Your output should look like this:

```{}
benjamin-laptop:Github benjamin$ git clone https://github.com/bensoltoff/myrepo.git
Cloning into 'myrepo'...
remote: Counting objects: 3, done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (3/3), done.
Checking connectivity... done.
```

* Make this new repository your working directory, list its files, display the README, and get some information on its connection to GitHub.


```bash
cd myrepo
ls
less README.md            # press [q] to quit
git remote show origin
```

This should look something like:

```{}
benjamin-laptop:Github benjamin$ cd myrepo

benjamin-laptop:myrepo benjamin$ ls
README.md

benjamin-laptop:myrepo benjamin$ less README.md
# myrepo
README.md (END)

benjamin-laptop:myrepo benjamin$ git remote show origin
* remote origin
  Fetch URL: https://github.com/bensoltoff/myrepo.git
  Push  URL: https://github.com/bensoltoff/myrepo.git
  HEAD branch: main
  Remote branch:
    main tracked
  Local branch configured for 'git pull':
    main merges with remote main
  Local ref configured for 'git push':
    main pushes to main (up to date)
```

## Make a local change, commit, and push

* Add a line to README and verify that Git notices the change:


```bash
echo "A line I wrote on my local computer" >> README.md
git status
```

```
benjamin-laptop:myrepo benjamin$ echo "A line I wrote on my local computer" >> README.md
benjamin-laptop:myrepo benjamin$ git status
On branch main
Your branch is up-to-date with 'origin/main'.
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   README.md

no changes added to commit (use "git add" and/or "git commit -a")
```

* Commit this change and push to your remote repo on GitHub.


```bash
git add -A
git commit -m "A commit from my local computer"
git push
```

This should look like:

```{}
benjamin-laptop:myrepo benjamin$ git add -A

benjamin-laptop:myrepo benjamin$ git commit -m "A commit from my local computer"
[main 33bb99f] A commit from my local computer
 1 file changed, 1 insertion(+), 1 deletion(-)
 
benjamin-laptop:myrepo benjamin$ git push
Counting objects: 3, done.
Writing objects: 100% (3/3), 294 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To https://github.com/bensoltoff/myrepo.git
   d72645a..33bb99f  main -> main
```

If you have never pushed a commit to GitHub, you will be challenged to enter your username and password. Do this.

## Confirm the local change propagated to the GitHub remote

* Go back to the browser. Make sure you're still viewing your `myrepo` GitHub repository.
* Refresh the page.
* You should see the new line "A line I wrote on my local computer" in the README.
* If you click on "Commits" you should see one with the message "A commit from my local computer."

## Authenticating with GitHub for each push

While the need to authenticate users is obvious (if there was no authentication, anyone could upload changes to your repository), it can be tedious to enter your username and password every time you want to push a change to GitHub. Fortunately there are a couple different options for caching your credentials which we will review [here](/setup/git-configure/#cache-credentials).

## Clean up

Since this was simply a test, there is no need to keep `myrepo`. Because we stored the repo on both our computer and GitHub, we need to remove it from both locations.

* Delete the local repository in the shell:


```bash
cd ..
rm -rf myrepo/
```

* Delete the repository from GitHub:
    * In the browser, viewing your repository's landing page on GitHub, click on "Settings", near the bottom of the right sidebar.
    * Scroll down, click on "Delete this repository", and follow the instructions

## Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).
