# uc-cfss.github.io

[![Netlify Status](https://api.netlify.com/api/v1/badges/10736f91-82cc-4e9b-87cc-21ae0f745739/deploy-status)](https://app.netlify.com/sites/stoic-knuth-8eedfa/deploys)

This is the course site for [MACS 30500 - Programming for the Social Sciences](https://cfss.uchicago.edu).

To build this site, you should have a running R development environment.
You can download R [here](https://www.r-project.org/) on the official R-project website. After installing R and adding it to your path, consider installing [RStudio](https://rstudio.com/), an R-specific IDE. It will make development on this project much easier.

A note on using RStudio: it is an IDE that uses four separate views and can be intimidating when first opened. The top left window is used for editing; the top right window is used for showing information about the environment and console history; the bottom left window contains a console; the bottom right window has a Files tab for exploring the project file structure, and a Viewer tab for viewing the website when it is built.  

In a file explorer, navigate to the root folder of this repo and open the cfss.Rproj file using RProject. In the Files tab on the bottom right, navigate into the R folder, then click the install-packages.R file to open it in the main view. Highlight the entire file and run it using the Run button on the bar on top of the main view. Repeat this step for the build.R file in the R folder. If you get a notification advising you to download missing packages, accept it. Next, run `blogdown::serve_site()` in the console at the bottom left of the IDE. This should build and run the site; it will be viewable in the Viewer tab on the bottom right window. At this point, any changes you make and save should cause the code to be automatically rebuilt and displayed in the View tab.

It is advised that you make all edits within RStudio, as the IDE is not proficient at recognizing when an open file has been changed in another editor.


