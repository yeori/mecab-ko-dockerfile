#!/bin/bash
docker exec mecab-con sh -c 'echo "$0$@" | mecab' "$@"