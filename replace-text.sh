#!/bin/sh

find . -type f -name "*Rmarkdown*" -exec sed -i '' 's/T12:00:00/T:13:50:00/g' {} +
