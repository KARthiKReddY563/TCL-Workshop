
  
set enable_prelayout_timing 1

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

#----------------------------------------------------------------------------------------#
#------------------ Checking files/paths exist or not------------------------------------#
#----------------------------------------------------------------------------------------#
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


#----------------------------------------------------------------------------------------#
#------------------------------Writing SDC constraints ----------------------------------#
#----------------------------------------------------------------------------------------#

puts "\n Info: Dumping SDC constraints for $DesignName"
::struct::matrix constraints
set chan [open $ConstraintsFile]
csv::read2matrix $chan constraints , auto
close $chan
set constr_rows [constraints rows]
puts " number of rows in constraints file = $constr_rows "
set constr_columns [constraints columns]
puts " number of columns in constraints file = $constr_columns "
set clock_start [lindex [lindex [constraints search all CLOCKS] 0] 1]
set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0] 0]
#puts "clock_start =  $clock_start"
#puts "clock_start_column = $clock_start_column"

set input_ports_start [lindex [lindex [ constraints search all INPUTS] 0] 1]
#puts "input_ports_start =$input_ports_start"
set output_ports_start [lindex [lindex [ constraints search all OUTPUTS] 0] 1]
#puts "output_ports_start = $output_ports_start "


#----------------------------------------------------------------------------------------#
#------------------ TO get individual clock parameters ----------------------------------#
#----------------------------------------------------------------------------------------#

set clock_early_rise_delay_start [lindex [lindex [ constraints search rect $clock_start_column $clock_start [expr {$constr_columns -1}] [expr {$input_ports_start -1}] early_rise_delay] 0 ] 0 ]
set clock_early_fall_delay_start [lindex [lindex [ constraints search rect $clock_start_column $clock_start [expr {$constr_columns -1}] [expr {$input_ports_start -1}] early_fall_delay] 0 ] 0 ]
set clock_late_rise_delay_start [lindex [lindex [ constraints search rect $clock_start_column $clock_start [expr {$constr_columns -1}] [expr {$input_ports_start -1}] late_rise_delay] 0 ] 0 ]
set clock_late_fall_delay_start [lindex [lindex [ constraints search rect $clock_start_column $clock_start [expr {$constr_columns -1}] [expr {$input_ports_start -1}] late_fall_delay] 0 ] 0 ]
set clock_early_rise_slew_start [lindex [lindex [ constraints search rect $clock_start_column $clock_start [expr {$constr_columns -1}] [expr {$input_ports_start -1}] early_rise_slew] 0 ] 0 ]
set clock_early_fall_slew_start [lindex [lindex [ constraints search rect $clock_start_column $clock_start [expr {$constr_columns -1}] [expr {$input_ports_start -1}] early_fall_slew] 0 ] 0 ]
set clock_late_rise_slew_start [lindex [lindex [ constraints search rect $clock_start_column $clock_start [expr {$constr_columns -1}] [expr {$input_ports_start -1}] late_rise_slew] 0 ] 0 ]
set clock_late_fall_slew_start [lindex [lindex [ constraints search rect $clock_start_column $clock_start [expr {$constr_columns -1}] [expr {$input_ports_start -1}] late_fall_slew] 0 ] 0 ]

#puts "clock_early_rise_delay_start = $clock_early_rise_delay_start"
#puts "clock_early_fall_delay_start = $clock_early_fall_delay_start"
#puts "clock_late_rise_delay_start = $clock_late_rise_delay_start"
#puts "clock_late_fall_delay_start = $clock_late_fall_delay_start"
#puts "clock_early_rise_slew_start = $clock_early_rise_slew_start"
#puts "clock_early_fall_slew_start = $clock_early_fall_slew_start"
#puts "clock_late_rise_slew_start = $clock_late_rise_slew_start"
#puts "clock_late_fall_slew_start = $clock_late_fall_slew_start"

#-----------------------------------------------------------------------------------------------#
#------------------ Writing individual clock parameters into sdc_file---------------------------#
#-----------------------------------------------------------------------------------------------#
set sdc_file [open $OutputDirectory/$DesignName.sdc "w"]
set i [expr {$clock_start+1}]
set end_of_ports [expr {$input_ports_start -1}]


puts "\n Info-SDC: Working on clock constraints..."



