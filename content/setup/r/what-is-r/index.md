---
date: "2018-09-09T00:00:00-05:00"
draft: false
weight: 20
title: "Why R?"
toc: true
type: book
aliases: ["/setup01.html", "/setup/what-is-r/"]
---

# Open-source

R is open-source software, which means using it is **completely free**. Second, open-source software is developed **collaboratively**, meaning the source code is open to public inspection, modification, and improvement.

# Popular

R is widely used in the physical and social sciences, [as well as in government, non-profits, and the private sector](http://spectrum.ieee.org/static/interactive-the-top-programming-languages-2016).

Many developers and social scientists write programs in R. As a result, there is also a large support community available to help troubleshoot problematic code. As seen in the Redmonk programming language rankings (which compare languages' appearances on Github [usage] and StackOverflow [support]), R appears near the top of both rankings.

[![](/img/lang.rank_.618-1-1024x708.png)](https://redmonk.com/sogrady/2018/08/10/language-rankings-6-18/)

# Lack of point-and-click interface

R, like any computing language, relies on programmatic execution of functions. That is, to do anything you must write code. This differs from popular statistical software such as [Stata](http://www.stata.com/) or [SPSS](http://www.ibm.com/analytics/us/en/technology/spss/) which at their core utilize a command language but overlay them with drop-down menus that enable a point-and-click interface. While much easier to operate, there are several downsides to this approach - mainly that it [makes it impossible to reproduce one's analysis](https://web.stanford.edu/~gentzkow/research/CodeAndData.pdf).

# Things R does well

* Data analysis - R was written by statisticians for statisticians, so it is designed first and foremost as a language for statistical and data analysis. Much of the cutting-edge research in machine learning occurs in R, and every week there are packages added to [CRAN](https://cran.r-project.org/) implementing these new methods. Furthermore, many models in R can be exported to other programming languages such as `C`, `C++`, `Python`, `tensorflow`, `stan`, etc.
* Data visualization - while the base R `graphics` package is comprehensive and powerful, additional libraries such as [`ggplot2`](http://docs.ggplot2.org/current/) and [`lattice`](https://cran.r-project.org/web/packages/lattice/index.html) make R the go-to language for power data visualization approaches.

# Things R does not do as well

* Speed - while by no means a slug, R is not written to be a fast, speedy language. Depending on the complexity of the task and the size of your data, you may find R taking a long time to execute your program.

# Why are we not using Python?

[![](/img/xkcd_python.png)](https://xkcd.com/353/)

Python was developed in the 1990s as a general-purpose programming language. It [emphasizes simplicity over complexity](https://en.wikipedia.org/wiki/Zen_of_Python) in both its syntax and core functions. As a result, code written in Python is (relatively) easy to read and follow as compared to more complex languages like Perl or Java. As you can see in the above references, Python is just as, if not more, popular than R. It does many things well, like R, but is perhaps better in some aspects:

* General computation - since Python is a general computational language, it is more versatile at non-statistical tasks and is a bit more popular outside the statistics community.
* Speed - because it is a general computing language, Python is optimized to be fast (assuming you write your code optimally). As your data becomes larger or more complex, you might find Python to be faster than R for your analytical needs.
* Workflow - since Python is a general-purpose language, you can build entire applications using it. R, not so much.

That said, there are also things it does not do as well as R:

* Visualizations - visual graphics libraries in Python are increasing in number and quality (see [`matplotlib`](http://matplotlib.org/), [`pygal`](http://www.pygal.org/en/stable/), and [`seaborn`](https://stanford.edu/~mwaskom/software/seaborn/)), but are still behind R in terms of comprehensiveness and ease of use. Of course, once you wish to create interactive and advanced information visualizations, you can also used more specialized software such as [Tableau](http://www.tableau.com/) or [D3](https://d3js.org/).
* Add-on libraries - previously Python was criticized for its lack of libraries to perform statistical analysis and data manipulation, especially relative to the plethora of libraries for R. In recent years Python has begun to catch up with libraries for scientific computing ([`numpy`](http://www.numpy.org/)), data analysis ([`pandas`](http://pandas.pydata.org/)), and machine learning ([`scikit-learn`](http://scikit-learn.org/stable/)). However I personally have found immense difficulty installing and managing packages in Python, even with the use of a package manager such as [`conda`](https://conda.io/docs/).

At the end of the day, I don't think it is a debate between learning R vs. Python. Frankly to be a desirable (and therefore highly-compensated) data scientist [you should learn both languages.](https://blog.usejournal.com/python-vs-and-r-for-data-science-833b48ccc91d) R and Python complement each other, and even R/Python luminaries such as [Hadley Wickham](https://twitter.com/hadleywickham) and [Wes McKinney](https://ursalabs.org/) promote the benefits of both languages:

{{< tweet 855035652710309890 >}}

This course could be taught exclusively in Python (as it was in previous incarnations) or a combination of R and Python (as it was in [fall 2016](https://uc-cfss.github.io/fall2016)). From my past experience, I think the best introduction to computer programming focuses on a single language. Learning two languages simultaneously is extremely difficult. It is better to stick with a single language and syntax. My language of preference is R, so that is what I teach here. Once you complete this course, you will have the basic skills necessary to learn Python on your own.

# Acknowledgements

* This page is derived in part from ["R vs Python for Data Science: The Winner is …"](http://www.kdnuggets.com/2015/05/r-vs-python-data-science.html).
