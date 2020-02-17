#!/bin/sh

find . -type f -name "*Rmarkdown*" -exec sed -i '' 's/T12:30:00/T13:30:00/g' {} +
