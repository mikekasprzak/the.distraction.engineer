#!/bin/bash

git clone --recurse-submodules https://github.com/google/woff2.git .woff2
cd .woff2 && make
