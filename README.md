QUICK CD
========

This small command-line tool can help you quickly change directory to what you want with few keystrokes.

Here's a example: You want to quickly switch to "C:\Documents and Settings"

1. You need to add the directory first, so you can navigate it later on.  
Cd to that directory and type `qcd -a document`. This will add the current directory with a name _document_.

2. Then you can use `qcd document` to quickly change directory that directory.


What if you want to quickly switch to "C:\Documents and Settings\mars"?  
`qcd document/m` will do the job. Of course you can use 'qcd document/mars' to achieve this, but we programmer always **lazy** you know. 

Quick CD give all directories a abbreviation, you can use those abbreviation to navigate to it. For example:
 * "Documents and Settings" and 
