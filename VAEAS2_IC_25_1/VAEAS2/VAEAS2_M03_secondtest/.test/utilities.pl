#!/usr/local/bin/perl
#
#  This routine prints a message to the standard output stream and causes
#  'perl' to quit with a non-zero exit status.  We use this rather than
#  'die' so that all error messages have a standard appearence ('die'
#   prints line information with the message you pass it -- emulating
#  this behavior may be difficult from non-perl utilities).  Non-perl
#  testing utilities should use the format shown here:
#
#      <utility_name>: ERROR: <descriptive message>

#
# This routine checks the current operating system and returns an error if it
# is a supported operated system intended for this database.
#
sub runningSupportedOS
{
   return($^O) if(&runningUnix() || &runningNT() || &runningLinux());
   return("");
}

sub runningLinux
{
   return($^O) if($^O eq 'linux');
   return("");
}

sub runningUnix
{
   return($^O) if(($^O eq 'solaris') || ($^O eq 'hpux') || ($^O eq 'aix'));
   return("");
}


sub runningNT
{
   return($^O) if($^O eq 'MSWin32');
   return("");
}

#
#  This routine should be used when an error of any kind has been detected.
#
sub error
{
   print(STDOUT "$0: ERROR: @_\n");
   print(@_) if($verbose);
}

#
# Report the problems, errors and warnings into the output file.
#
sub report
{
   print("@_\n");
   &error("Couldn't write report file '$reportFile'.") unless(open(reportFile,">>$reportFile"));
   print(reportFile "@_\n");
   close(reportFile);
}

#
#  This routine prints a warning message to the standard output stream.
#  Non-perl testing utilities should use the format shown here.
#
sub warning
{
   print(STDOUT "$0: WARNING: @_\n");
   &error("Couldn't write report file '$reportFile'.") unless(open(reportFile,">>$reportFile"));
   print(reportFile "@_\n");
   close(reportFile);
}

sub info
{
   &error("Couldn't write report file '$reportFile'.") unless(open(reportFile,">>$reportFile"));
   print(reportFile "@_\n");
   close(reportFile);
}

#  This function locates the path to a normal executable that can be searched.
#  This function requires one argument: a string containing the name of an executable program.
#  The directories in the PATH environment variable are searched and the
#  first directory found containing an executable file matching the specified
#  program name is returned.  If the program cannot be found in any of the
#  path directories, an empty string ("") is returned.
#  For Windows functions that are executables can only be returned.
sub findExec
{
   #  Grab the name of (or path to) the executable in question.
   my ($progName) = (@_);

   #  Complain and exit if no program was specified.
   &report("No program specified to 'findExec'.") unless($progName);
   #  Nuke any leading/trailing spaces.
   $progName =~ s/ *//g;
   $cleanPath = $ENV{PATH};
###
   unless (runningNT()) 
   {
     $cleanPath =~ s/::/:/g;
     foreach $path (split(/:/,$cleanPath))
     {
        print(STDOUT "$path\n") if(-x "$path/progName"); 
        return($path) if(-x "$path/$progName");
     }
   }
###
   if (runningNT()) 
   {
     $cleanPath =~ s/;;/;/g;
     foreach $path (split(/;/,$cleanPath))
     {
        #$path =~ s/\\$//g;
        print(STDOUT "${path}\\${progName}.exe\n") if(-x "$path\\$progName.exe"); 
        print(STDOUT "${path}\\${progName}.exe\n") if(-x "$path\\$progName.ocx"); 
        print(STDOUT "${path}\\${progName}.exe\n") if(-x "$path\\$progName.sys"); 
        print(STDOUT "${path}\\${progName}.exe\n") if(-x "$path\\$progName.dll"); 
        return($path) if(-x "${path}\\${progName}.exe"); 
        return($path) if(-x "${path}\\${progName}.ocx"); 
        return($path) if(-x "${path}\\${progName}.sys"); 
        return($path) if(-x "${path}\\${progName}.dll"); 
     }
   }
   &report("ERROR: I could not find the executable for $progName.\n");
   return("");
}