while {$i< $end_of_ports} {
        #puts "Working on clock [constraints get cell 0 $i ]"
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
 

#----------------------------------------------------------------------------------------#
#------------------ TO get individual input parameters ----------------------------------#
#----------------------------------------------------------------------------------------#

set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns-1}] [expr {$output_ports_start-1}] early_rise_delay] 0] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns-1}] [expr {$output_ports_start-1}] early_fall_delay] 0] 0]
set input_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns-1}] [expr {$output_ports_start-1}] late_rise_delay] 0] 0]
set input_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns-1}] [expr {$output_ports_start-1}] late_fall_delay] 0] 0]
set input_early_rise_slew_start [lindex [lindex [ constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns -1}] [expr {$output_ports_start -1}] early_rise_slew] 0 ] 0 ]
set input_early_fall_slew_start [lindex [lindex [ constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns -1}] [expr {$output_ports_start -1}] early_fall_slew] 0 ] 0 ]
set input_late_rise_slew_start [lindex [lindex [ constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns -1}] [expr {$output_ports_start -1}] late_rise_slew] 0 ] 0 ]
set input_late_fall_slew_start [lindex [lindex [ constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns -1}] [expr {$output_ports_start -1}] late_fall_slew] 0 ] 0 ]
#puts "input_early_rise_delay = $input_early_rise_delay_start"
#puts "input_early_fall_delay = $input_early_fall_delay_start"
#puts "input_late_rise_delay = $input_late_rise_delay_start"
#puts "input_late_fall_delay = $input_late_fall_delay_start"
#puts "input_early_rise_slew_start = $input_early_rise_slew_start"
#puts "input_early_fall_slew_start = $input_early_fall_slew_start"
#puts "input_late_rise_slew_start = $input_late_rise_slew_start"
#puts "input_late_fall_slew_start = $input_late_fall_slew_start"


#-----------------------------------------------------------------------------------------------#
#------------------ Writing individual input parameters into sdc_file---------------------------#
#-----------------------------------------------------------------------------------------------#
set related_clock [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$constr_columns-1}] [expr {$output_ports_start-1}]  clocks] 0 ] 0]

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
    set inp_ports [concat [constraints get cell 0 $i]*]
	#puts "\n Bussed"
	#puts "Input port is \"$inp_ports\""
} else {

    set inp_ports [constraints get cell 0 $i]
	#puts "\n Not Bussed"
	#puts "Input port is \"$inp_ports\""
}
	#puts "input poret name is $inp_ports and count is $count"

	puts -nonewline $sdc_file "\nset_input_delay -clock  \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_delay_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included  [constraints get cell $input_early_fall_delay_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_delay -clock  \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included  [constraints get cell $input_late_rise_delay_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_delay -clock  \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included  [constraints get cell $input_late_fall_delay_start $i] \[get_ports $inp_ports\]"

	puts -nonewline $sdc_file "\nset_input_transition -clock  \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_slew_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included  [constraints get cell $input_early_fall_slew_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_transition -clock  \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included  [constraints get cell $input_late_rise_slew_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_transition -clock  \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included  [constraints get cell $input_late_fall_slew_start $i] \[get_ports $inp_ports\]"

	set i [expr {$i+1}]
}
close $tmp2_file


#----------------------------------------------------------------------------------------#
#------------------ TO get individual output parameters ---------------------------------#
#----------------------------------------------------------------------------------------#


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
set i [expr {$output_ports_start+1}]
set end_of_ports [expr {$constr_rows-1}]
puts "\nInfo-SDC: Working on Output constraints....."
puts "\nInfo-SDC: Categorizing output ports as bits and bussed"



#-----------------------------------------------------------------------------------------------#
#------------------ Writing individual output parameters into sdc_file--------------------------#
#-----------------------------------------------------------------------------------------------#

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




#----------------------------------------------------------------------------------------#
#--------------------------- Hierarchy Check --------------------------------------------#
#----------------------------------------------------------------------------------------#


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



# Catching all the errors in Log file

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

#-----------------------------------------------------------------------------------------------------__#
#------------------------------- Main Synthesis Script -------------------------------------------------#
#-------------------------------------------------------------------------------------------------------#

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


#-------------------------------------------------------------------------------------------------#
#--------------------- Run Synthesis script using Yosys ------------------------------------------#
#-------------------------------------------------------------------------------------------------#


if {[catch { exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log} msg]} {
	puts "\nError: Syntesis failed due to errors. Please refer to log $OutputDirectory/$DesignName.synthesis.log for errors"
	exit
} else {
	puts "\nInfo: Synthesis finished sucessfully"
}

puts "\nInfo: Please refert olog $OutputDirectory/$DesignName.synthesis.log"

