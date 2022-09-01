#!/bin/bash

/aesmd.sh

gramine-sgx-get-token --output app.token --sig app.sig
gramine-sgx app
