# TCL Workshop
Tcl (Tool Command Language) is a high-level, interpreted scripting language known for its simplicity and flexibility. It is widely used for rapid application development, automation, GUI creation (often with Tk), and embedding into C-based programs. Tcl is platform-independent and supports dynamic typing, making it easy to prototype and extend. It is especially popular in domains like electronic design automation (EDA) for scripting tasks in tools like Synopsys and Cadence. With a straightforward syntax and powerful string handling, Tcl enables quick development of control scripts and testing frameworks, making it a valuable tool for developers and engineers in various technical fields.




## Module 1: Introduction to TCL and VSDSYNTH Toolbox Usage

In this Workshop, we are a doing a Task which involves building a TCL box which takes a csv file as an input and gives a timing results as an output as shown in the below figure

![Image](https://github.com/user-attachments/assets/eb070970-0db2-438e-b006-e457bab3f515)

Further, the task is divided into subtasks.

First sub-task is to create a command (for example, vsdsynth) and pass .csv files from UNIX shell to TCL script. The next sub-task involves converting all inputs to format [1]and SDC format, then passing them to the synthesis tool 'Yosys'. Yosys tool cannot understand the csv file so we need to conbvert it into foramt [1] as shown below.

![Image](https://github.com/user-attachments/assets/f4b93251-868b-428f-ba63-1643de82f7be)

Also we need to convert openMSP430_design_constraints.csv into the sdc format which can be passed to Yosys tool for synthesis.

![Image](https://github.com/user-attachments/assets/f730fdc9-9976-4118-909b-b6a036cfde99)

Above figure shows the constraitns file which should be convert into sdc foramt as shown below.

![Image](https://github.com/user-attachments/assets/c06a7386-aee0-4cba-a1df-5d08a20b24ab)

Following this, we need to convert format [1] and SDC to format [2] and pass them to the timing tool 'Opentimer'. 

![Image](https://github.com/user-attachments/assets/b0019f18-484f-4093-ae5a-d2a0f90c65a7)

The above foramt[2] can be understandable by Opentimer tool for STA.

The final sub-task is to generate an output report with the timing results as shown below.

![Image](https://github.com/user-attachments/assets/12a93b47-aa3a-4d2d-b381-d1f5654b73fc)


### Sub-task 1 Create Command (panda) and pass csv file from UNIC shell to Tcl script

First we need to create a UNIX script "vsdsynth" .The command was created with the following instructions:

1) letting the system know that its a UNIX script

```
#!/bin/tcsh -f  
```

2) Creating the logo

```
echo " #    #    #    ######  ####### #     # ### #    #           "
echo " #   #    # #   #     #    #    #     #  #  #   #             "
echo " #  #    #   #  #     #    #    #     #  #  #  #              " 
echo " ###    #     # ######     #    #######  #  ###               " 
echo " #  #   ####### #   #      #    #     #  #  #  #               "
echo " #   #  #     # #    #     #    #     #  #  #   #              "
echo " #    # #     # #     #    #    #     # ### #    #             "
echo 
echo ""
echo ""
echo "           Developed by: Karthik"
echo "           Acknowledgement: Kunal Ghosh, vlsisystemdesign.com"
echo ""
echo ""
echo ""
```

3) Creates a variable named "my_work_dir" and assign to it the absolute path of the current working directory. The pwd command (which stands for "print working directory") returns the full path of the directory where the Tcl script is currently executin
```
set my_work_dir [pwd]
```
4) We can check if the user is porividing a correct .csv file by using below script
```
 if ($#argv != 1) then
	   echo "Info : Please Provide the csv file"
	   exit 1
 endif
 if (! -f $argv[1] || $argv[1] == "-help") then
	if ($argv[1] == "-help") then
		echo USAGE: ./vsdsynth \<csv file\>
		echo
		echo 		where \<csv file\> consists of 2 columns
		echo
		echo           	\<Design Name\> is the name of top level module 
		echo
		echo            \<Output Directory\> is the name of Output Directory where you want to dump synthesis script, synthesized netlist and timing reports
		echo 
		echo             \<Early Libary Path\> is the file path of the early cell libary to be used for STA
		echo
                echo             \<Late Libary Path\> is the file path of the late cell libary to be used for STA
		echo
                echo             \<Constraints file\> is the file path of constraints to be used for STA
	else 
		echo "ERROR: Cannot find the CSV file $argv[1]. Exiting"
	endif
else
		tclsh vsdsynth.tcl  $argv[1]
endif
```
- In first scenario, if the user is not passing  a .csv fileor passing more than one .csv file then it prints a statement "Info : Please Provide the csv file" on the screen as shown below.

![Image](https://github.com/user-attachments/assets/765d0790-2eec-429c-85fc-280697775b71)

- If the provided .csv file doesnt exist then it pritns a statement "ERROR: Cannot find the CSV file.Exiting" as shown below.

![Image](https://github.com/user-attachments/assets/19b0cc59-b1bc-4afe-8af1-0639f5c220f8)

- If the user enter __-help__ 

![Image](https://github.com/user-attachments/assets/618be1cc-1346-4b9b-9337-bb645c3d3e02)

		tclsh vsdsynth.tcl  $argv[1]

The above command executes a Tcl script named "vsdsynth.tcl" using the Tcl shell interpreter (tclsh) and passes the first command-line argument to the script.



Note : Make sure the file is executable by using the command ``` chmod -R 777 panda ``` 

## Module 2: Variable Creation and Processing Constraints from CSV

In this module, we will perform sub-task 2 which converts .csv file into format[1] and constraints.csv file into sdc format

- First we need to create the variables using tcl script by reading the first column elemetns of openMSP430_design_details.csv file like DesingName, OutputDirectory etc...
- Secondly, we need to check if the files / directory provided by user in a csv file ( second column) does exists or nots.
- Further, we need to read the constraints file for above and convert it into a SDC format which is acceptable for synthesis and PNR purposes.
- Then we need to read all the files from "NetlistDirectory" i.e. all verilog files and write it in script for Yosys.
- Lastly, we hgave to create a synthesis script and pass it Yosys tool.

#### Creatring variables from CSV file

In this step, we will first convert the CSV file into matrix __m__ and then converts matrix __m__  into an array. By converting the csv file into array, we can access every cell by using TCL commands like __lindex__. The script mentioned below is used to covnert CSV file into array.


        set filename [lindex $argv 0]
        package require csv
        package require struct::matrix
        struct::matrix m
        set f [open $filename]
        csv::read2matrix $f m , auto
        close $f
        set columns [m columns]
        #m add columns $columns
        m link my_arr
        set rows [m rows]

Further, we will create a varialbe by reading first column of csv file and then assign the second column value to the variables. In the first column of csv file, we have varialbe names such as DesignName, OutputDirectory etc.. but we have Space b/w the varialbe like Design Name ,Output Directory etc.. as shown in the below figure.

![Image](https://github.com/user-attachments/assets/6efdebdd-e27d-415a-8e73-96f4ba260c49)

We need to remove space and then assign second column value to the varialbe. In some second column values, we dont have full directory of the file path like home/vsdsynth/verilog. They just have "./verilog" or  "~/verilog". We need to normalize this and convert it into full path. BThe script mentioned below can normalize values and assign them to variables. It also remvoes the space b/w the varialbe.

```
        set i 0
        while {$i < $rows} {
                 puts "\nInfo: Setting $my_arr(0,$i) as '$my_arr(1,$i)'"
                 if {$i == 0} {
                         set [string map {" " ""} $my_arr(0,$i)] $my_arr(1,$i)
                 } else {
                         set [string map {" " ""} $my_arr(0,$i)] [file normalize $my_arr(1,$i)]
                 }
                  set i [expr {$i+1}]
        }


puts "\nInfo: Below are the list of the initial variables and their values. User can use these variables for further debugging purposes."
puts "DesignName = $DesignName"
puts "OutputDirectory = $OutputDirectory"
puts "NetlistDirectory = $NetlistDirectory"
puts "EarlyLibraryPath = $EarlyLibraryPath"
puts "LateLibraryPath = $LateLibraryPath"
puts "ConstraintsFile = $ConstraintsFile"
```
![Image](https://github.com/user-attachments/assets/f2770413-e741-482e-b8f8-ecedf925f614)

In the above figure we can see that varaibles and their normalzied values.

#### Check if the files provided exists or not

We need to check if the directory mentioned exists or not. If the directory not exists then we have to create a new directory. 

We also need to check if the files exists or not. If not exists then we have to warn the user and exit the script. The script mentioned belows check if all the paths/ files mentioned exsists or not. If the directroy doesnt exists then it creates a new directory.

```
if { [file isdirectory $OutputDirectory]} {
	puts "\nInfo : Output directory exists and found in path $OutputDirectory "
} else {
	puts "\n Info : Cannot find the output directory $OutputDirectory. Creating $OutputDirectory"
	file mkdir $OutputDirectory
}
if { [file isdirectory $NetlistDirectory]} {
	puts "\nInfo : Netlist directory exists and found in path $NetlistDirectory "
} else {
	puts "\n Info : Cannot find the Netlist directory $NetlistDirectory. Creating $NetlistDirectory"
	file mkdir $NetlistDirectory
}
if { [file exists $EarlyLibraryPath]} {
	puts "\nInfo : Early cell library file exists and found in path $EarlyLibraryPath "
} else {
	puts "\n Info : Cannot find the early cell library file in path $EarlyLibraryPath. Exiting..."
	exit
}
if { [file exists $LateLibraryPath]} {
	puts "\nInfo : Late cell library file exists and found in path $LateLibraryPath "
} else {
	puts "\n Info : Cannot find the Late cell library file in path $LateLibraryPath. Exiting..."
	exit
}
if { [file exists $ConstraintsFile]} {
	puts "\nInfo : Constraints file exists and found in path $ConstraintsFile "
} else {
	puts "\n Info : Cannot find the Constraints file in path $ConstraintsFile. Exiting..."
	exit
}
```
If the all the files and directory mentioned exists then we can go for the further process.

![Image](https://github.com/user-attachments/assets/521fb6b5-ce7c-4778-8289-ae21c8cb3c27)

If the mentioned directory doesnot exists then the script will create a new directroy as shown in the below figure.

![Image](https://github.com/user-attachments/assets/7e0b6ed4-c020-4652-818d-42b7ad702985)

If the file mentioned doesnot exists then the script will exit as shown in the below figure.

![Image](https://github.com/user-attachments/assets/d87b0f9f-cea3-42c9-a38a-509c4a36ed40)

#### Convert constraints file into a SDC format 

First, we need to convert the constraints.csv file into matrix for processing the cells easily. The script mentioned below can convert constraints.csv file into an matrix object.
constr_rows represents the number of rows presents in constraints.csv file and constr_columns represents the number of columns presents in constraints.csv file.

```
puts "\n Info: Dumping SDC constraints for $DesignName"
::struct::matrix constraints
set chan [open $ConstraintsFile]
csv::read2matrix $chan constraints , auto
close $chan
set constr_rows [constraints rows]
puts " number of rows in constraints file = $constr_rows "
set constr_columns [constraints columns]
puts " number of columns in constraints file = $constr_columns "
```
![Image](https://github.com/user-attachments/assets/c5ebcae0-a05d-40e5-ba04-e86ee3d41533)

In the above figure, we can see that the constraints.csv file has three major parts such as Clock constraints, Input ports constraints, Output ports constraints.

To facilitate efficient processing, we can divide the constraints.csv file into Clock constraints, Input ports constraints, Output ports constraints. For that we need to know the starting row number of each constraints. The script mentioned below will find the starting row of each constraints

```
set clock_start [lindex [lindex [constraints search all CLOCKS] 0] 1]
set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0] 0]
puts "clock_start =  $clock_start"
puts "clock_start_column = $clock_start_column"

set input_ports_start [lindex [lindex [ constraints search all INPUTS] 0] 1]
puts "input_ports_start =$input_ports_start"
set output_ports_start [lindex [lindex [ constraints search all OUTPUTS] 0] 1]
puts "output_ports_start = $output_ports_start "
```
![Image](https://github.com/user-attachments/assets/f059474c-d514-435f-970f-24e8a8b849be)

In above figure, we can see the number of rows and columns in constraints.csv file is 57 and 11 respectively. We can also see the clock starting row as 0 input starting row as 4 and output starting row as 27. By obtaining these values we can easily process the constraints.csv file into sdc format.

## Module 3 Processing clock and input constraints 

In this module, we will process the clock and input constraints into Synopsys Design Constraints (SDC) format which can used for synthesis.

We need to develop a alogrithm to identify column numbers of different parameters like  early_rise_delay, early_fall_dealy etc.. of clock constraints. The script mentioned below identifies the column numbers of different parameters of clock and assigns it to a varaibles. It also displays the column numbers of parameters on screen. 
```
set clock_early_rise_delay_start [lindex [lindex [ constraints search rect $clock_start_column $clock_start [expr {$constr_columns -1}] [expr {$input_ports_start -1}] early_rise_delay] 0 ] 0 ]
set clock_early_fall_delay_start [lindex [lindex [ constraints search rect $clock_start_column $clock_start [expr {$constr_columns -1}] [expr {$input_ports_start -1}] early_fall_delay] 0 ] 0 ]
set clock_late_rise_delay_start [lindex [lindex [ constraints search rect $clock_start_column $clock_start [expr {$constr_columns -1}] [expr {$input_ports_start -1}] late_rise_delay] 0 ] 0 ]
set clock_late_fall_delay_start [lindex [lindex [ constraints search rect $clock_start_column $clock_start [expr {$constr_columns -1}] [expr {$input_ports_start -1}] late_fall_delay] 0 ] 0 ]
set clock_early_rise_slew_start [lindex [lindex [ constraints search rect $clock_start_column $clock_start [expr {$constr_columns -1}] [expr {$input_ports_start -1}] early_rise_slew] 0 ] 0 ]
set clock_early_fall_slew_start [lindex [lindex [ constraints search rect $clock_start_column $clock_start [expr {$constr_columns -1}] [expr {$input_ports_start -1}] early_fall_slew] 0 ] 0 ]
set clock_late_rise_slew_start [lindex [lindex [ constraints search rect $clock_start_column $clock_start [expr {$constr_columns -1}] [expr {$input_ports_start -1}] late_rise_slew] 0 ] 0 ]
set clock_late_fall_slew_start [lindex [lindex [ constraints search rect $clock_start_column $clock_start [expr {$constr_columns -1}] [expr {$input_ports_start -1}] late_fall_slew] 0 ] 0 ]

puts "clock_early_rise_delay_start = $clock_early_rise_delay_start"
puts "clock_early_fall_delay_start = $clock_early_fall_delay_start"
puts "clock_late_rise_delay_start = $clock_late_rise_delay_start"
puts "clock_late_fall_delay_start = $clock_late_fall_delay_start"
puts "clock_early_rise_slew_start = $clock_early_rise_slew_start"
puts "clock_early_fall_slew_start = $clock_early_fall_slew_start"
puts "clock_late_rise_slew_start = $clock_late_rise_slew_start"
puts "clock_late_fall_slew_start = $clock_late_fall_slew_start"
```

![Image](https://github.com/user-attachments/assets/5c416e4b-c4b8-4a30-9db1-54fe646412cf)

In the above figure, we can see different parameter column numbers have been assign to respective varialbes.

Then we have to write the parameters into a SDC file in a particular manner as shown below.

![Image](https://github.com/user-attachments/assets/c6cb864f-e350-41b1-b706-113d31dda654)


```
set sdc_file [open $OutputDirectory/$DesignName.sdc "w"]
set i [expr {$clock_start+1}]
set end_of_ports [expr {$input_ports_start -1}]
puts "\n Info-SDC: Working on clock constraints..."

while {$i< $end_of_ports} {
        puts "Working on clock [constraints get cell 0 $i ]"
	puts -nonewline $sdc_file "\ncreate_clock -name [constraints get cell 0 $i ] -period [constraints get cell 1 $i ] -waveform \{0 [expr { [constraints get cell 1 $i ]*[constraints get cell 2 $i ]/100 }]\} \[get_ports [constraints get cell 0 $i ]\]"
     	puts -nonewline $sdc_file "\nset_clock_latency -source -early -rise [constraints get cell $clock_early_rise_delay_start $i ] \[get_clocks [constraints get cell 0  $i]\]"
	puts -nonewline $sdc_file "\nset_clock_latency -source -early -fail [constraints get cell $clock_early_fall_delay_start $i ] \[get_clocks [constraints get cell 0  $i]\]"
	puts -nonewline $sdc_file "\nset_clock_latency -source -late -rise [constraints get cell $clock_late_rise_delay_start $i ] \[get_clocks [constraints get cell 0  $i]\]"
	puts -nonewline $sdc_file "\nset_clock_latency -source -late -fail [constraints get cell $clock_late_fall_delay_start $i ] \[get_clocks [constraints get cell 0  $i]\]"
        puts -nonewline $sdc_file "\nset_clock_transition   -rise -min [constraints get cell $clock_early_rise_slew_start $i ] \[get_clocks [constraints get cell 0  $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition   -fall -min [constraints get cell $clock_early_fall_slew_start $i ] \[get_clocks [constraints get cell 0  $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition   -rise -max [constraints get cell $clock_late_rise_slew_start $i ] \[get_clocks [constraints get cell 0  $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition   -fall -max [constraints get cell $clock_late_fall_slew_start $i ] \[get_clocks [constraints get cell 0  $i]\]"
	set i [expr {$i+1}]
}
```
The above mentioned script creates a .sdc file in OutputDirectory and writes the parameters into .sdc file in a particular manner as mentioned above.

![Image](https://github.com/user-attachments/assets/66b2c186-f369-4e05-ba7f-598392f038a8)

In the above figure, we can see that the clock parameters are written into a .sdc file and we can also verify thatthe values written are matached same as cosntraints.csv file.

Similarly, we have to find the column number for input parameter. The script mentioned belowc can find column numbers and assigns it to a respective variable. It also displays the column numbers of input parameters on display.

```
set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns-1}] [expr {$output_ports_start-1}] early_rise_delay] 0] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns-1}] [expr {$output_ports_start-1}] early_fall_delay] 0] 0]
set input_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns-1}] [expr {$output_ports_start-1}] late_rise_delay] 0] 0]
set input_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns-1}] [expr {$output_ports_start-1}] late_fall_delay] 0] 0]
set input_early_rise_slew_start [lindex [lindex [ constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns -1}] [expr {$output_ports_start -1}] early_rise_slew] 0 ] 0 ]
set input_early_fall_slew_start [lindex [lindex [ constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns -1}] [expr {$output_ports_start -1}] early_fall_slew] 0 ] 0 ]
set input_late_rise_slew_start [lindex [lindex [ constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns -1}] [expr {$output_ports_start -1}] late_rise_slew] 0 ] 0 ]
set input_late_fall_slew_start [lindex [lindex [ constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns -1}] [expr {$output_ports_start -1}] late_fall_slew] 0 ] 0 ]

puts "input_early_rise_delay = $input_early_rise_delay_start"
puts "input_early_fall_delay = $input_early_fall_delay_start"
puts "input_late_rise_delay = $input_late_rise_delay_start"
puts "input_late_fall_delay = $input_late_fall_delay_start"
puts "input_early_rise_slew_start = $input_early_rise_slew_start"
puts "input_early_fall_slew_start = $input_early_fall_slew_start"
puts "input_late_rise_slew_start = $input_late_rise_slew_start"
puts "input_late_fall_slew_start = $input_late_fall_slew_start"
```

![Image](https://github.com/user-attachments/assets/968e74b8-5348-4111-968a-46f846deffbb)

In the above figure, we can see that some of the input ports are bussed and some are not. But from the cosntraitns.csv filer we can differentiate which ports are bussed or which are not. We need to expand the bussed ports into single ports for understanding purposes for Opentimer too. So, we need to find if the input ports are bussed or not i.e. if the input port is single port or a bus. If it is a bus we need to append a "*" at the end of the port name in the .sdc file as shown below.

![Image](https://github.com/user-attachments/assets/07451caf-3d53-44cc-888c-6093758b3e51)

```
set i [expr {$input_ports_start+1}]
set end_of_ports [expr {$output_ports_start-1}]
puts "\nInfo-SDC: Working on IO constraints....."
puts "\nInfo-SDC: Categorizing input ports as bits and bussed"

while { $i < $end_of_ports } {

set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1 w]

foreach f $netlist {
        set fd [open $f]
		#puts "reading file $f"
        while {[gets $fd line] != -1} {
			set pattern1 " [constraints get cell 0 $i];"
            if {[regexp -all -- $pattern1 $line]} {
			#puts "\npattern1 \"$pattern1\" found and matching line in verilog file \"$f\" is \"$line\""
				set pattern2 [lindex [split $line ";"] 0]
			#puts "\ncreating pattern2 by splitting pattern1 using semi-colon as delimiter => \"$pattern2\""
				if {[regexp -all {input} [lindex [split $pattern2 "\S+"] 0]]} {	
			#puts "\nout of all patterns, \"$pattern2\" has matching string \"input\". So preserving this line and ignoring others"
				set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
				#puts "\nprinting first 3 elements of pattern as \"$s1\" using space as delimiter"
				puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
				#puts "\nreplace multiple spaces in s1 by space and reformat as \"[regsub -all {\s+} $s1 " "]\""
				}
				#else { " \"$pattern2\" didnt have first term as 'output'"}
        	}
        }
close $fd
}
close $tmp_file
```

Some of the input port have multiple spaces in between them. The above mentioned script removes the spaces inbetween them and writes them in a temporary file. We can see the above process in the below figure as the scrpit reads one of input porta as "input          cpu_en" and later it is written in /tmp/1 file as "input cpu_en"

![Image](https://github.com/user-attachments/assets/2b75a558-9ffd-4b23-9c5d-aa0c6933062f)

Then we have develop a alogrithm that checks if the input ports are bussed or not. The first step in the alogrithm is to read the /tmp/1 file. We have to split the file into lines. If the input ports are present multiple times in temporary file then we have sort unique item. Then we have to join them. We have to write that varaible into another temporary file. Then by using __llength__ coomand, count the number of elemnets in each port. If the count is greater than 2, it means input port is bussed. So concat a "*" at the end of port name.

The script for the above alogrithm is mentioned below.

```
set tmp_file [open /tmp/1 r]
set tmp2_file [open /tmp/2 w]
#puts "reading [read $tmp_file]"
#puts "splitting /tmp/1 file as  [split [read $tmp_file] \n]] ]"
#puts "sorting /tmp/1 file as [lsort -unique [split [read $tmp_file] \n]]"
#puts "joining /tmp/1 file as [join [lsort -unique [split [read $tmp_file] \n]] \n]"
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open /tmp/2 r]

set count [llength [read $tmp2_file]] 
#puts "Count is $count"
if {$count > 2} { 
    set inp_ports [concat [constraints get cell 0 $i]*]
	#puts "\n Bussed"
} else {

    set inp_ports [constraints get cell 0 $i]
	#puts "\n Not Bussed"
}
```
![Image](https://github.com/user-attachments/assets/bf68f0ff-c1ee-467b-acc1-cfc2156fa229)

In the above figure, we can see we are reading "\n" and input port two times.

![Image](https://github.com/user-attachments/assets/cc029769-84ee-4180-929f-2648abc6c88b)

In the above figure, we split the lines and formatted into a single line.

![Image](https://github.com/user-attachments/assets/2624b0b5-5dbd-4fa1-8902-7d93908bc514)

In the above figure, we sortted the unique item.

![Image](https://github.com/user-attachments/assets/c6b7776f-2a78-479f-9e14-6153e29d3b3d)

In the above figure, we joined the both elements.


![Image](https://github.com/user-attachments/assets/6f4faff6-53a7-4117-86b8-63f8d79dd525)

In the above figure, we can see if the count is greater than 2 then __*__ was concatted at the end of port name.

We have to write the input parameters into .sdc file. The script for the mentioned purpose is given below.
```
puts -nonewline $sdc_file "\nset_input_delay -clock  \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_delay_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included  [constraints get cell $input_early_fall_delay_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_delay -clock  \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included  [constraints get cell $input_late_rise_delay_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_delay -clock  \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included  [constraints get cell $input_late_fall_delay_start $i] \[get_ports $inp_ports\]"

	puts -nonewline $sdc_file "\nset_input_transition -clock  \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_slew_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included  [constraints get cell $input_early_fall_slew_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_transition -clock  \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included  [constraints get cell $input_late_rise_slew_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_transition -clock  \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included  [constraints get cell $input_late_fall_slew_start $i] \[get_ports $inp_ports\]"
```

The below figure shows that the input parameters are written in .sdc file and if the port is buzzed "*" concatted at the end of port name.

![Image](https://github.com/user-attachments/assets/d874f6a8-21af-49c1-9ddf-0dfc14c9311c)


## Module 4: Complete Scripting and Yosys Synthesis Introduction

In this module, we will complete the sub-task 2 by converting output constraints into sdc format. We will also do the synthesis by using Yosys tool.

In the previous module we have completed convertting input constraints into sdc format.Similarly, do the same process for output parameters. We have to change only some parameters such as setting __i__ as __$output_ports_start__ etc..

The script mentioned below finds the column number of the output parameters.
```
set output_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$constr_columns-1}] [expr {$constr_rows-1}]  early_rise_delay] 0 ] 0]
set output_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$constr_columns-1}] [expr {$constr_rows-1}]  early_fall_delay] 0 ] 0]
set output_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$constr_columns-1}] [expr {$constr_rows-1}]  late_rise_delay] 0 ] 0]
set output_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$constr_columns-1}] [expr {$constr_rows-1}]  late_fall_delay] 0 ] 0]
set output_load_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$constr_columns-1}] [expr {$constr_rows-1}]  load] 0 ] 0]
set related_clock [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$constr_columns-1}] [expr {$constr_rows-1}]  clocks] 0 ] 0]
puts "output_early_rise_delay_start =$output_early_rise_delay_start"
puts "output_early_fall_delay_start =$output_early_fall_delay_start"
puts "output_late_rise_delay_start =$output_late_rise_delay_start"
puts "output_late_fall_delay_start =$output_late_fall_delay_start"
puts "output_load_start =$output_load_start"
```
We can the output parameters column numbers in the below figure.

![Image](https://github.com/user-attachments/assets/8783ca50-2d84-4c44-956c-25d17c237420)

We have to develop an alogrithm to check if the output ports are bussed or not. If bussd, concat "*" at the end of port name. Then write the output parameters into .sdc format in a particular sdc foramt.The script mentioned below does the above purpose.

```
set i [expr {$output_ports_start+1}]
set end_of_ports [expr {$constr_rows-1}]
puts "\nInfo-SDC: Working on Output constraints....."
puts "\nInfo-SDC: Categorizing output ports as bits and bussed"

while { $i < $end_of_ports } {

set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1 w]

foreach f $netlist {
        set fd [open $f]
		#puts "reading file $f"
        while {[gets $fd line] != -1} {
			set pattern1 " [constraints get cell 0 $i];"
            if {[regexp -all -- $pattern1 $line]} {
			#puts "\npattern1 \"$pattern1\" found and matching line in verilog file \"$f\" is \"$line\""
				set pattern2 [lindex [split $line ";"] 0]
			#puts "\ncreating pattern2 by splitting pattern1 using semi-colon as delimiter => \"$pattern2\""
				if {[regexp -all {outptu} [lindex [split $pattern2 "\S+"] 0]]} {	
			#puts "\nout of all patterns, \"$pattern2\" has matching string \"input\". So preserving this line and ignoring others"
				set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
				#puts "\nprinting first 3 elements of pattern as \"$s1\" using space as delimiter"
				puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
				#puts "\nreplace multiple spaces in s1 by space and reformat as \"[regsub -all {\s+} $s1 " "]\""
				}
				#else { " \"$pattern2\" didnt have first term as 'output'"}
        	}
        }
close $fd
}
close $tmp_file

set tmp_file [open /tmp/1 r]
set tmp2_file [open /tmp/2 w]
#puts "reading [read $tmp_file]"
#puts "reading /tmp/1 file as  [split [read $tmp_file] \n]] ]"
#puts "sorting /tmp/1 file as [lsort -unique [split [read $tmp_file] \n]]"
#puts "joining /tmp/1 file as [join [lsort -unique [split [read $tmp_file] \n]] \n]"
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open /tmp/2 r]

set count [llength [read $tmp2_file]] 
#puts "Count is $count"
if {$count > 2} { 
    set op_ports [concat [constraints get cell 0 $i]*]
	#puts "\n Bussed"
} else {

    set op_ports [constraints get cell 0 $i]
	#puts "\n Not Bussed"
}
	#puts "output port name is $inp_ports and count is $count"

	puts -nonewline $sdc_file "\nset_output_delay -clock  [constraints get cell $related_clock $i] -min -rise  [constraints get cell $output_early_rise_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock  [constraints get cell $related_clock $i] -min -fall  [constraints get cell $output_early_fall_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock  [constraints get cell $related_clock $i] -max -rise  [constraints get cell $output_late_rise_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock  [constraints get cell $related_clock $i] -max -fall  [constraints get cell $output_late_fall_delay_start $i] \[get_ports $op_ports\]"
		puts -nonewline $sdc_file "\nset_load [constraints get cell $output_load_start $i] \[get_ports $op_ports\]"



	set i [expr {$i+1}]

}
puts "\n Info:SDC Created .Please use the constraints path $OutputDirectory/$DesignName.sdc"
close $tmp2_file

close $sdc_file
```

We can see the output parameters are written in sdc format in .sdc file as shown below.
![Image](https://github.com/user-attachments/assets/6afe4279-ac49-4551-9837-c92cc3aa90aa)

After the successfull completion of writng all constraints parameters into .sdc file, we get a message saying "SDC created.Please use the constraints path /home/vsduser/vsdsynth/outdir_openMSP430/$openMSP430.sdc" as shown below.

![Image](https://github.com/user-attachments/assets/c659fa92-2d99-4626-84f4-b3cf474078da)


#### Creating Scripts for Hierarchy check

The script mentioned belows creates a .hier.ys and writes the script for the hierarchy check.
```

puts "\n Info: Creating hierarchy check script to be used by Yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
#puts "data is \"$data\""
set filename "$DesignName.hier.ys"
#puts "\nfilename is \"$filename\""
set fileId [open $OutputDirectory/$filename "w"]
#puts "open \"$OutputDirectory/$filename"\ in write mode"
puts -nonewline $fileId $data
#puts "netlist is \"$netlist\""
set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
	set data $f
	#puts "data is \"$f\""
	puts -nonewline $fileId "\n read_verilog $f"
}
puts -nonewline $fileId "\nhierarchy -check"
close $fileId

```
The script mentioned above creates a .hier.ys and writes the script for the hierarchy check as shown in the below figure.

![Image](https://github.com/user-attachments/assets/60cc1f8f-d4d8-4862-b93b-e10ff6d2a3f9)

Whenever we uses __"exec"__ command in the tcl script, it runs the command in bash.
We are runnimg running the yosys tool by passing __"openMSP430.heir.ys"__ as input file and catching all the logs in  __"openMSP430.hierarchy_check.log__

If there is an error, __"my_error"__ will be set to 1 and we have to find the error. In yosys when error occurs then we will find a common pattern such as __"referenced in module"__ . It differs across various tools. We have to search each lines of .log file and pritns the error statement. The script mentioned below does the above purpose. If the hierarchy check passes then it displays a message saying __"Hierarchy check PASS"__

```
set my_error [catch { exec yosys -s $OutputDirectory/$DesignName.hier.ys >& $OutputDirectory/$DesignName.hierarchy_check.log} msg]
puts "Error flag is \"$my_error\""
if { $my_error } {
	set filename "$OutputDirectory/$DesignName.hierarchy_check.log"
	puts "log file name is \"$filename\" "
	set pattern "referenced in module"
	#puts "pattern is $pattern"
	set count 0
	set fid [open $filename r]
	while {[gets $fid line] != -1} {
		# -- used to say end of command options. everything after this is args
		incr count [regexp -all -- $pattern $line]
		if {[regexp -all -- $pattern $line]} {
			puts "\nError: module [lindex $line 2] is not part of design $DesignName. Please correct RTL in the path '$NetlistDirectory'"
			puts "\nInfo: Hierarchy check FAIL"
		}
	}
	close $fid
} else {
	puts "\nInfo: Hierarchy check PASS"
}
puts "\n Info: Please find the hierearchy check details in [file normalize $OutputDirectory/$DesignName.hierarchy.check.log] for more info"

```

- if there is no error then 

![Image](https://github.com/user-attachments/assets/6954bc54-5e06-413b-8730-c24e4d51cbaa)

- if there is a error in hierarchy check then

![Image](https://github.com/user-attachments/assets/9bfc50d5-12a1-46e8-81ec-978bf86573ac)






## Module 5: Advanced Scripting Techniques and Quality of Results Generation

In module 5, we will develop script for synthesis and run yosys tool. Then we will talk about procs and discuss some procs that we are going to use in this task. We also convert the foramt [1] and sdc format intp format [2] which can be understandle by Opentimer tool.

#### Creating script for Synthesis
```
puts "\nInfo: Creating main synthesis script to be used for yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.ys"
#puts "\nfilename is \"$filename\""
set fileId [open $OutputDirectory/$filename "w"]
#puts "open \"$OutputDirectory/$filename\" in write mode"
puts -nonewline $fileId $data
#puts "netlist is \"$netlist\""
set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
	set data $f
	#puts "data is \"$f\""
	puts -nonewline $fileId "\n read_verilog $f"
}

puts -nonewline $fileId "\nhierarchy -top $DesignName"
puts -nonewline $fileId "\nsynth -top $DesignName"
puts -nonewline $fileId "\nsplitnets -ports -format __\ndfflibmap -liberty ${LateLibraryPath}\nopt"
puts -nonewline $fileId "\nabc -liberty ${LateLibraryPath}"
puts -nonewline $fileId "\nflatten"
puts -nonewline $fileId "\nclean -purge\niopadmap -outpad BUFX2 A:Y -bits\nopt \nclean"
puts -nonewline $fileId "\nwrite_verilog $OutputDirectory/$DesignName.synth.v"
close $fileId
puts "\nInfo: Synthesis script created and can be accesed from the path $OutputDirectory/$filename"
puts "\nInfo: Running Synthesis...."

if {[catch { exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log} msg]} {
	puts "\nError: Syntesis failed due to errors. Please refer to log $OutputDirectory/$DesignName.synthesis.log for errors"
	exit
} else {
	puts "\nInfo: Synthesis finished sucessfully"
}

puts "\nInfo: Please refert olog $OutputDirectory/$DesignName.synthesis.log"

```

- The above script creates a __"openMSP430.ys"__ which can be passed to Yosys for synthesis purpose.
- It writes all the netlist and all scripts necessary for synthesis into __"openMSP430.ys"__
- By using __"exec"__ commnad we can run yosys via tcl command and all the logs are stored in openMSP430.synthesis.log
- If there is an error, it displays a message "Error: Syntesis failed due to errors. Please refer to log /home/vsduser/vsdsynth/outdir_openMSP430/$openMSP430.synthesis.log for errors"

-If there is no error while running synthesis

![Image](https://github.com/user-attachments/assets/d03225d3-3e6f-4720-9e92-09469a55ea26)

-If there is an error while runnimg synthesis

![Image](https://github.com/user-attachments/assets/f1ac5ea2-e111-478f-ba7a-b351bc18ee4e)

```
set fileId [open /tmp/1 "w"]
puts -nonewline $fileId [exec grep -v -w "*" $OutputDirectory/$DesignName.synth.v]
close $fileId

set output [open $OutputDirectory/$DesignName.final.synth.v "w"]

set filename "/tmp/1"
set fid [open $filename r]
	while {[gets $fid line] != -1} {
	puts -nonewline $output [string map {"\\" ""} $line]
	puts -nonewline $output "\n"
}

close $fid
close $output

puts "\nInfo: Please find the synthesized netlist for $DesignName at below path. You can use this netlist for STA or PNR"
puts "\n$OutputDirectory/$DesignName.final.synth.v"

```

The above scirpt can be used to remove \ from the gate level netlist. Because opentimer tool cannot understand the netlist with \ in it.As we can see we have 6119 \ in  the synt.v file as shown in the below figure. After running the above the count came down to 0.

![Image](https://github.com/user-attachments/assets/f88b9d33-54e3-4d62-a690-3e86779b1b2d)

![Image](https://github.com/user-attachments/assets/25dc5030-2675-4f02-9376-14b786b7bf51)

#### Procs

In Tcl, procedures (commonly called "procs") are a fundamental mechanism for creating reusable script blocks. They function similarly to functions or methods in other programming languages, allowing you to organize script into logical, reusable units.

We are going to use some procs such as reopenStdout.proc, set_num_threads.proc, read_lib.proc, read_verilog.proc, read_sdc.proc to convert the foramt [1] and sdc format to format [2].

1) reopenStdout.proc
 
The __reopenStdout__ proc is a Tcl procedure used to redirect standard output to a file. This technique is sometimes called "reopening" stdout.

```
proc reopenStdout {file} {
    close stdout
    open $file w       
}
```
This procedure works by:

- Closing the current stdout channel

- Opening a file in write mode and making it the new stdout channel

When we call this procedure with a filename as an argument, all subsequent output that would normally go to the console will instead be written to the specified file. This is useful when you need to capture output from commands or procedures that write directly to stdout and don't provide an option to specify an output channel.

2) set_num_threads.proc

The __set_multi_cpu_usage__ proc is a Tcl procedure designed to configure multi-threading capabilities for EDA tools in ASIC design automation workflows. This procedure is part of TCL scripts that automate the frontend of ASIC design.

```
proc set_multi_cpu_usage {args} {
    array set options {-localCpu <num_of_threads> -help "" }
    foreach {switch value} [array get options] {
    puts "Option $switch is $value"
    }
    while {[llength $args]} {
    puts "llength is [llength $args]"
    puts "lindex 0 of \"$args\" is [lindex $args 0]"
        switch -glob -- [lindex $args 0] {
          -localCpu {
              puts "old args is $args"
              set args [lassign $args - options(-localCpu)]
              puts "new args is \"$args\""
              puts "set_num_threads $options(-localCpu)"
              }
          -help {
              puts "old args is $args"
              set args [lassign $args - options(-help) ]
              puts "new args is \"$args\""
              puts "Usage: set_multi_cpu_usage -localCpu <num_of_threads>"
              }
        }
    }
}
```
It accepts command-line style arguments through a parameter array that manages options for local CPU thread allocation. When invoked with the -localCpu flag followed by a numeric value, the procedure configures the underlying EDA tools to utilize the specified number of processor threads for computationally intensive tasks like synthesis and timing analysis. This is accomplished by calling another procedure named set_num_threads with the appropriate thread count. The procedure also includes a helpful -help option that displays usage instructions when requested. 

When __set_multi_cpu_usage -localCpu 8 -help__ commnad is executed, it will go through 2 iterations like in the 1st part shown below. When __set_multi_cpu_usage -localCpu 8__ command is executed, it will go through 1 iterations like shown in the below part.

![Image](https://github.com/user-attachments/assets/00594860-53f3-455a-9faf-dd07f7617b84)


3) read_verilog.proc
The read_verilog command is used to read Verilog or SystemVerilog source files into design tools. 

```
proc read_verilog {arg1} {
puts "set_verilog_fpath $arg1"
}
```


4) read_lib.proc

The __read_lib proc__ is a Tcl procedure designed to handle library files in ASIC design automation workflows. This procedure is part of a larger TCL scripting framework that automates the frontend of ASIC design.

The procedure accepts multiple options and converts standard library specifications into OpenTimer format.
```
proc read_lib args {
	array set options {-late <late_lib_path> -early <early_lib_path> -help ""}
	while {[llength $args]} {
		switch -glob -- [lindex $args 0] {
		-late {
			set args [lassign $args - options(-late) ]
			puts "set_late_celllib_fpath $options(-late)"
		      }
		-early {
			set args [lassign $args - options(-early) ]
			puts "set_early_celllib_fpath $options(-early)"
		       }
		-help {
			set args [lassign $args - options(-help) ]
			puts "Usage: read_lib -late <late_lib_path> -early <early_lib_path>"
			puts "-late <provide late library path>"
			puts "-early <provide early library path>"
		      }	
		default break
		}
	}
}
```

The procedure has three main options:

- -late: Specifies the path to the late library file used for setup timing analysis

- -early: Specifies the path to the early library file used for hold timing analysis

- -help: Displays usage information for the procedure

When called with the appropriate options, the procedure generates commands in OpenTimer format (e.g., set_late_celllib_fpath and set_early_celllib_fpath) that are used by the timing analysis tool.

This proc works alongside other procedures like read_verilog.proc and read_sdc.proc to convert standard design files into formats compatible with OpenTimer for static timing analysis. It's part of a comprehensive TCL framework for automating ASIC design flows, particularly for timing analysis and quality of results (QoR) generation.

5) read_sdc.proc

__read_sdc__ is a Tcl command used in EDA tools to read Synopsys Design Constraint (SDC) files into the design environment

The read_sdc proc is a large proc file which will be covered in parts.

```
proc read_sdc {arg1} {
set sdc_dirname [file dirname $arg1]
set sdc_filename [lindex [split [file tail $arg1] .] 0 ]
set sdc [open $arg1 r]
set tmp_file [open /tmp/1 "w"] 
puts -nonewline $tmp_file [string map {"\[" "" "\]" " "} [read $sdc]]     
close $tmp_file
}
```
The above script is used to remvoe square bractets "[]" and replace it with "" as shown in below figure.

![Image](https://github.com/user-attachments/assets/280c7541-1efa-43c2-ade4-d8deaf87c3e0)

![Image](https://github.com/user-attachments/assets/b93e7cf6-22a7-48bf-9336-43df32023572)

```
set tmp_file [open /tmp/1 r]
set timing_file [open /tmp/3 w]
set lines [split [read $tmp_file] "\n"]
set find_clocks [lsearch -all -inline $lines "create_clock*"]
foreach elem $find_clocks {
	set clock_port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
	puts "clock_port_name is \"$clock_port_name\" "
	set clock_period [lindex $elem [expr {[lsearch $elem "-period"]+1}]]
	puts "clock_period is \"$clock_period\" "
	set duty_cycle [expr {100 - [expr {[lindex [lindex $elem [expr {[lsearch $elem "-waveform"]+1}]] 1]*100/$clock_period}]}]
	puts "duty_cycle is \"$duty_cycle\" "
	puts $timing_file "clock $clock_port_name $clock_period $duty_cycle"
	}
close $tmp_file

```
The above script is used to convert create_clock constraitns into format [2] which can be understandle by Opentimer tool. Basically it searches a pattern __create_clock__  and then gets the clock_port_name, clock_period and calucaltes dutry cycle. And then writes all the above values in /tmp/3 file as shown in below figure.

![Image](https://github.com/user-attachments/assets/b1b2a8d8-5e5e-42da-86c1-e7896cdc37b2)

![Image](https://github.com/user-attachments/assets/4f6dff5c-a1a8-437c-8ae9-1df6bb72b76a)


```
set find_keyword [lsearch -all -inline $lines "set_clock_latency*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_clocks"]+1}]]
	if {![string match $new_port_name $port_name]} {
        	set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
        	set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_clocks"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
		puts -nonewline $tmp2_file "\nat $port_name $delay_value"
	}
}

close $tmp2_file
```

The above script is used to convert set_clock_latency constraitns into format [2] which can be understandle by Opentimer tool. Basically it searches a pattern __set_clock_latency__  and then gets all the parameters. Then writes all the above values in /tmp/2 file which is furher written in .timings file as shown in below figure.

![Image](https://github.com/user-attachments/assets/b1b2a8d8-5e5e-42da-86c1-e7896cdc37b2)

![Image](https://github.com/user-attachments/assets/f52c7c59-272c-4f97-bbc8-18d4f9d94fc4)

```
set find_keyword [lsearch -all -inline $lines "set_clock_transition*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_clocks"]+1}]]
        if {![string match $new_port_name $port_name]} {
		set new_port_name $port_name
		set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
        	set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_clocks"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $tmp2_file "\nslew $port_name $delay_value"
	}
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file

```
The above script is used to convert set_clock_transition constraitns into format [2] which can be understandle by Opentimer tool. Basically it searches a pattern __set_clock_transition__  and then gets all the parameters. Then writes all the above values in /tmp/2 file which is furher written in .timings file as shown in below figure.

![Image](https://github.com/user-attachments/assets/b1b2a8d8-5e5e-42da-86c1-e7896cdc37b2)

![Image](https://github.com/user-attachments/assets/a554aa97-1b28-41c0-81f9-5da5cd0414d2)

```
set find_keyword [lsearch -all -inline $lines "set_input_delay*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
		set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_ports"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $tmp2_file "\nat $port_name $delay_value"
	}
}
close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file
```

The above script is used to convert set_input_delay constraitns into format [2] which can be understandle by Opentimer tool. Basically it searches a pattern __set_input_delay__  and then gets all the parameters. Then writes all the above values in /tmp/2 file which is furher written in .timings file as shown in below figure.

![Image](https://github.com/user-attachments/assets/969a2859-13a0-4b8b-b0c3-b0a0758aa615)

![Image](https://github.com/user-attachments/assets/fc2e146a-a6cc-4297-af2e-7291e2ec1b75)


```
set find_keyword [lsearch -all -inline $lines "set_input_transition*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
        	set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_ports"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $tmp2_file "\nslew $port_name $delay_value"
	}
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file

```
The above script is used to convert set_input_transition constraitns into format [2] which can be understandle by Opentimer tool. Basically it searches a pattern __set_input_transition__  and then gets all the parameters and convert into Opentimer format. Then writes all the above values in /tmp/2 file which is furher written in .timings file as shown in below figure.

![Image](https://github.com/user-attachments/assets/969a2859-13a0-4b8b-b0c3-b0a0758aa615

![Image](https://github.com/user-attachments/assets/28bf650a-4229-46e3-99ce-a138ec8e4539)

```
set find_keyword [lsearch -all -inline $lines "set_output_delay*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
        	set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_ports"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $tmp2_file "\nrat $port_name $delay_value"
	}
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file
```

The above script is used to convert set_output_delay constraitns into format [2] which can be understandle by Opentimer tool. Basically it searches a pattern __set_output_delay__  and then gets all the parameters and convert into Opentimer format. Then writes all the above values in /tmp/2 file which is furher written in .timings file as shown in below figure.

![Image](https://github.com/user-attachments/assets/36a57d47-b2d6-4273-a9ab-1cff21d1583f)

![Image](https://github.com/user-attachments/assets/badb89bf-5bdb-483a-9d17-80c754880a54)

```
set ot_timing_file [open $sdc_dirname/$sdc_filename.timing w]
set timing_file [open /tmp/3 r]
while {[gets $timing_file line] != -1} {
        if {[regexp -all -- {\*} $line]} {
                set bussed [lindex [lindex [split $line "*"] 0] 1]
                set final_synth_netlist [open $sdc_dirname/$sdc_filename.final.synth.v r]
                while {[gets $final_synth_netlist line2] != -1 } {
                        if {[regexp -all -- $bussed $line2] && [regexp -all -- {input} $line2] && ![string match "" $line]} {
                        puts -nonewline $ot_timing_file "\n[lindex [lindex [split $line "*"] 0 ] 0 ] [lindex [lindex [split $line2 ";"] 0 ] 1 ] [lindex [split $line "*"] 1 ]"
                        } elseif {[regexp -all -- $bussed $line2] && [regexp -all -- {output} $line2] && ![string match "" $line]} {
                        puts -nonewline $ot_timing_file "\n[lindex [lindex [split $line "*"] 0 ] 0 ] [lindex [lindex [split $line2 ";"] 0 ] 1 ] [lindex [split $line "*"] 1 ]"
                        }
                }
        } else {
        puts -nonewline $ot_timing_file  "\n$line"
        }
}

close $timing_file
puts "set_timing_fpath $sdc_dirname/$sdc_filename.timing"
}

```
The above script is used to expand bussed ports into format [2] which can be understandle by Opentimer tool as shown below.

Before expanding

![Image](https://github.com/user-attachments/assets/1fef3392-2aa6-4e8b-860f-95c07982a73e)

after expanding

![Image](https://github.com/user-attachments/assets/50d89034-e37e-4509-911e-23c734f17629)

#### Creating scripts for Opentimer

```

if {$enable_prelayout_timing == 1} {
	puts "\nInfo: enable prelayout_timing is $enable_prelayout_timing. Enabling zero-wire load parasitics"
	set spef_file [open $OutputDirectory/$DesignName.spef w]
	puts $spef_file "*SPEF \"IEEE 1481-1998\""
	puts $spef_file "*DESIGN \"$DesignName\""
	puts $spef_file "*DATE \"Sun Jun 11 11:59:00 2023\""
	puts $spef_file "*VENDOR \"VLSI System Design\""
	puts $spef_file "*PROGRAM \"TCL Workshop\""
	puts $spef_file "*DATE \"0.0\""
	puts $spef_file "*DESIGN FLOW \"NETLIST_TYPE_VERILOG\""
	puts $spef_file "*DIVIDER /"
	puts $spef_file "*DELIMITER : "
	puts $spef_file "*BUS_DELIMITER [ ]"
	puts $spef_file "*T_UNIT 1 PS"
	puts $spef_file "*C_UNIT 1 FF"
	puts $spef_file "*R_UNIT 1 KOHM"
	puts $spef_file "*L_UNIT 1 UH"
}
close $spef_file
```
The above script creates a .spef file and writes all the required commands into it as shown in below

![Image](https://github.com/user-attachments/assets/80c9ba14-20a7-408b-999e-53e4eb026f96)

```
set conf_file [open $OutputDirectory/$DesignName.conf a]
puts $conf_file "set_spef_fpath $OutputDirectory/$DesignName.spef"
puts $conf_file "init_timer"
puts $conf_file "report_timer"
puts $conf_file "report_wns"
puts $conf_file "report_tns"
puts $conf_file "report_worst_paths -numPaths 10000 " 
close $conf_file
```

The above script creates a .conf file and writes all the required commands into it which is then passed as input to Opentimer tool as shown in below

![Image](https://github.com/user-attachments/assets/a17bd60a-68c0-4ab0-8c5a-74aed013224e)

#### Quality of results (QOR) generation algorithm

This is the final sub-task which involves output generation as a datasheet.

```
set time_elapsed_in_us [time {exec /home/vsduser/OpenTimer-1.0.5/bin/OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results} ]
set time_elapsed_in_sec "[expr {[lindex $time_elapsed_in_us 0]/100000}]sec"
puts "\nInfo: STA finished in $time_elapsed_in_sec seconds"
puts "\nInfo: Refer to $OutputDirectory/$DesignName.results for warings and errors"

```
The above script is used to executed the Opnetimer tool by passing openMSP430.conf file as an input the results are stored in openMSP430.results.It also stores the time elapsed during STA in microseconds and seconds as shown below.

![Image](https://github.com/user-attachments/assets/e00ffcf6-c495-42d4-bd4c-5c17cd05621f)



```
#-------------------- Finding worst outptut violation --------------------------#
set worst_RAT_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {RAT}
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
		set worst_RAT_slack "[expr {[lindex $line 3]/1000}]ns"
		break
	} else {
		continue
	}
}
close $report_file
#--------------------------- Finding number of outptut violation ------------------------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
	incr count [regexp -all -- $pattern $line]
}
set Number_output_violations $count
close $report_file

#--------------------------- Finding worst setup violation -------------------------#
set worst_negative_setup_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r] 
set pattern {Setup}
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
		set worst_negative_setup_slack "[expr {[lindex $line 3]/1000}]ns"
		break
	} else {
		continue
	}
}
close $report_file


#-------------------------find number of setup violations--------------------------------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
	incr count [regexp -all -- $pattern $line]
}
set Number_of_setup_violations $count
close $report_file

#-------------------------find worst hold violation--------------------------------#
set worst_negative_hold_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r] 
set pattern {Hold}
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
		set worst_negative_hold_slack "[expr {[lindex $line 3]/1000}]ns"
		break
	} else {
		continue
	}
}
close $report_file

#-------------------------find number of hold violations--------------------------------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
	incr count [regexp -all -- $pattern $line]
}
set Number_of_hold_violations $count
close $report_file

#-------------------------find number of instances--------------------------------#

set pattern {Num of gates}
set report_file [open $OutputDirectory/$DesignName.results r] 
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
		set Instance_count "[lindex [join $line " "] 4 ]"
		break
	} else {
		continue
	}
}
close $report_file


puts "DesignName is \{$DesignName\}"
puts "time_elapsed_in_sec is \{$time_elapsed_in_sec\}"
puts "Instance_count is \{$Instance_count\}"
puts "worst_negative_setup_slack is \{$worst_negative_setup_slack\}"
puts "Number_of_setup_violations is \{$Number_of_setup_violations\}"
puts "worst_negative_hold_slack is \{$worst_negative_hold_slack\}"
puts "Number_of_hold_violations is \{$Number_of_hold_violations\}"
puts "worst_RAT_slack is \{$worst_RAT_slack\}"
puts "Number_output_violations is \{$Number_output_violations\}"
```

The above script can be used to find different parameters such as worst hold violation, no of hold vioalations etc... which are reported in final output and also displays on terminal.

![Image](https://github.com/user-attachments/assets/e4c08501-1dae-4fc8-a7ae-7d7a105a8135)

```
puts "\n"
puts "						****PRELAYOUT TIMING RESULTS**** 					"
set formatStr "%15s %15s %15s %15s %15s %15s %15s %15s %15s"

puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts [format $formatStr "DesignName" "Runtime" "Instance Count" "WNS Setup" "FEP Setup" "WNS Hold" "FEP Hold" "WNS RAT" "FEP RAT"]
puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
foreach design_name $DesignName runtime $time_elapsed_in_sec instance_count $Instance_count wns_setup $worst_negative_setup_slack fep_setup $Number_of_setup_violations wns_hold $worst_negative_hold_slack fep_hold $Number_of_hold_violations wns_rat $worst_RAT_slack fep_rat $Number_output_violations {
	puts [format $formatStr $design_name $runtime $instance_count $wns_setup $fep_setup $wns_hold $fep_hold $wns_rat $fep_rat]
}

puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts "\n"
	
```
The above script can be used to show the results in Horizontal format like shown in below figure.

![Image](https://github.com/user-attachments/assets/bfb816b1-82a4-4902-9227-75c82088b225)
