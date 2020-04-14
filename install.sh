#!/bin/bash

docker run -it --rm \
  --volume $HOME/bin:/target \
  zoom install
