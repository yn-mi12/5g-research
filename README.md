## Overview
This project aims to provide an experimental setup for the comparisson of different log reduction strategies in cloud-native 5G and B5G networks.
## Setup  
The project uses https://github.com/niloysh/open5gs-k8s's codebase as a starting base including https://github.com/niloysh/testbed-automator for ceating the Kubernetes cluster. The repositories provide a ready configuration of Kubernetes, Open5Gs and UERANISM.
## Telemetry stack
OpenTelemetry, Prometheus and Grafana are used for monitoring of the obtained logs. Different log reduction strategies are applied and the results are presented using Python's functionalities.