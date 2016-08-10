# wingui
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/wingui)](https://cran.r-project.org/package=wingui)
[![Coverage Status](https://img.shields.io/codecov/c/github//master.svg)](https://codecov.io/github/?branch=master)

The goal of wingui is to augment the interaction with the built-in 
R gui for Windows.  It also includes helpful utilities specific to 
windows interaction.

## Interacting with the GUI via command lines.

### Changing the Title
```R
GUI$Title <- "My new title"
```

## Other Utilities

* `win_processes` - get a list of running processes on the machine.
* `win_users` - get a list of logged in users on the current machine.
* `win_load` - get a measurement of the current CPU and Memory usage.
* `win_kill` - kill a process by pid, executable name, or window title.
* `win_memory` - get the current memory availability.
* `whos_the_hog` - aggregate the CPU and memory usage to the user to find out 
   who on a multi-user server is using resources.
* `read_lnk` - read a windows link (`*.lnk` file) to get the target.

## Notes
Please note that this project is released with a 
[Contributor Code of Conduct](CONDUCT.md). By participating in this project 
you agree to abide by its terms.
