#!/bin/bash

traffic_cop --stdout &
# Herer we should run the ATS hICN proxy

wait
return 0
