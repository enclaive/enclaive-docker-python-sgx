#!/bin/bash

/aesmd.sh

gramine-sgx-get-token --output py.token --sig py.sig
gramine-sgx py
