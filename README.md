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
This is the GitHub repository for Mres 2nd mini project. 
- Point-to-point 2 lens ray tracing simulation based on [TC18APC-1550 collimators](https://www.thorlabs.com/thorproduct.cfm?partnumber=TC18APC-1550)
- Coupling loss (lateral deviation, mode size mismatch, clipping) due to a small angular mislignment at 1 lens. The angular error to generate 0,1dB loss is transformed into lateral/voltage/bit resolution based on [Piezoelectric Tube actuators](https://www.piezodrive.com/actuators/piezoelectric-tube-scanners/)
- A design prototype of how to calculate the maximum horiozntal number of transceivers (X) and max vertical number of nodes (N) for an **interleaving** structure tower panel. 




## Files
This repository contains the following files:
- [Datasets](/Datasets): 2 datasets are stored inside its subfolder England, containing daily new cases csv and daily new hospital admissions csv separately. Both are downloaded from [GOV.UK](https://coronavirus.data.gov.uk/). 
- [main.py](/main.py): main function file. Prints results only
