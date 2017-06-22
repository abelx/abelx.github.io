#!/bin/bash
# author: abelx

if [ $# -lt 1 ]
then
    echo "need title."
    exit
fi
title=$1
date=`date "+%Y-%m-%d"`
filename=$date"-"$title".md"

echo -e "---\n \
\n \
layout: post\n \
title: ${title}\n \
subtitle: \"\"\n \
date: ${date} \n \
author: abelx \n \
category: \n \
tags: \n \
finished: false \n \
\n\
--- \n

" > _posts/$filename

open /Applications/MacDown.app _posts/$filename #打开MacDown