#-------------------------------------------------------------------------------------------------#
#--------------------- Edit synth.v to be usable by Opentimer ------------------------------------#
#-------------------------------------------------------------------------------------------------#


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


#-------------------------------------------------------------------------------------------------#
#-------------------------------------STA using Opentimer-----------------------------------------#
#-------------------------------------------------------------------------------------------------#

puts "\nInfo: Timing Analysis Started ... "
puts "\nInfo: Initializing number of threads, libraries, sdc, verilog netlist path..."

source /home/vsduser/vsdsynth/procs/reopenStdout.proc
source /home/vsduser/vsdsynth/procs/set_num_threads.proc
reopenStdout $OutputDirectory/$DesignName.conf
set_multi_cpu_usage -localCpu 4

source /home/vsduser/vsdsynth/procs/read_lib.proc
read_lib -early /home/vsduser/vsdsynth/osu018_stdcells.lib
read_lib -late /home/vsduser/vsdsynth/osu018_stdcells.lib

source /home/vsduser/vsdsynth/procs/read_verilog.proc
read_verilog $OutputDirectory/$DesignName.final.synth.v

source /home/vsduser/vsdsynth/procs/read_sdc.proc
read_sdc $OutputDirectory/$DesignName.sdc
reopenStdout /dev/tty



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

set conf_file [open $OutputDirectory/$DesignName.conf a]
puts $conf_file "set_spef_fpath $OutputDirectory/$DesignName.spef"
puts $conf_file "init_timer"
puts $conf_file "report_timer"
puts $conf_file "report_wns"
puts $conf_file "report_tns"
puts $conf_file "report_worst_paths -numPaths 10000 " 
close $conf_file


#--------------------------------------------------------------------------------------------------------#
#-------------------------------------------- Finding STA runtime ---------------------------------------#
#--------------------------------------------------------------------------------------------------------#

set time_elapsed_in_us [time {exec /home/vsduser/OpenTimer-1.0.5/bin/OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results} ]
set time_elapsed_in_sec "[expr {[lindex $time_elapsed_in_us 0]/100000}]sec"
puts "\nInfo: STA finished in $time_elapsed_in_sec seconds"
puts "\nInfo: Refer to $OutputDirectory/$DesignName.results for warings and errors"

#--------------------------------------------------------------------------------------------------------#
#------------------------------------- Finding worst outptut violation ----------------------------------#
#--------------------------------------------------------------------------------------------------------#


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
#--------------------------------------------------------------------------------------------------------#
#--------------------------------- Finding number of outptut violation ----------------------------------#
#--------------------------------------------------------------------------------------------------------#


set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
	incr count [regexp -all -- $pattern $line]
}
set Number_output_violations $count
close $report_file


#--------------------------------------------------------------------------------------------------------#
#------------------------------------- Finding worst setup violation ------------------------------------#
#--------------------------------------------------------------------------------------------------------#


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

#--------------------------------------------------------------------------------------------------------#
#-------------------------Finding number of setup violations --------------------------------------------#
#--------------------------------------------------------------------------------------------------------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
	incr count [regexp -all -- $pattern $line]
}
set Number_of_setup_violations $count
close $report_file
#--------------------------------------------------------------------------------------------------------#
#-------------------------------Finding worst hold violation --------------------------------------------#
#--------------------------------------------------------------------------------------------------------#
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
#--------------------------------------------------------------------------------------------------------#
#--------------------------------Finding number of hold violations --------------------------------------#
#--------------------------------------------------------------------------------------------------------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
	incr count [regexp -all -- $pattern $line]
}
set Number_of_hold_violations $count
close $report_file
#--------------------------------------------------------------------------------------------------------#
#------------------------------Finding number of instances ----------------------------------------------#
#--------------------------------------------------------------------------------------------------------#

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

#puts "DesignName is \{$DesignName\}"
#puts "time_elapsed_in_sec is \{$time_elapsed_in_sec\}"
#puts "Instance_count is \{$Instance_count\}"
#puts "worst_negative_setup_slack is \{$worst_negative_setup_slack\}"
#puts "Number_of_setup_violations is \{$Number_of_setup_violations\}"
#puts "worst_negative_hold_slack is \{$worst_negative_hold_slack\}"
#puts "Number_of_hold_violations is \{$Number_of_hold_violations\}"
#puts "worst_RAT_slack is \{$worst_RAT_slack\}"
#puts "Number_output_violations is \{$Number_output_violations\}"

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
