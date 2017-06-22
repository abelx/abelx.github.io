#!/bin/bash
# author: abelx

message="new blog"

if [ $# == 1 ]
then
    $message="${1}"
fi

git add . && git commit -m "${message}" && git push origin master