#  This routine runs a program on the host operating system and captures
#  each line of its output into a list returned as the routine's value.
#
sub callCommand
{
   my @results = ();   #  Holds the return value for this routine.
   my ($commandLine) = (@_);
   my $commandName;
   my $pipeHndl;  #  Holds the file handle opened by the system call.

   ($commandName) = split(/ +/,$commandLine);
     #  Can we call this command?
     report("couldn't find '$commandName' in the search path. Check your path variable.")
        unless(findExec($commandName));
     #  Execute the command specified.
     report("couldn't call '$commandLine'.")
        unless(open(pipeHndl,"$commandLine |"));
     #  Grab the output generated from the command.
     while(<pipeHndl>)
     {
        chop();
        push(@results,$_);
     }
     #  Close the file handle to the command sub-process.
     close(pipeHndl);
     #  Return the output from the command.
     return(@results);
}


#
sub convertNumber
{
   my $result;
   my ($inputNumber) = (@_);
   my @tokens = ();
   my $preFraction = 0;
   my @digits = ();
   my $digit = 0;
   my $i = 0;
   my $count = 0;
   @tokens = split(/\./,$inputNumber);
   @digits = split(//, @tokens[0]);
   $digit = (@digits - 1) / 2;
   for ($count= (@digits) - 2; $i < $digit; $count=$count-2)
   {
     if(@digits[$count] =~ /0/) { $preFraction = 0; }
     if(@digits[$count] =~ /1/) { $preFraction = 1; }
     if(@digits[$count] =~ /2/) { $preFraction = 2; }
     if(@digits[$count] =~ /3/) { $preFraction = 3; }
     if(@digits[$count] =~ /4/) { $preFraction = 4; }
     if(@digits[$count] =~ /5/) { $preFraction = 5; }
     if(@digits[$count] =~ /6/) { $preFraction = 6; }
     if(@digits[$count] =~ /7/) { $preFraction = 7; }
     if(@digits[$count] =~ /8/) { $preFraction = 8; }
     if(@digits[$count] =~ /9/) { $preFraction = 9; }
     $result = ($preFraction * (10 ** ($i))) + $result;
     $i = $i + 1;
   }
   return($result);
}

#
#  This routine reads the contents of a text file into an array.  Each
#  item in the array is a complete line from the file and may be indexed
#  by its line number (starting at 0).
#  A single argument is required.  This is a string containing the path to
#  the file.
#  Upon successful completion, an array containing the file contents is
#  returned.
#
sub readTextFile
{
   #  Get the path to the file.
   my ($fileName) = @_;

   #  Local variables.
   my $fileHndl;
   my @theFile = ();

   #  Open the file; complain and exit if the file could not be opened.
   &report("can't open '$fileName'.") unless(open(fileHndl,$fileName));
   #  Get each line from the file.
   while(<fileHndl>)
   {
      #  Add this line to the array.
      push(@theFile,$_);
   }
   #  Close the file.
   close(fileHndl);
   #  Return the array containing the file information.
   return(@theFile);
}

#
#  This routine reads the contents of a directory map file into a hash.  Each
#  item in the hash is a complete line from the directory map and may be
#  indexed by the file it represents.
#
#  A single argument is required.  This is a string containing the path to
#  the directory map.
#
#  Upon successful completion, a hash containing the directory map is
#  returned.
#
sub readDirMap
{
   #  Get the path to the directory map.
   ($mapName) = @_;
   #  Local variables.
   my $mapHndl;
   my @items = ();
   my %theMap = ();
   #  Open the directory map.
   &report("can't open '$mapName'.") unless(open(mapHndl,$mapName));
   #  Get each line from the file.
   while(<mapHndl>)
   {
      #  Nuke the trailing carriage return (i.e. '\n').
      chop;
      #  Create a list of each token in the line.
      @items = split(/ /);
      #  Add an entry to the hash if there are 3 (!) items on this line.
      $theMap{@items[0]} = $_ if($#items eq 2);
   }
   #  Close the directory map file.
   close(mapHndl);
   #  Return the hash containing the map information.
   return(%theMap);
}
###
###  For debugging. Writes directory map hash to standard output stream.
###
sub dumpDirMap
{
   my (%theMap) = @_;
   foreach $key (keys(%theMap))
   {
      printf("%s =",$key);
      printf(" %s\n",$theMap{$key});
   }
}

#
#  This routine compares the contents of 2 system profiles.  Each profile
#  is stored as a hash and is passed to the routine by reference (!).  The
#  first profile is considered the "master" (a description of the desired
#  minimum hardware configuration required) and the second profile is
#  configuration of the current host.
#  Results are printed to the standard output stream.  A report is generated
#  for any of these conditions:
#  - CPU architecture/version is incorrect.
#  - Operating system/version is incorrect.
#  - Insufficient disk space available.
#  - Insufficient swap space available.
#  - Insufficient physical memory available.
#  This routine returns no meaningful value.  All results are written to
#  the default stream.
#
sub compareSysProfiles
{
######################## Read the requirements file #####
   #  Get the path to the profile.
   my ($profileName) = @_;
   my @fileContents;
   $sysFile = "sysinfo.txt";
   my %theProfile;
   my @tokens;
   @fileContents = &readTextFile($profileName);
   &report("Profile '$profileName' is empty.") unless($#fileContents >= 0);
   foreach $line (@fileContents)
   {
      chop($line);
      @tokens = split(/=/,$line);
      &report("Malformed profile entry '$line'.") unless($#tokens >= 1);
      @tokens[0] =~ s/\$//;
      @tokens[0] =~ s/ //g;
      @tokens[1] =~ s/\;//;
      @tokens[1] =~ s/\"//g;
      @tokens[1] =~ s/ //g;
      $theProfile{@tokens[0]} = @tokens[1];
   }

#  Assign the profile *references* to local variables.
#  Preset the system information variables to "Unknown".
#
$osName = "Unknown";
$osVersion = "Unknown";
$cpuArch = "Unknown";
$machType = "Unknown";
$physMem = "Unknown";
$totalSwap = "Unknown";
$freeDisk = "Unknown";

 @results =  &callCommand("uname") unless &runningNT();
 ($osName, $rest) = split(/ /,@results[0]) unless &runningNT();

if (&runningNT())
{
 $osName = "Windows";
# my @sysFileContents;
# &report("Make sure you have set the path variable to msinfo32.exe.\n") unless(&findExec("msinfo32"));
# @sysFileContents = &readTextFile($sysFile);
# &report("System profile '$sysFile' is empty.") unless($#sysFileContents >= 0);
# foreach $line (@sysFileContents)
 &callCommand("msinfo32 /categories systemsummary /report $sysFile");
 my $count = 0;
 open(sysFile, "$sysFile") or die("Could not open $sysfile.");
   foreach $line (<sysFile>) {
     chop($line);
     $count = $count + 1;
      if($count eq "9") { 
         @tokens = split(/\s+/,$line);
         $hostName = @tokens[2];
      }
      if($count eq "7") { 
         @tokens = split(/\s+/,$line);
         $osVersion = @tokens[1];
      }
      if($count eq "13") { 
         @tokens = split(/\s+/,$line);
         $cpuArch = @tokens[2] . @tokens[3];
      }
      if($count eq "12") { 
         @tokens = split(/\s+/,$line);
         $machType = @tokens[2] . @tokens[3];
      }
      if($count eq "24") { 
         @tokens = split(/\s+/,$line);
         $physMem = &convertNumber(@tokens[3]) unless(@tokens[4] =~ /G/);
          if(@tokens[4] =~ /G/) { $physMem = &convertNumber(@tokens[3]) * 1000; }
      }
      if($count eq "25") { 
         @tokens = split(/\s+/,$line);
         $freeDisk = &convertNumber(@tokens[3]) unless(@tokens[4] =~ /G/);
         if(@tokens[4] =~ /G/) { $freeDisk = &convertNumber(@tokens[3]) * 1000;  }
      }
      if($count eq "27") { 
         @tokens = split(/\s+/,$line);
         $totalSwap = &convertNumber(@tokens[3]) unless(@tokens[4] =~ /G/);
         if(@tokens[4] =~ /G/) { $totalSwap = (&convertNumber(@tokens[3]) * 1000); }
      }
      if($count > 30) {
        last;
      }
   }
   close(sysFile);
   &callCommand("cmd /c del $sysFile");
} # Done with NT/Windows.


#  If we're operating under Redhat Linux...
 if($osName eq "Linux")
 {
   $osName = "Linux";
   @results = &callCommand("uname -iprn");
   ($hostName, $osVersion, $cpuArch, $machType) = split(/ +/,@results[0]);
   @results = &callCommand("cat /proc/meminfo | grep '^SwapTotal:'");
   @results = split(/ +/,@results[0]);
   $totalSwap = int(@results[1]/1024) ;
   @results = &callCommand("df -k . | grep -v Filesystem");
   @results = split(/ +/,@results[0]);
   $freeDisk = int(@results[3] / 1024) ;
   @results = &callCommand("cat /proc/meminfo | grep '^MemFree:'");
   @results = split(/ +/,@results[0]);
   $physMem = int(@results[1]/1024);
 }

#  If we're operating under Sun O/S...
 if($osName eq "SunOS")
 {
   $osName = "SunOS";
   @results = &callCommand("uname -iprn");
   ($hostName,$osVersion,$cpuArch,$machType) =
      split(/ +/,@results[0]);
   @results = &callCommand("swap -s");
   @results = split(/ +/,@results[0]);
   $swapAvail = @results[10];
   chop($swapAvail);
   $totalSwap = @results[8];
   chop($totalSwap);
   $totalSwap = $swapAvail + $totalSwap;
   $totalSwap = int($totalSwap/1024) ;
   @results = &callCommand("df -k . | grep -v Filesystem");
   @results = split(/ +/,@results[0]);
   $freeDisk = int(@results[3] / 1024) ;
   @results = 
      &callCommand("prtconf | grep '^Memory size:'");
   @results = split(/ +/,@results[0]);
   $physMem = @results[2];
   $physMem = "Unknown" if(!$physMem);
 }
#  For HP-UX...
 if($osName eq "hpux")
 {
   $osName = "hpux";
   @results = &callCommand("uname -mrn");
   ($hostName,$osVersion,$cpuArchAndMachType) = split(/ +/,@results);
   ($cpuArch,$machType) = split(/\//,$cpuArchAndMachType);
   @results = &callCommand("df -k . | grep 'free allocated'");
   @results = split(/ +/,@results);
   $freeDisk = @results[1];
   @results = &callCommand("getmem");
   @results = split(/ +/,@results);
   $physMem = @results[1];
   @results = &callCommand("top");
   @results = split(/ +/,@results);
   $totalSwap = @results[1];
 }
#  For IBM's AIX (and pains)...
 if($osName eq "aix")
 {
   $osName = "aix";
   @results = &callCommand("df -k . | grep 'Filesystem'");
   @results = split(/ +/,@results);
   $freeDisk = @results[2];
   @results  =  &callCommand("swap  -s");
   my $i=0;
   foreach $line(@results) {
     &report("$line");
     if(i > 0) {
       @swapResults = split(/ +/, $line);
       $totalSwap = $swapResults[0];
      }
     $i = $i + 1;
   }
 }
############################ Comparision Starts Here ####
  foreach $profile (keys(%theProfile))
  { 
    if($profile eq "osName") {
       if($osName =~ /$theProfile{$profile}/) {
         &report("\tERROR: Improper '$profile' (found $osName, need $theProfile{$profile}).")
             unless($theProfile{$profile} eq "ANY");
      } else { &report("\t$profile, Need: $theProfile{$profile}, Found: $osName: OK."); }
    }
    if($profile eq "cpuArch") {
       if($cpuArch =~ /$theProfile{$profile}/) {
         &report("\tWARNING: Improper '$profile' (found $cpuArch, need $theProfile{$profile}).")
            unless($theProfile{$profile} eq "ANY");
       } else { &report("\t$profile, Need: $theProfile{$profile}, Found: $cpuArch: OK."); }
    }
    if($profile eq "machType") {
       if($machType =~ /$theProfile{$profile}/) {
         &report("\tWARNING: Improper '$profile' (found $machType, need $theProfile{$profile}).")
            unless($theProfile{$profile} eq "ANY");
      } else { &report("\t$profile, Need: $theProfile{$profile}, Found: $machType: OK."); }
    }
    if($profile eq "osVersion") {
       if($osVersion =~ /$theProfile{$profile}/) {
         &report("\tWARNING: Improper '$profile' (found $osVersion, need $theProfile{$profile}).")
            unless($theProfile{$profile} eq "ANY");
      } else { &report("\t$profile, Need: $theProfile{$profile}, Found: $osVersion: OK."); }
    }
    if($profile eq "physMem") {
      if($physMem < /$theProfile{$profile}/) {
        &report("\tWARNING: Insufficient '$profile' (found $physMem, need $theProfile{$profile} MB).")
           unless($theProfile{$profile} eq "ANY");
      } else { &report("\t$profile, Need: $theProfile{$profile} MB, Found: $physMem MB: OK."); }
    }
    if($profile eq "totalSwap") {
      if($totalSwap < /$theProfile{$profile}/) {
        &report("\tWARNING: Insufficient '$profile' (found $totalSwap, need $theProfile{$profile} MB).")
           unless($theProfile{$profile} eq "ANY");
      } else { &report("\t$profile, Need: $theProfile{$profile} MB, Found: $totalSwap MB: OK."); }
    }
    if($profile eq "freeDisk") {
      if($freeDisk < /$theProfile{$profile}/) {
        &report("\tWARNING: Insufficient '$profile' (found $freeDisk, need $theProfile{$profile} MB).")
           unless($theProfile{$profile} eq "ANY");
      } else { &report("\t$profile, Need: $theProfile{$profile} MB, Found: $freeDisk MB: OK."); }
    }
  } # End of foreach

&report("Done comparing the system profiles.\n\n");
return(1);
} # End of sub

#
# Write out the directory map to the file specified.
#
sub mkDirMap {
  ($outputFile, $directoryName) = @_;
# Specify the output file and open it for writing.
#
   if(!open(outputFile,">$outputFile"))
   {
      printf("$0: ERROR: couldn't write output file '$outputFile'.\n");
      exit(1);
   }
   shift;
   shift;
   select(outputFile);

#
#  Generate a report for each directory specified on the command line.
#
   &printDirInfo($directoryName);
#
if($outputFile ne "")
{
   close(outputFile);
   select(STDOUT);
}
} # End of sub mkDirMap
                                                                                
#
#  This routine uses 'printFileInfo' to report information about files in a
#  given directory.  The routine is recursive in nature:  as sub-directories
#  are encountered, the routine calls itself to report these directories as
#  well.  See the definition of 'printFileInfo' for a description of the
#  well.  See the definition of 'printFileInfo' for a description of the
#  output format.
#
#  When a symbolic link is encountered it is reported, but the routine will
#  not "follow" the link if it points to a directory.
#
#  A single argument is required:  This is a string containing the name of
#  directory in question.
#
sub printDirInfo
{
   #  Assign the directory-name argument to a local variable.
   my ($dirName) = @_;
   #  Local variable for the path to the current file.
   my $path;
   #  Open the specified directory and retrieve a list of its files.
   unless(opendir(dirHndl,$dirName))
   {
      printf(STDERR "$0: ERROR: couldn't open directory '$dirName'.\n");
      exit(1);
   }
   #  Report each file in the directory.
   foreach $file (readdir(dirHndl))
   {
      #  Don't report the current directory or the parent directory.
      unless(($file eq '.') || ($file eq '..'))
      {
         #  Create a path to the current file.
         $path = sprintf("%s/%s",$dirName,$file);
         #  Generate a report for this file (if it's not a directory).
         &printFileInfo($path) if(!(-d $path));
         #  Is the current file a directory (but not a symbolic link)?  
         # If so, generate a report for this sub-directory.
         &printDirInfo($path) if((-d $path) && !(-l $path));
      }
   }
   #  Close the directory handle.
   closedir(dirHndl);
}
                                                                                
#  This routine writes information about a specified file to the standard
#  output stream.  The information has the form:
#
#  fileName typeAndMode sizeInBytes modifyTime modifyDate
#  Example output:
#     ./bin/makeDirMap 100755 1346 16:55:19 11Jun1999
#
#  The routine requires one argument:  A string containing the path to the
#  file in question.
#
sub printFileInfo
{
   #  Assign the file path argument to a local variable.
   my ($fileName) = @_;
   #  Local variable for the file data structure.
   my @fileHndl;
   #  Get the file information.
   @fileHndl = stat($fileName);
   #  Write the required information in the appropriate format.
   printf("%s %o %d\n",$fileName,@fileHndl[7],@fileHndl[9]);
}

#
#  This routine compares the contents of 2 directory maps.  Each map is
#  stored as a hash and is passed to the routine by reference (!).  The
#  first map is considered the "master" (a description of the desired state
#  of the 2 directories) and the second map is considered the "target" (the
#  directory to be scrutinized).
#
#  Results are printed to the standard output stream.  A report is generated
#  for any of these conditions:
#  - A file is missing in the target directory map.
#
#  - An extra file exists in the target directory map.
#
#  - The routine 'compareMapEntries' finds a discrepancy.  See its definition
#    for more information.
#
#  Two arguments are required:  A hash containing the master directory map
#  and a hash containing the target directory map.
#
#  If any problems are identified between the master and targer directory
#  maps, this routine returns false ("").  Otherwise, a non-false value is
#  returned.
#
sub compareDirMaps
{
#
#  Global variables for this program.
#  Assign the directory map *references* to local variables.
my $dir;
my $noProblems = "true";
my $makeComparison = "true";
@ignoreDirs = ("./.test");
$checkSize = "true";
$checkAccess = "";
$checkModified = "true";
$checkExtra = "true";
$reportFile = "./.test/testReport";

($masterDirMapName,$targetDirMapName) = @_;
#
#  Was a master directory map specified?
#
 report("ERROR: No master directory map specified.") unless($masterDirMapName);
#
#  Was a target directory map specified?
#
 report("ERROR: No target directory map specified.") unless($targetDirMapName);
#
#  Read the master and target directory maps.
#
 %masterMap = &readDirMap($masterDirMapName);
 %targetMap = &readDirMap($targetDirMapName);

   &report("Comparing the directory map listing.");

##   Examine each file in the master directory map.
   foreach $key (keys(%masterMap))
   {
      #  Set a flag to make the comparison for this entry.
      $makeComparison = "true";
      #  Look through the list of directories to ignore.
      foreach $dir (@ignoreDirs)
      {
         #  Clear the comparison flag if this entry begins with this
         #  ignore directory path.
         $makeComparison = "" if($masterMap{$key} =~ /^$dir/);
      }
      #  If it's still OK to make the comparison...
      if($makeComparison)
      {
         #  Is this file present in the target directory map?
         if($targetMap{$key} eq '')
         {
            #  No, complain.
            printf("File %s is missing.\n",$key);
            $noProblems = "";
         }
         else
         {
            #  Are there any discrepancies between the file as it exists in
            #  the master directory and the way it appears in the target
            #  directory?  If so, complain.
            $noProblems = ""
                unless(&compareMapEntries($masterMap{$key},$targetMap{$key}));
         }
      }
   }
   #  Should we check for extra files?
   if($checkExtra)
   {
      #  Are there any extra files in the target directory?
      foreach $key (keys(%targetMap))
      {
         #  Set a flag to make the comparison for this entry.
         $makeComparison = "true";
         #  Look through the list of directories to ignore.
         foreach $dir (@ignoreDirs)
         {
            #  Clear the comparison flag if this entry begins with this
            #  ignore directory path.
            $makeComparison = "" if($targetMap{$key} =~ /^$dir/);
         }
         #  If it's still OK to make the comparison...
         if($makeComparison && ($masterMap{$key} eq ''))
         {
            #  Yes, complain.
            printf("Extra file %s\n",$key);
            $noProblems = "";
         }
      }
   }
   &report("Done comparing the directory map listing.\n");
   return($noProblems);
} # end of sub.

#
#  This routine compares file information between two directory map entries.
#  If the directory map entries are exactly the same, no report is generated.
#  If they differ, reports are written to the standard output stream.  A
#  report is generated for the following situations:
#
#  - A file in the target directory map has the wrong type or access
#    permissions.
#
#  - A file in the target directory map is the wrong size.
#
#  - A file in the target directory map has the wrong modification
#    time-stamp.
#
#  - A file in the target directory map has the wrong modification date.
#
#  Two arguments are required.  The first is a string containing the "master"
#  directory map entry.  The second is a string containing the "target"
#  directory map entry.
#
#  If any problems are identified between the master and targer directory
#  maps, this routine returns false ("").  Otherwise, a non-false value is
#  returned.
#
sub compareMapEntries
{
   #  Get the map entries.
   my ($masterEntry,$targetEntry) = @_;
   #  Local lists for the items in each map entry.
   my @masterItems;
   my @targetItems;
   my $noProblems = "true";
   #  If the map entries differ...
   if($masterEntry ne $targetEntry)
   {
      #  Create a list of items from the master entry.
      @masterItems = split(/ /,$masterEntry);
      #  Create a list of items from the target entry.
      @targetItems = split(/ /,$targetEntry);
      #  Report if the file names differ.
      if(@masterItems[0] ne @targetItems[0])  ## Should never see this.
      {
        $noProblems = "";
         report("File name mismatch: @masterItems[0] not equal ],@targetItems[0].\n");
      }
#  Report if the access permissions or type differ.
 #     if($checkAccess && (@masterItems[1] ne @targetItems[1]))
  #     $noProblems = "";
   #   {
    #     report("Permission/type mismatch on @masterItems[0]: @masterItems[1] not equal @targetItems[1].\n");
     # }
 #  Report if the file sizes differ.
  $fileSizeDiff = @masterItems[2] - @targetItems[2];
      if($checkSize && ($fileSizeDiff > 1))
      {
         $noProblems = "";
         report("Size mismatch on @masterItems[0]: @masterItems[2] not equal @targetItems[2].\n");
      }
      #  Report if the modification dates or time-stamps differ.
      if($checkModified && (@masterItems[3] ne @targetItems[3]))
      {
         $noProblems = "";
         report("Modification time mismatch on @masterItems[0]: scalar localtime(@masterItems[3]) not equal scalar localtime(@targetItems[3]).\n");
      }
   }
   return($noProblems);
}

###
### Check the tool in the path and the version specification. 
###
sub ckToolAndVersion
{
   #  Get the arguments.
   my ($toolName,$needVersion,$toolExpr,$toolLogFile) = (@_);
   #  Local variables.
   my @results = ();
   my $theVersion = "NOTFOUND";
   my $toolPath; 
   my $line;
#
  &report("Required Tool Executable: $toolName");
  &report("Required Tool Version: $needVersion");

 #  Find the first occurrence of 'toolName' in the PATH.
   &report("Finding the first occurence of the '$toolName' in your PATH.");
   $toolPath = &findExec($toolName);
   $installDir = $toolPath;
   #  Report finding the proper tool or tool version.
   &report("The tool '$toolName' is installed in '$installDir'.\n");
   $theVersion = "NOTFOUND";
 #  Was a version specified?
   if($needVersion ne "ANY")
   {
      #  Get the version name from the tool.
      &report("Running the command: '$toolName $toolExpr'\n");
      @results = &callCommand("$toolName $toolExpr");
      if($toolLogFile ne "") 
      {
        @results = &readTextFile($toolLogFile);
      }
      foreach $line(@results)
      {
        &info("$line\n");
        if ($line =~ /$needVersion/)
          { 
           $theVersion = "FOUND";
           last;
          }
      }
   }
   else { 
     $theVersion = "FOUND";
   }
 #  Results.
   if($theVersion eq "FOUND") 
   { 
     &report("INFO: I found the version $needVersion.\n"); 
   }
   return(1) unless($theVersion eq "NOTFOUND");
   return(0);
} #end of sub ckToolAndVersion

# Check the FlexLM licenses of the tools required.
sub chkFlexlmLic
{
 my ($license,$needLicenses) = @_;
 $licenseFiles = @ENV{LM_LICENSE_FILE} || @ENV{CDS_LIC_FILE} unless($licenseFile && (-r $licenseFile));
 if($licenseFiles eq "") { &report("\nLicense File Not Found\n"); }
 &report("No license names specified.") if($license eq "");
 $canCheckOut = "";
 $licenseExpires = "";
 $numberLicenses = "";
 unless(runningNT())
  {
     if($licenseFile ne "") 
     {
       @response = &callCommand("lmdiag -n $license -c $licenseFile");
       &report("Call to 'lmdiag -n $license' failed.") unless($#response ge 0);
       foreach $line (@response)
       {
          $canCheckOut = "true" if($line =~ /This license can be checked out/);
          if($line =~ /expires: /)
          {
             $licenseExpires = $line;
          }
       }
       &report("WARNING: Cannot check-out '$license'\n$licenseExpires.\n") unless($canCheckOut);
     } # End license diagnostics
    @response = &callCommand("lmstat -i '$license'");
    &report("Call to lmstat -i '$license' failed.") unless($#response ge 0);
    $license24 = substr($license, 0, 23);
    foreach $line (@response)
    {
      if($line =~ /$license24/)
      {
         $licenseLines = $line;
      }
    }
    @tokens = split(/\s+/, $licenseLines);
    $licenseVersion = @tokens[1];
    $numberLicenses = @tokens[2];
    $licenseExpires = @tokens[3];
    &report("WARNING: Too few licenses for '$license' (have $numberLicenses, need  $needLicenses}).") unless($numberLicenses >= $needLicenses);
    &report("INFO: License '$license' OK for $numberLicenses users until $licenseExpires.\n") unless($numberLicenses < 1);
  } # if not for Windows
#
  if(runningNT())
  {
    if($licenseFile ne "") {
       @response = &callCommand("lmutil lmdiag -n $license -c $licenseFile");
       &report("Call to lmutil lmdiag -n $license failed.") unless($#response ge 0);
       foreach $line(@response) {
          $canCheckOut = "true" if($line =~ /This license can be checked out/);
          if($line =~ /expires: /) {
             $licenseExpires = $line;
          }
       }
       &report("WARNING: Cannot check-out '$license'.\n$licenseExpires.\n") unless($canCheckOut);
    } # End license diagnostics
    @response = &callCommand("lmutil lmstat -i $license -c $licenseFile");
    &report("WARNING: Call to lmutil 'lmstat -i' '$license' failed.") unless($#response ge 0);
    $license24 = substr($license, 0, 23);
    foreach $line (@response) {
      if($line =~ /$license24/) {
          $licenseLines = $line;
      }
    }
    printf("$licenseLines\n");
    @tokens = split(/\s+/, $licenseLines);
    $licenseVersion = @tokens[1];
    $numberLicenses = @tokens[2];
    $licenseExpires = @tokens[3];
    &report("WARNING: Too few licenses for '$license' (have $numberLicenses, need $needLicenses).") unless($numberLicenses >= $needLicenses);
    &report("INFO: License '$license' OK for $numberLicenses users until $licenseExpires.\n") unless($numberLicenses < 1);
  } # for Windows
    return(1) unless(($canCheckOut eq "true") && ($numberLicenses >= $needLicenses) && ($numberLicenses >= 1));
    return(0);
} #Done checking flexlm license.
