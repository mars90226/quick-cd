QUICK CD
========

This small command-line tool can help you quickly change directory to what you want with few keystrokes.

## Usage

Here's a example: You want to quickly switch to "C:\Documents and Settings"

1. You need to add the directory first, so you can navigate it later on.  
Cd to that directory and type `qcd -a document`. This will add the current directory with a name _document_.

2. Then you can use `qcd document` to quickly change directory that directory.

What if you want to quickly switch to "C:\Documents and Settings\mars"?  
`qcd document/m` will do the job. Of course you can use 'qcd document/mars' to achieve this, but we programmer always **lazy** you know. 

Quick CD give all directories a abbreviation, you can use those abbreviation to navigate to it. For example:

* `"Documents and Settings"` will get a abbreviation: `"das"` 
* `"quick-cd"` will get a abbreviation: `"qc"`
* `"no_such_directory"` will get a abbreviation: `"nsd"`
* `"RailsApplication"` will get a abbreviation: `"ra"`
* `"PuttingAll together-into one_name"` with get a abbreviation: `"pation"`
* `"It will----ignore MULTiple delimiter"` will get a abbreviation: `"iwimd"`

As you can see, Quick CD will split the directory name with underscore, hyphen, space, and capital letter and only retain the first charactor to make a abbreviation.  
Be careful! All these abbreviation are in **lowercase**!

You can also use drive name as start directory. No need to add drive into favorite directories. Just use `qcd c:` to switch to C drive.

To find more help, use `qcd -h`. There maybe something weird like "using vim to modify the code". Well, just ignore them.

## Install

Quick CD require Windows and Ruby, and support both cmd and powershell. Download the files, put it into the same directory and add that directory into PATH. Then you can navigate through directories with Quick CD.
