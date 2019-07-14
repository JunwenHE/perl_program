#!/bin/perl
#Author: Junwen HE, Date of complention: 3/JUN/2019
#This program is to read from a file similar to the output of UNIX' command 'top' by Perl.
#This program processes opinions and print the requested output to the standard output.

#Declare first two variables that recevice the first two arguments.
$option = $ARGV[0];
$user_insert = $ARGV[1];

#Using condition control to identity which option then read the file and implmenet into specific subroutine.
if($option eq "-a") {
	open(TASK_FILE, "<" ,$user_insert) || die "Error: No such file or directory. Please select valid file\n";
	print_alphabetically();
} elsif($option eq "-m") {
	open(TASK_FILE,"<", $user_insert) || die "Error: No such file or directory. Please select valid file.\n";
	calculate_total_memory();
} elsif($option eq "-t"){
	open(TASK_FILE,"<", $user_insert) || die "Error: No such file or directory. Please select valid file.\n";
	calculate_cpu_time();
} elsif($option eq "-s") {
	memory_threshold();
} elsif($option eq "-n"){
	if (scalar(@ARGV) == 2 ){
		information();
	} else {
		#Show error if the input arguments are not required with a file.
		print "Error: invalid arugment! Please try again.\n";
	}
} else {
	#Show error if not matched the option above.
	print "Error: invalid input! Please try again.\n";
}

#Declare initial array variables for collecting file content by specific index of loop.
@task_process_ids;
@task_memory_sizes;
@task_cpu_time;
@task_program_names;

#This subroutine is to display the print all the lines of file sorted alphabetically by field program name.
#Using hash variable to find out and sorted the index of program name, then other detail is printed based on the sorted index of the hash. 
sub print_alphabetically {

	#Declare the initial variables for collecting program name and its index.
	my %task_index;
	$index = 0;
  
	#using file test operatior to check the content of file is empty or not.
	if(-s $user_insert) {
  
		while(<TASK_FILE>){
		
			#During the while loop of reading content each line of the file, using regular expression to collect each element by spliting the space.
			#Then add these elements to specific array based on the index in each line.
			@lines = split(/\s/, $_);
			push (@task_process_ids, $lines[0]);
			push (@task_memory_sizes, $lines[1]);
			push (@task_cpu_time, $lines[2]);
			push (@task_program_names, $lines[3]);
	
			#Add the program name as key into hash.
			#Recording the index of line in file as a value into hash, for the relevant content matching.
			$task_index{$lines[3]}=$index;
			$index++;
		}
	
		#Sorted the program name alphabetically in the hash.
		#then print the whole content from the array which is based on the index of after sorted of hash value.
		foreach my $key (sort keys (%task_index)) {
			my $result_index = $task_index{$key};
			print "@task_process_ids[$result_index] @task_memory_sizes[$result_index] @task_cpu_time[$result_index] @task_program_names[$result_index]\n";
		}
	}
	else {
		#Print message if the content of the file is empty.
		print "No tasks found.\n";
	}
}

#This subroutine the calculation of total memory from the file.
sub calculate_total_memory {

	#Inital the total memory as zero.
	my $total_memory = 0;
	
	#Again, adding memory value into array from the file by regular expression.
    if(-s $user_insert) {
		while(<TASK_FILE>) {
			@lines = split(/\s/, $_);
			push (@task_memory_sizes, $lines[1]);
		}

		#Calculate and print the total value of all programs' memory by loop method.
		foreach my $memory(@task_memory_sizes) {
			$total_memory = $total_memory + $memory;
		}
		print "Total memory size: $total_memory KB.\n";
	} else {
		print "No memory used.\n";
    }
}

#Calculating total cup time used by collecting values from file.
#This subroutine is similar to above, which just only change specific index in each line content from the file.
sub calculate_cpu_time {
	#Inital total cpu used time as zero.
	my @task_cpu_time;
	
    if(-s $user_insert) {
		while(<TASK_FILE>) {
			@lines = split(/\s/, $_);
			push (@task_cpu_time, $lines[2]);
		}

		foreach my $cpu_time(@task_cpu_time) {
			$total_cpu_time = $total_cpu_time + $cpu_time;
		}
		print "Total CPU time: $total_cpu_time seconds.\n";
    }else{
		print "No CPU time used.\n"
    };
}

#This subroutine is to print all the lines of file where the value of field memory size. 
#which is greater than or equal to the value of memoery threshold by user input. 
sub memory_threshold {
	#Declare the initial variable for memoery threshold value as zero.
	#Assign the variable of incorrect input argument is false.
    my $threshold_value = 0;
    my $wrong_argument = "false";
	
	#Read the file from the third argument due to the second argument for inputing memoery threshold value.
    open(TASK_FILE,"<",$ARGV[2]) || die "Error: No such file or directory. Please select valid file.\n";
	
	#Check the second argument is digit by regular expression. Then stored into memory threshold variable.
    if ($user_insert =~ /\d+/){
		$threshold_value = $user_insert;
    } else {
		#Print message if the argument doesn't meet the requirement, and chenage the statment of worng arugment as true.
		print "Invalid arugment.\n";
		$wrong_argument = "true";
    }

	#Check the content of the file and there are not worng argument, then start the collecting progrss.
    if(-s $ARGV[2] && $wrong_argument eq "false") {
		#Adding the content to specific array by removing the space in the file.
		while(<TASK_FILE>){
			@lines = split(/\s/, $_);
			push (@task_process_ids, $lines[0]);
			push (@task_memory_sizes, $lines[1]);
			push (@task_cpu_time, $lines[2]);
			push (@task_program_names, $lines[3]);
		}
	  
		#Get the number line from the file bsaed on the size of array.
		$task_length = scalar(@task_memory_sizes);

		#Finding the memoery which is greater than or euqal to memory threshold value.
		#Print the result which is matched the criteria. 
		for($loop_index = 0; $loop_index < $task_length; $loop_index++){
			if(@task_memory_sizes[$loop_index] >= $threshold_value) {
				print "@task_process_ids[$loop_index] @task_memory_sizes[$loop_index] @task_cpu_time[$loop_index] @task_program_names[$loop_index]\n";
			}
		}

    } elsif ($wrong_argument eq "true"){
		#Print the invalid input message if the worng argument marked as true.
        print "Please enter numeric value in this option.\n";
    } else {
		#Print the message if the file is empty.
		print "No tasks with the specified memory size.\n";
    }
}

#This subroutine collected and print the author information only.  
sub information{
	print "Name: Junwen \nSurname: HE\nStudent ID: 12207080\nDate of complention: 3/JUN/2019\n";
}
