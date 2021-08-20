# Mres2ndminiproject


Author: Yanwu Liu

Student ID: 15105271  

Module code: Mres 2nd mini project - UCL-ZER-36 Optical Wireless Data Centre Networks for Machine Learning

email address: zczliue@ucl.ac.uk


## Table of Contents 
- [Introduction](#Introduction)
- [Files](#Files)
- [UserGuide](#UserGuide)
- [ErrorHandling](#ErrorHandling)
- [Prerequisites](#Prerequisites)




## Introduction
This is the GitHub repository for Mres 2nd mini project. A reconfigurable intra-DCN structure has been proposed based on realistic device parameters. This repository provides the source code to generate each plot in the report.   




## Files
This repository contains the following files:
- [modified_matrix_tracer.py](/modified_matrix_tracer.py): The function file of ray tracing model built on an existing reference [1]
- [MFD](/MFD): MFD approximation and comparison between 3 empirical  formulae and 1 mode solver. All following analysis will use mode solver approximation. 
- [P2P](/P2P): An ideal point-to-point 2 lens ray tracing simulation model based on [TC18APC-1550 collimators](https://www.thorlabs.com/thorproduct.cfm?partnumber=TC18APC-1550)
- [angular_loss_and_resolution](/angular_loss_and_resolution): contains 2 files
  -   [angular_loss.ipynb](/angular_loss_and_resolution/angular_loss.ipynb): calculate coupling loss (lateral deviation, mode size mismatch, clipping) due to a small angular mislignment at 1 lens.
  -   [actuator_resolution.ipynb](/angular_loss_and_resolution/actuator_resolution.ipynb): The angular error to generate 0,1dB loss is transformed into lateral/voltage/bit resolution based on [Piezoelectric Tube actuators](https://www.piezodrive.com/actuators/piezoelectric-tube-scanners/)

- [DCN_dimension](/DCN_dimension): A design prototype of how to calculate the maximum horiozntal number of transceivers (X) and max vertical number of nodes (N) for an **interleaving** structure tower panel. 
- [scan_range](/scan_range): The required horizontal and vertical scan range for an actuator consider the extreme scenarios in DCN dimension design. 


## UserGuide
Each file under each folder can be run independently. 


## References
[1] C. Deakin, M. Enrico, N. Parsons, and G. Zervas, “Design and analysis of beam steering multicore fiber optical switches,” Journal of Lightwave Technology, vol. 37, no. 9, pp. 1954– 1963, 2019.
