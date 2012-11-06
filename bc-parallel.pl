#!/usr/bin/perl -w

# trivial modification to parallel that won't start new jobs when
# "netstat -anp" shows more than 50 connections

=head1 NAME

parallel - build and execute shell command lines from standard input in parallel

=head1 SYNOPSIS

B<parallel> [options] [I<command> [arguments]] [< list_of_arguments]

=head1 DESCRIPTION

GNU B<parallel> is a shell tool for executing jobs in parallel using
one or more machines. A job is typically a single command or a small
script that has to be run for each of the lines in the input. The
typical input is a list of files, a list of hosts, a list of users, a
list of URLs, or a list of tables.

If you use B<xargs> today you will find GNU B<parallel> very easy to
use as GNU B<parallel> is written to have the same options as
B<xargs>. If you write loops in shell, you will find GNU B<parallel>
may be able to replace most of the loops and make them run faster by
running several jobs in parallel. If you use B<ppss> or B<pexec> you will find
GNU B<parallel> will often make the command easier to read.

GNU B<parallel> makes sure output from the commands is the same output as
you would get had you run the commands sequentially. This makes it
possible to use output from GNU B<parallel> as input for other programs.

For each line of input GNU B<parallel> will execute I<command> with
the line as arguments. If no I<command> is given, the line of input is
executed. Several lines will be run in parallel. GNU B<parallel> can
often be used as a substitute for B<xargs> or B<cat | sh>.

=over 9

=item I<command>

Command to execute.  If I<command> or the following arguments contain
{} every instance will be substituted with the input line. Setting a
command also invokes B<-f>.

If I<command> is given, GNU B<parallel> will behave similar to B<xargs>. If
I<command> is not given GNU B<parallel> will behave similar to B<cat | sh>.


=item B<{}>

Input line. This is the default replacement string and will normally
be used for putting the argument in the command line. It can be
changed with B<-I>.


=item B<{.}>

Input line without extension. This is a specialized replacement string
with the extension removed. If the input line contains B<.> after the
last B</> the last B<.> till the end of the string will be removed and
B<{.}> will be replaced with the remaining. E.g. I<foo.jpg> becomes
I<foo>, I<subdir/foo.jpg> becomes I<subdir/foo>, I<sub.dir/foo.jpg>
becomes I<sub.dir/foo>, I<sub.dir/bar> remains I<sub.dir/bar>. If the
input line does not contain B<.> it will remain unchanged.

B<{.}> can be used the same places as B<{}>. The replacement string
B<{.}> can be changed with B<-U>.


=item B<--null>

=item B<-0>

Use NUL as delimiter.  Normally input lines will end in \n
(newline). If they end in \0 (NUL), then use this option. It is useful
for processing arguments that may contain \n (newline).


=item B<--arg-file>=I<input-file>

=item B<-a> I<input-file>

Read items from the file I<input-file> instead of standard input.  If
you use this option, stdin is given to the first process run.
Otherwise, stdin is redirected from /dev/null.


=item B<--cleanup>

Remove transferred files. B<--cleanup> will remove the transferred files
on the remote server after processing is done.

  find log -name '*gz' | parallel \
    --sshlogin server.example.com --transfer --return {.}.bz2 \
    --cleanup "zcat {} | bzip -9 >{.}.bz2"

With B<--transfer> the file transferred to the remote server will be
removed on the remote server.  Directories created will not be removed
- even if they are empty.

With B<--return> the file transferred from the remote server will be
removed on the remote server.  Directories created will not be removed
- even if they are empty.

B<--cleanup> is ignored when not used with B<--transfer> or B<--return>.


=item B<--command>

=item B<-c>

Line is a command.  The input line contains more than one argument or
the input line needs to be evaluated by the shell. This is the default
if I<command> is not set. Can be reversed with B<-f>.


=item B<--delimiter> I<delim>

=item B<-d> I<delim>

Input items are terminated by the specified character.  Quotes and
backslash are not special; every character in the input is taken
literally.  Disables the end-of-file string, which is treated like any
other argument.  This can be used when the input consists of simply
newline-separated items, although it is almost always better to design
your program to use --null where this is possible.  The specified
delimiter may be a single character, a C-style character escape such
as \n, or an octal or hexadecimal escape code.  Octal and
hexadecimal escape codes are understood as for the printf command.
Multibyte characters are not supported.

=item B<-E> I<eof-str>

Set the end of file string to eof-str.  If the end of file string
occurs as a line of input, the rest of the input is ignored.  If
neither B<-E> nor B<-e> is used, no end of file string is used.


=item B<--eof>[=I<eof-str>]

=item B<-e>[I<eof-str>]

This option is a synonym for the B<-E> option.  Use B<-E> instead,
because it is POSIX compliant for B<xargs> while this option is not.
If I<eof-str> is omitted, there is no end of file string.  If neither
B<-E> nor B<-e> is used, no end of file string is used.




=item B<--file>

=item B<-f>

Line is a filename.  The input line contains a filename that will be
quoted so it is not evaluated by the shell. This is the default if
I<command> is set. Can be reversed with B<-c>.


=item B<--group>

=item B<-g>

Group output.  Output from each jobs is grouped together and is only
printed when the command is finished. STDERR first followed by STDOUT.
B<-g> is the default. Can be reversed with B<-u>.

=item B<--help>

=item B<-h>

Print a summary of the options to GNU B<parallel> and exit.


=item B<-I> I<replace-str>

Use the replacement string I<replace-str> instead of {}.


=item B<--replace>[=I<replace-str>]

=item B<-i>[I<replace-str>]

This option is a synonym for B<-I>I<replace-str> if I<replace-str> is
specified, and for B<-I>{} otherwise.  This option is deprecated;
use B<-I> instead.


=item B<--jobs> I<N>

=item B<-j> I<N>

=item B<--max-procs> I<N>

=item B<-P> I<N>

Run up to N jobs in parallel.  0 means as many as possible. Default is 9.


=item B<--jobs> I<+N>

=item B<-j> I<+N>

=item B<--max-procs> I<+N>

=item B<-P> I<+N>

Add N to the number of CPU cores.  Run this many jobs in parallel. For
compute intensive jobs B<-j> +0 is useful as it will run
number-of-cpu-cores jobs in parallel. See also
B<--use-cpus-instead-of-cores>.


=item B<--jobs> I<-N>

=item B<-j> I<-N>

=item B<--max-procs> I<-N>

=item B<-P> I<-N>

Subtract N from the number of CPU cores.  Run this many jobs in parallel.
If the evaluated number is less than 1 then 1 will be used.  See also
B<--use-cpus-instead-of-cores>.


=item B<--jobs> I<N>%

=item B<-j> I<N>%

=item B<--max-procs> I<N>%

=item B<-P> I<N>%

Multiply N% with the number of CPU cores.  Run this many jobs in parallel.
If the evaluated number is less than 1 then 1 will be used.  See also
B<--use-cpus-instead-of-cores>.


=item B<--keeporder>

=item B<-k>

Keep sequence of output same as the order of input. If jobs 1 2 3 4
end in the sequence 3 1 4 2 the output will still be 1 2 3 4.


=item B<--controlmaster> (experimental)

=item B<-M> (experimental)

Use ssh's ControlMaster to make ssh connections faster. Useful if jobs
run remote and are very fast to run.


=item B<--max-args>=I<max-args>

=item B<-n> I<max-args>

Use at most I<max-args> arguments per command line.  Fewer than
I<max-args> arguments will be used if the size (see the B<-s> option)
is exceeded, unless the B<-x> option is given, in which case
GNU B<parallel> will exit.

Only used with B<-m> and B<-X>.


=item B<--max-line-length-allowed>

Print the maximal number characters allowed on the command line and
exit (used by GNU B<parallel> itself to determine the line length
on remote machines).


=item B<--number-of-cpus>

Print the number of physical CPUs and exit (used by GNU B<parallel>
itself to determine the number of physical CPUs on remote machines).


=item B<--number-of-cores>

Print the number of cores and exit (used by GNU B<parallel> itself to determine the
number of cores on remote machines).


=item B<--interactive>

=item B<-p>

Prompt the user about whether to run each command line and read a line
from the terminal.  Only run the command line if the response starts
with 'y' or 'Y'.  Implies B<-t>.


=item B<--quote>

=item B<-q>

Quote I<command>.  This will quote the command line so special
characters are not interpreted by the shell. See the section
QUOTING. Most people will never need this.  Quoting is disabled by
default.


=item B<--no-run-if-empty>

=item B<-r>

If the standard input only contains whitespace, do not run the command.

=item B<--return> I<filename>

Transfer files from remote servers. B<--return> is used with
B<--sshlogin> when the arguments are files on the remote servers. When
processing is done the file I<filename> will be transferred
from the remote server using B<rsync> and will be put relative to
the default login dir. E.g.

  echo foo/bar.txt | parallel \
    --sshlogin server.example.com --return {.}.out touch {.}.out

This will transfer the file I<$HOME/foo/bar.out> from the server
I<server.example.com> to the file I<foo/bar.out> after running
B<touch foo/bar.out> on I<server.example.com>.

  echo /tmp/foo/bar.txt | parallel \
    --sshlogin server.example.com --return {.}.out touch {.}.out

This will transfer the file I</tmp/foo/bar.out> from the server
I<server.example.com> to the file I</tmp/foo/bar.out> after running
B<touch /tmp/foo/bar.out> on I<server.example.com>.

Multiple files can be transferred by repeating the options multiple
times:

  echo /tmp/foo/bar.txt | \
    parallel --sshlogin server.example.com \
    --return {.}.out --return {.}.out2 touch {.}.out {.}.out2

B<--return> is often used with B<--transfer> and B<--cleanup>.

B<--return> is ignored when used with B<--sshlogin :> or when not used with B<--sshlogin>.


=item B<--max-chars>=I<max-chars>

=item B<-s> I<max-chars>

Use at most I<max-chars> characters per command line, including the
command and initial-arguments and the terminating nulls at the ends of
the argument strings.  The largest allowed value is system-dependent,
and is calculated as the argument length limit for exec, less the size
of your environment.  The default value is the maximum.


=item B<--show-limits>

Display the limits on the command-line length which are imposed by the
operating system and the B<-s> option.  Pipe the input from /dev/null
(and perhaps specify --no-run-if-empty) if you don't want GNU B<parallel>
to do anything.


=item B<-S> I<[ncpu/]sshlogin[,[ncpu/]sshlogin[,...]]> (beta testing)

=item B<--sshlogin> I<[ncpu/]sshlogin[,[ncpu/]sshlogin[,...]]> (beta testing)

Distribute jobs to remote servers. The jobs will be run on a list of
remote servers.  GNU B<parallel> will determine the number of CPU
cores on the remote servers and run the number of jobs as specified by
B<-j>.  If the number I<ncpu> is given GNU B<parallel> will use this
number for number of CPUs on the host. Normally I<ncpu> will not be
needed.

An I<sshlogin> is of the form:

  [sshcommand [options]][username@]hostname

The sshlogin must not require a password.

The sshlogin ':' is special, it means 'no ssh' and will therefore run
on the local machine.

To specify more sshlogins separate the sshlogins by comma or repeat
the options multiple times.

For examples: see B<--sshloginfile>.

The remote host must have GNU B<parallel> installed.

B<--sshlogin> is known to cause problems with B<-m> and B<-X>.


=item B<--sshloginfile> I<filename> (beta testing)

File with sshlogins. The file consists of sshlogins on separate
lines. Empty lines and lines starting with '#' are ignored. Example:

  server.example.com
  username@server2.example.com
  8/my-8-core-server.example.com
  2/myusername@my-dualcore.example.net
  # This server has SSH running on port 2222
  ssh -p 2222 server.example.net
  4/ssh -p 2222 quadserver.example.net
  # Use a different ssh program
  myssh -p 2222 -l compute hexacpu.example.net
  # Use a different ssh program with default number of cores
  //usr/local/bin/myssh -p 2222 -l compute hexacpu.example.net
  # Use a different ssh program with 6 cores
  6//usr/local/bin/myssh -p 2222 -l compute hexacpu.example.net
  # Assume 16 cores on the local machine
  16/:


=item B<--silent>

Silent.  The job to be run will not be printed. This is the default.
Can be reversed with B<-v>.


=item B<--verbose>

=item B<-t>

Print the command line on the standard error output before executing
it.

See also B<-v>.


=item B<--transfer>

Transfer files to remote servers. B<--transfer> is used with
B<--sshlogin> when the arguments are files and should be transferred to
the remote servers. The files will be transferred using B<rsync> and
will be put relative to the default login dir. E.g.

  echo foo/bar.txt | parallel \
    --sshlogin server.example.com --transfer wc

This will transfer the file I<foo/bar.txt> to the server
I<server.example.com> to the file I<$HOME/foo/bar.txt> before running
B<wc foo/bar.txt> on I<server.example.com>.

  echo /tmp/foo/bar.txt | parallel \
    --sshlogin server.example.com --transfer wc

This will transfer the file I<foo/bar.txt> to the server
I<server.example.com> to the file I</tmp/foo/bar.txt> before running
B<wc /tmp/foo/bar.txt> on I<server.example.com>.

B<--transfer> is often used with B<--return> and B<--cleanup>.

B<--transfer> is ignored when used with B<--sshlogin :> or when not used with B<--sshlogin>.


=item B<--trc> I<filename>

Transfer, Return, Cleanup. Short hand for:

B<--transfer> B<--return> I<filename> B<--cleanup>


=item B<--ungroup>

=item B<-u>

Ungroup output.  Output is printed as soon as possible. This may cause
output from different commands to be mixed. GNU B<parallel> runs
faster with B<-u>. Can be reversed with B<-g>.


=item B<--extensionreplace> I<replace-str>

=item B<-U> I<replace-str>

Use the replacement string I<replace-str> instead of {.} for input line without extension.


=item B<--use-cpus-instead-of-cores>

Count the number of physical CPUs instead of cores. When computing how
many jobs to run in parallel relative to the number of cores you can
ask GNU B<parallel> to instead look at the number of physical
CPUs. This will make sense for computers that have hyperthreading as
two jobs running on one CPU with hyperthreading will run slower than
two jobs running on two physical CPUs. Some multi-core CPUs can run
faster if only one thread is running per physical CPU. Most users will
not need this option.


=item B<-v>

Verbose.  Print the job to be run on STDOUT. Can be reversed with
B<--silent>. See also B<-t>.


=item B<--version>

=item B<-V>

Print the version GNU B<parallel> and exit.


=item B<--xargs>

=item B<-m>

Multiple. Insert as many arguments as the command line length
permits. If B<{}> is not used the arguments will be appended to the
line.  If B<{}> is used multiple times each B<{}> will be replaced
with all the arguments.

Support for B<-m> with B<--sshlogin> is limited and may fail.


=item B<-X>

xargs with context replace. This works like B<-m> except if B<{}> is part
of a word (like I<pic{}.jpg>) then the whole word will be
repeated. Normally B<-X> will do the right thing, whereas B<-m> can
give surprising results if B<{}> is used as part of a word.

Support for B<-X> with B<--sshlogin> is limited and may fail.

=back

=head1 EXAMPLE: Working as xargs -n1. Argument appending

GNU B<parallel> can work similar to B<xargs -n1>.

To compress all html files using B<gzip> run:

B<find . -name '*.html' | parallel gzip>


=head1 EXAMPLE: Inserting multiple arguments

When moving a lot of files like this: B<mv * destdir> you will
sometimes get the error:

B<bash: /bin/mv: Argument list too long>

because there are too many files. You can instead do:

B<ls | parallel mv {} destdir>

This will run B<mv> for each file. It can be done faster if B<mv> gets
as many arguments that will fit on the line:

B<ls | parallel -m mv {} destdir>


=head1 EXAMPLE: Context replace

To remove the files I<pict0000.jpg> .. I<pict9999.jpg> you could do:

B<seq -f %04g 0 9999 | parallel rm pict{}.jpg>

You could also do:

B<seq -f %04g 0 9999 | perl -pe 's/(.*)/pict$1.jpg/' | parallel -m rm>

The first will run B<rm> 10000 times, while the last will only run
B<rm> as many times needed to keep the command line length short
enough to avoid B<Argument list too long> (it typically runs 1-2 times).

You could also run:

B<seq -f %04g 0 9999 | parallel -X rm pict{}.jpg>

This will also only run B<rm> as many times needed to keep the command
line length short enough.


=head1 EXAMPLE: Compute intensive jobs and substitution

If ImageMagick is installed this will generate a thumbnail of a jpg
file:

B<convert -geometry 120 foo.jpg thumb_foo.jpg>

If the system has more than 1 CPU core it can be run with
number-of-cpu-cores jobs in parallel (B<-j> +0). This will do that for
all jpg files in a directory:

B<ls *.jpg | parallel -j +0 convert -geometry 120 {} thumb_{}>

To do it recursively use B<find>:

B<find . -name '*.jpg' | parallel -j +0 convert -geometry 120 {} {}_thumb.jpg>

Notice how the argument has to start with B<{}> as B<{}> will include path
(e.g. running B<convert -geometry 120 ./foo/bar.jpg
thumb_./foo/bar.jpg> would clearly be wrong). The command will
generate files like ./foo/bar.jpg_thumb.jpg.

Use B<{.}> to avoid the extra .jpg in the file name. This command will
make files like ./foo/bar_thumb.jpg:

B<find . -name '*.jpg' | parallel -j +0 convert -geometry 120 {} {.}_thumb.jpg>


=head1 EXAMPLE: Substitution and redirection

This will generate an uncompressed version of .gz-files next to the .gz-file:

B<ls *.gz | parallel zcat {} ">>B<"{.}>

Quoting of > is necessary to postpone the redirection. Another
solution is to quote the whole command:

B<ls *.gz | parallel "zcat {} >>B<{.}">

Other special shell charaters (such as * ; $ > < | >> <<) also needs
to be put in quotes, as they may otherwise be interpreted by the shell
and not given to GNU B<parallel>.

=head1 EXAMPLE: Composed commands

A job can consist of several commands. This will print the number of
files in each directory:

B<ls | parallel 'echo -n {}" "; ls {}|wc -l'>

To put the output in a file called <name>.dir:

B<ls | parallel '(echo -n {}" "; ls {}|wc -l) >> B<{}.dir'>


=head1 EXAMPLE: Removing file extension when processing files

When processing files removing the file extension using B<{.}> is
often useful.

Create a directory for each zip-file and unzip it in that dir:

B<ls *zip | parallel 'mkdir {.}; cd {.}; unzip ../{}'>

Recompress all .gz files in current directory using B<bzip2> running 1
job per CPU core in parallel:

B<ls *.gz | parallel -j+0 "zcat {} | bzip2 >>B<{.}.bz2 && rm {}">


=head1 EXAMPLE: Rewriting a for-loop and a while-loop

for-loops like this:

B<  (for x in `cat list` ; do
    do_something $x
  done) | process_output>

and while-loops like this:

B<  cat list | (while read x ; do
    do_something $x
  done) | process_output>

can be written like this:

B<cat list | parallel do_something | process_output>

If the processing requires more steps the for-loop like this:

B< (for x in `cat list` ; do
   no_extension=${x%.png};
   do_something $x scale $no_extension.jpg
   do_step2 <$x $no_extension
 done) | process_output>

and while-loops like this:

B<  cat list | (while read x ; do
   no_extension=${x%.png};
   do_something $x scale $no_extension.jpg
   do_step2 <$x $no_extension
 done) | process_output>

can be written like this:

B<cat list | parallel "do_something {} scale {.}.jpg ; do_step2 <{} {.}" | process_output>


=head1 EXAMPLE: Group output lines

When runnning jobs that output data, you often do not want the output
of multiple jobs to run together. GNU B<parallel> defaults to grouping the
output of each job, so the output is printed when the job finishes. If
you want the output to be printed while the job is running you can use
B<-u>.

Compare the output of:

B<(echo foss.org.my; echo debian.org; echo freenetproject.org) | parallel traceroute>

to the output of:

B<(echo foss.org.my; echo debian.org; echo freenetproject.org) | parallel -u traceroute>


=head1 EXAMPLE: Keep order of output same as order of input

Normally the output of a job will be printed as soon as it
completes. Sometimes you want the order of the output to remain the
same as the order of the input. This is often important, if the output
is used as input for another system. B<-k> will make sure the order of
output will be in the same order as input even if later jobs end
before earlier jobs.

Append a string to every line in a text file:

B<cat textfile | parallel -k echo {} append_string>

If you remove B<-k> some of the lines may come out in the wrong order.

Another example is B<traceroute>:

B<(echo foss.org.my; echo debian.org; echo freenetproject.org) | parallel traceroute>

will give traceroute of foss.org.my, debian.org and
freenetproject.org, but it will be sorted according to which job
completed first.

To keep the order the same as input run:

B<(echo foss.org.my; echo debian.org; echo freenetproject.org) | parallel -k traceroute>

This will make sure the traceroute to foss.org.my will be printed
first.

=head1 EXAMPLE: Using remote computers

To run commands on a remote computer SSH needs to be set up and you
must be able to login without entering a password (B<ssh-agent> may be
handy).

To run B<echo> on B<server.example.com>:

  seq 1 10 | parallel --sshlogin server.example.com echo

To run commands on more than one remote computer run:

  seq 1 10 | parallel --sshlogin server.example.com,server2.example.net echo

Or:

  seq 1 10 | parallel --sshlogin server.example.com \
    --sshlogin server2.example.net echo

If the login username is I<foo> on I<server2.example.net> use:

  seq 1 10 | parallel --sshlogin server.example.com \
    --sshlogin foo@server2.example.net echo

To distribute the commands to a list of machines, make a file
I<mymachines> with all the machines:

  server.example.com
  foo@server2.example.com
  server3.example.com

Then run:

  seq 1 10 | parallel --sshloginfile mymachines echo

To include the local machine add the special sshlogin ':' to the list:

  server.example.com
  foo@server2.example.com
  server3.example.com
  :

If the number of CPU cores on the remote servers is not identified
correctly the number of CPU cores can be added in front. Here the
server has 8 CPU cores.

  seq 1 10 | parallel --sshlogin 8/server.example.com echo


=head1 EXAMPLE: Transferring of files

To recompress gzipped files with B<bzip2> using a remote server run:

  find logs/ -name '*.gz' | \
    parallel --sshlogin server.example.com \
    --transfer "zcat {} | bzip2 -9 >{.}.bz2"

This will list the .gz-files in the I<logs> directory and all
directories below. Then it will transfer the files to
I<server.example.com> to the corresponding directory in
I<$HOME/logs>. On I<server.example.com> the file will be recompressed
using B<zcat> and B<bzip2> resulting in the corresponding file with
I<.gz> replaced with I<.bz2>.

If you want the file to be transferred back to the local machine add
I<--return {.}.bz2>:

  find logs/ -name '*.gz' | \
    parallel --sshlogin server.example.com \
    --transfer --return {.}.bz2 "zcat {} | bzip2 -9 >{.}.bz2"

After the recompressing is done the I<.bz2>-file is transferred back to
the local machine and put next to the original I<.gz>-file.

If you want to delete the transferred files on the remote machine add
I<--cleanup>. This will remove both the file transferred to the remote
machine and the files transferred from the remote machine:

  find logs/ -name '*.gz' | \
    parallel --sshlogin server.example.com \
    --transfer --return {.}.bz2 --cleanup "zcat {} | bzip2 -9 >{.}.bz2"

If you want run on several servers add the servers to I<--sshlogin>
either using ',' or multiple I<--sshlogin>:

  find logs/ -name '*.gz' | \
    parallel --sshlogin server.example.com,server2.example.com \
    --sshlogin server3.example.com \
    --transfer --return {.}.bz2 --cleanup "zcat {} | bzip2 -9 >{.}.bz2"

You can add the local machine using I<--sshlogin :>. This will disable the
removing and transferring for the local machine only:

  find logs/ -name '*.gz' | \
    parallel --sshlogin server.example.com,server2.example.com \
    --sshlogin server3.example.com \
    --sshlogin : \
    --transfer --return {.}.bz2 --cleanup "zcat {} | bzip2 -9 >{.}.bz2"

Often I<--transfer>, I<--return> and I<--cleanup> are used together. They can be
shortened to I<--trc>:

  find logs/ -name '*.gz' | \
    parallel --sshlogin server.example.com,server2.example.com \
    --sshlogin server3.example.com \
    --sshlogin : \
    --trc {.}.bz2 "zcat {} | bzip2 -9 >{.}.bz2"

With the file I<mymachines> containing the compute machines it becomes:

  find logs/ -name '*.gz' | parallel --sshloginfile mymachines \
    --trc {.}.bz2 "zcat {} | bzip2 -9 >{.}.bz2"


=head1 EXAMPLE: Working as cat | sh. Ressource inexpensive jobs and evaluation

GNU B<parallel> can work similar to B<cat | sh>.

A ressource inexpensive job is a job that takes very little CPU, disk
I/O and network I/O. Ping is an example of a ressource inexpensive
job. wget is too - if the webpages are small.

The content of the file jobs_to_run:

  ping -c 1 10.0.0.1
  wget http://status-server/status.cgi?ip=10.0.0.1
  ping -c 1 10.0.0.2
  wget http://status-server/status.cgi?ip=10.0.0.2
  ...
  ping -c 1 10.0.0.255
  wget http://status-server/status.cgi?ip=10.0.0.255

To run 100 processes simultaneously do:

B<parallel -j 100 < jobs_to_run>

As there is not a I<command> the option B<-c> is default because the
jobs needs to be evaluated by the shell.


=head1 QUOTING

For more advanced use quoting may be an issue. The following will
print the filename for each line that has exactly 2 columns:

B<perl -ne '/^\S+\s+\S+$/ and print $ARGV,"\n"' file>

This can be done by GNU B<parallel> using:

B<ls | parallel "perl -ne '/^\\S+\\s+\\S+$/ and print \$ARGV,\"\\n\"'">

Notice how \'s, "'s, and $'s needs to be quoted. GNU B<parallel> can do
the quoting by using option B<-q>:

B<ls | parallel -q  perl -ne '/^\S+\s+\S+$/ and print $ARGV,"\n"'>

However, this means you cannot make the shell interpret special
characters. For example this B<will not work>:

B<ls *.gz | parallel -q "zcat {} >>B<{.}">

B<ls *.gz | parallel -q "zcat {} | bzip2 >>B<{.}.bz2">

because > and | need to be interpreted by the shell.

If you get errors like:

B<sh: -c: line 0: syntax error near unexpected token>

then you might try using B<-q>.

If you are using B<bash> process substitution like B<<(cat foo)> then
you may try B<-q> and prepending I<command> with B<bash -c>:

B<ls | parallel -q bash -c 'wc -c <(echo {})'>

Or for substituting output:

B<ls | parallel -q bash -c 'tar c {} | tee >>B<(gzip >>B<{}.tar.gz) | bzip2 >>B<{}.tar.bz2'>

B<Conclusion>: To avoid dealing with the quoting problems it may be
easier just to write a small script and have GNU B<parallel> call that
script.


=head1 LIST RUNNING JOBS

If you want a list of the jobs currently running you can run:

B<killall -USR1 parallel>

GNU B<parallel> will then print the currently running jobs on STDERR.


=head1 COMPLETE RUNNING JOBS BUT DO NOT START NEW JOBS

If you regret starting a lot of jobs you can simply break GNU B<parallel>,
but if you want to make sure you do not have halfcompleted jobs you
should send the signal B<SIGTERM> to GNU B<parallel>:

B<killall -TERM parallel>

This will tell GNU B<parallel> to not start any new jobs, but wait until
the currently running jobs are finished before exiting.


=head1 DIFFERENCES BETWEEN find -exec AND parallel

B<find -exec> offer some of the same possibilites as GNU B<parallel>.

B<find -exec> only works on files. So processing other input (such as
hosts or URLs) will require creating these inputs as files. B<find
-exec> has no support for running commands in parallel.


=head1 DIFFERENCES BETWEEN xargs AND parallel

B<xargs> offer some of the same possibilites as GNU B<parallel>.

B<xargs> deals badly with special characters (such as space, ' and
"). To see the problem try this:

  touch important_file
  touch 'not important_file'
  ls not* | xargs rm
  mkdir -p '12" records'
  ls | xargs rmdir

You can specify B<-0> or B<-d "\n">, but many input generators are not
optimized for using B<NUL> as separator but are optimized for
B<newline> as separator. E.g B<head>, B<tail>, B<awk>, B<ls>, B<echo>,
B<sed>, B<tar -v>, B<perl> (B<-0> and \0 instead of \n), B<locate>
(requires using B<-0>), B<find> (requires using B<-print0>), B<grep>
(requires user to use B<-z> or B<-Z>).

So GNU B<parallel>'s newline separation can be emulated with:

B<cat | xargs -d "\n" -n1 I<command>>

B<xargs> can run a given number of jobs in parallel, but has no
support for running number-of-cpu-cores jobs in parallel.

B<xargs> has no support for grouping the output, therefore output may
run together, e.g. the first half of a line is from one process and
the last half of the line is from another process.

B<xargs> has no support for keeping the order of the output, therefore
if running jobs in parallel using B<xargs> the output of the second
job cannot be postponed till the first job is done.

B<xargs> has no support for running jobs on remote machines.

B<xargs> has no support for context replace, so you will have to create the
arguments.

If you use a replace string in B<xargs> (B<-I>) you can not force
B<xargs> to use more than one argument.

Quoting in B<xargs> works like B<-q> in GNU B<parallel>. This means
composed commands and redirection requires using B<bash -c>.

B<ls | parallel "wc {} >> B<{}.wc">

becomes

B<ls | xargs -d "\n" -P9 -I {} bash -c "wc {} >>B< {}.wc">

and

B<ls | parallel "echo {}; ls {}|wc">

becomes

B<ls | xargs -d "\n" -P9 -I {} bash -c "echo {}; ls {}|wc">


=head1 DIFFERENCES BETWEEN ppss AND parallel

B<ppss> is also a tool for running jobs in parallel.

The output of B<ppss> is status information and thus not useful for
using as input for another command. The output from the jobs are put
into files.

The argument replace string ($ITEM) cannot be changed and must be
quoted - thus arguments containing special characters (space '"&!*)
may cause problems. More than one argument is not supported. File
names containing newlines are not processed correctly. When reading
input from a file null cannot be used terminator. B<ppss> needs to
read the whole input file before starting any jobs.

Output and status information is stored in ppss_dir and thus requires
cleanup when completed. If the dir is not removed before running
B<ppss> again it may cause nothing to happen as B<ppss> thinks the
task is already done. GNU B<parallel> will normally not need cleaning
up if running locally and will only need cleaning up if stopped
abnormally and running remote (B<--cleanup> may not complete if
stopped abnormally).

=head2 EXAMPLES FROM ppss MANUAL

Here are the examples from B<ppss>'s manual page with the equivalent
using parallel:

./ppss.sh standalone -d /path/to/files -c 'gzip '

find /path/to/files -type f | parallel -j+0 gzip

./ppss.sh standalone -d /path/to/files -c 'cp "$ITEM" /destination/dir '

find /path/to/files -type f | parallel -j+0 cp {} /destination/dir

./ppss.sh standalone -f list-of-urls.txt -c 'wget -q '

parallel -a list-of-urls.txt wget -q

./ppss.sh standalone -f list-of-urls.txt -c 'wget -q "$ITEM"'

parallel -a list-of-urls.txt wget -q {}

./ppss config -C config.cfg -c 'encode.sh ' -d /source/dir -m 192.168.1.100 -u ppss -k ppss-key.key -S ./encode.sh -n nodes.txt -o /some/output/dir --upload --download

./ppss deploy -C config.cfg

./ppss start -C config

# parallel does not use configs. If you want a different username put it in nodes.txt: user@hostname

find source/dir -type f | parallel --sshloginfile nodes.txt --trc {.}.mp3 lame -a {} -o {.}.mp3 --preset standard --quiet

./ppss stop -C config.cfg

killall -TERM parallel

./ppss pause -C config.cfg

Press: CTRL-Z or killall -SIGTSTP parallel

./ppss continue -C config.cfg

Enter: fg or killall -SIGCONT parallel

./ppss.sh status -C config.cfg

killall -SIGUSR1 parallel # Not quite equivalent: Only shows the currently running jobs


=head1 DIFFERENCES BETWEEN pexec AND parallel

B<pexec> is also a tool for running jobs in parallel.

Here are the examples from B<pexec>'s info page with the equivalent
using parallel:

pexec -o sqrt-%s.dat -p "$(seq 10)" -e NUM -n 4 -c -- \
  'echo "scale=10000;sqrt($NUM)" | bc'

seq 10 | parallel -j4 'echo "scale=10000;sqrt({})" | bc > sqrt-{}.dat'

pexec -p "$(ls myfiles*.ext)" -i %s -o %s.sort -- sort

ls myfiles*.ext | parallel sort {} ">{}.sort"

pexec -f image.list -n auto -e B -u star.log -c -- \
  'fistar $B.fits -f 100 -F id,x,y,flux -o $B.star'

parallel -a image.list -j+0 \
  'fistar {}.fits -f 100 -F id,x,y,flux -o {}.star' 2>star.log

pexec -r *.png -e IMG -c -o - -- \
  'convert $IMG ${IMG%.png}.jpeg ; "echo $IMG: done"'

ls *.png | parallel 'convert {} {.}.jpeg; echo {}: done'

pexec -r *.png -i %s -o %s.jpg -c 'pngtopnm | pnmtojpeg'

ls *.png | parallel 'pngtopnm < {} | pnmtojpeg > {}.jpg'

for p in *.png ; do echo ${p%.png} ; done | \
  pexec -f - -i %s.png -o %s.jpg -c 'pngtopnm | pnmtojpeg'

ls *.png | parallel 'pngtopnm < {} | pnmtojpeg > {.}.jpg'

LIST=$(for p in *.png ; do echo ${p%.png} ; done)
  pexec -r $LIST -i %s.png -o %s.jpg -c 'pngtopnm | pnmtojpeg'

ls *.png | parallel 'pngtopnm < {} | pnmtojpeg > {.}.jpg'

pexec -n 8 -r *.jpg -y unix -e IMG -c \
  'pexec -j -m blockread -d $IMG | \
  jpegtopnm | pnmscale 0.5 | pnmtojpeg | \
  pexec -j -m blockwrite -s th_$IMG'

GNU B<parallel> does not support mutexes directly but uses B<mutex> to
do that.

ls *jpg | parallel -j8 'mutex -m blockread cat {} | jpegtopnm |' \
  'pnmscale 0.5 | pnmtojpeg | mutex -m blockwrite cat > th_{}'


=head1 DIFFERENCES BETWEEN dxargs AND parallel

B<dxargs> does not deal well with more simultaneous jobs than SSHD's
MaxStartup. B<dxargs> is only built for remote run jobs, but does not
support transferring of files.


=head1 DIFFERENCES BETWEEN mdm/middleman AND parallel

middleman(mdm) is also a tool for running jobs in parallel.

Here are the shellscripts of http://mdm.berlios.de/usage.html ported
to parallel use:

B<seq 1 19 | parallel -j+0 buffon -o - | sort -n >>B< result>

B<cat files | parallel -j+0 cmd>


=head1 ENVIRONMENT VARIABLES

The environment variable $PARALLEL will be used as default options for
GNU B<parallel>. However, because some options take arguments the
options need to be split into groups in which only the last option
takes an argument. Each group of options should be put on a line of its
own.

=head1 INIT FILE (RC FILE)

The file ~/.parallelrc will be read if it exists. It should be
formatted like the environment variable $PARALLEL. Lines starting with
'#' will be ignored.


=head2 EXAMPLE

cat list | parallel -j1 -k -v ls

can be written as:

cat list | PARALLEL="-kvj1" parallel ls

cat list | parallel -j1 -k -v -S"myssh user@server" ls

can be written as:

cat list | PARALLEL="-kvj1
-Smyssh user@server" parallel echo

Notice the newline in the middel is needed because both B<-S> and
B<-j> take an argument and thus both need to be at the end of a group.


=head1 BUGS

Filenames beginning with '-' can cause some commands to give
unexpected results, as it will often be interpreted as an option.


=head1 REPORTING BUGS

Report bugs to <bug-parallel@gnu.org>.


=head1 AUTHOR

Copyright (C) 2007-10-18 Ole Tange, http://ole.tange.dk

Copyright (C) 2008,2009,2010 Ole Tange, http://ole.tange.dk

Copyright (C) 2010 Ole Tange, http://ole.tange.dk and Free Software
Foundation, Inc.

Parts of the manual concerning B<xargs> compatibility is inspired by
the manual of B<xargs> from GNU findutils 4.4.2.



=head1 LICENSE

Copyright (C) 2007,2008,2009,2010 Free Software Foundation, Inc.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
at your option any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head2 Documentation license I

Permission is granted to copy, distribute and/or modify this documentation
under the terms of the GNU Free Documentation License, Version 1.3 or
any later version published by the Free Software Foundation; with no
Invariant Sections, with no Front-Cover Texts, and with no Back-Cover
Texts.  A copy of the license is included in the file fdl.txt.

=head2 Documentation license II

You are free:

=over 9

=item B<to Share>

to copy, distribute and transmit the work

=item B<to Remix>

to adapt the work

=back

Under the following conditions:

=over 9

=item B<Attribution>

You must attribute the work in the manner specified by the author or
licensor (but not in any way that suggests that they endorse you or
your use of the work).

=item B<Share Alike>

If you alter, transform, or build upon this work, you may distribute
the resulting work only under the same, similar or a compatible
license.

=back

With the understanding that:

=over 9

=item B<Waiver>

Any of the above conditions can be waived if you get permission from
the copyright holder.

=item B<Public Domain>

Where the work or any of its elements is in the public domain under
applicable law, that status is in no way affected by the license.

=item B<Other Rights>

In no way are any of the following rights affected by the license:

=over 2

=item *

Your fair dealing or fair use rights, or other applicable
copyright exceptions and limitations;

=item *

The author's moral rights;

=item *

Rights other persons may have either in the work itself or in
how the work is used, such as publicity or privacy rights.

=back

=back

=over 9

=item B<Notice>

For any reuse or distribution, you must make clear to others the
license terms of this work.

=back

A copy of the full license is included in the file as cc-by-sa.txt.

=head1 DEPENDENCIES

GNU B<parallel> uses Perl, and the Perl modules Getopt::Long, IPC::Open3,
Symbol, IO::File, POSIX, and File::Temp.


=head1 SEE ALSO

B<find>(1), B<xargs>(1), B<pexec>(1), B<ppss>(1)

=cut


use IPC::Open3;
use Symbol qw(gensym);
use IO::File;
use POSIX ":sys_wait_h";
use File::Temp qw/ tempfile tempdir /;
use Getopt::Long;
use strict;

DoNotReap();
parse_options();
init_run_jobs();
start_more_jobs();
ReapIfNeeded();
drain_job_queue();

sub parse_options {
    # Defaults:
    $Global::version = 20100601;
    $Global::progname = 'parallel';
    $Global::debug = 0;
    $Global::verbose = 0;
    $Global::grouped = 1;
    $Global::keeporder = 0;
    $Global::quoting = 0;
    $Global::replacestring = '{}';
    $Global::replace_no_ext = '{.}';
    $/="\n";
    $Global::ignore_empty = 0;
    $Global::argfile = *STDIN;
    $Global::interactive = 0;
    $Global::stderr_verbose = 0;
    $Global::default_simultaneous_sshlogins = 9;

    Getopt::Long::Configure ("bundling","require_order");
    # Add options from .parallelrc
    my $parallelrc = $ENV{'HOME'}."/.parallelrc";
    if(-r $parallelrc) {
	open (IN, "<", $parallelrc) || die;
	while(<IN>) {
	    /^\s*\#/ and next;
	    chomp;
	    unshift @ARGV, $_;
	}
	close IN;
    }
    # Add options from shell variable $PARALLEL
    $ENV{'PARALLEL'} and unshift @ARGV, split/\n/, $ENV{'PARALLEL'};
    GetOptions("debug|D" => \$::opt_D,
	       "xargs|m" => \$::opt_m,
	       "X" => \$::opt_X,
	       "v" => \$::opt_v,
	       "silent" => \$::opt_silent,
	       "keeporder|k" => \$::opt_k,
	       "group|g" => \$::opt_g,
	       "ungroup|u" => \$::opt_u,
	       "command|c" => \$::opt_c,
	       "file|f" => \$::opt_f,
	       "null|0" => \$::opt_0,
	       "quote|q" => \$::opt_q,
	       "I=s" => \$::opt_I,
	       "extensionreplace|U=s" => \$::opt_U,
	       "jobs|j=s" => \$::opt_P,
	       "max-line-length-allowed" => \$::opt_max_line_length_allowed,
	       "number-of-cpus" => \$::opt_number_of_cpus,
	       "number-of-cores" => \$::opt_number_of_cores,
	       "use-cpus-instead-of-cores" => \$::opt_use_cpus_instead_of_cores,
	       "sshlogin|S=s" => \@::opt_sshlogin,
	       "sshloginfile=s" => \$::opt_sshloginfile,
	       "controlmaster|M" => \$::opt_controlmaster,
	       "return=s" => \@::opt_return,
	       "trc=s" => \@::opt_trc,
	       "transfer" => \$::opt_transfer,
	       "cleanup" => \$::opt_cleanup,
	       # xargs-compatibility - implemented, man, unittest
	       "max-procs|P=s" => \$::opt_P,
	       "delimiter|d=s" => \$::opt_d,
	       "max-chars|s=i" => \$::opt_s,
	       "arg-file|a=s" => \$::opt_a,
	       "no-run-if-empty|r" => \$::opt_r,
	       "replace|i:s" => \$::opt_i,
	       "E=s" => \$::opt_E,
	       "eof|e:s" => \$::opt_E,
	       "max-args|n=i" => \$::opt_n,
	       "help|h" => \$::opt_help,
	       "verbose|t" => \$::opt_verbose,
	       "version|V" => \$::opt_version,
	       "show-limits" => \$::opt_show_limits,
	       ## xargs-compatibility - implemented, man - unittest missing
	       "interactive|p" => \$::opt_p,
	       ## How to unittest? tty skal emuleres
	       # xargs-compatibility - unimplemented
	       "L=i" => \$::opt_L,
	       "max-lines|l:i" => \$::opt_l,
	       ## (echo a b;echo c) | xargs -l1 echo
	       ## (echo a b' ';echo c) | xargs -l1 echo
	       "exit|x" => \$::opt_x,
	) || die_usage();
    $Global::debug = (defined $::opt_D);
    $Global::input_is_filename = (@ARGV);
    if(defined $::opt_m) { $Global::xargs = 1; }
    if(defined $::opt_X) { $Global::Xargs = 1; }
    if(defined $::opt_v) { $Global::verbose = 1; }
    if(defined $::opt_silent) { $Global::verbose = 0; }
    if(defined $::opt_k) { $Global::keeporder = 1; }
    if(defined $::opt_g) { $Global::grouped = 1; }
    if(defined $::opt_u) { $Global::grouped = 0; }
    if(defined $::opt_c) { $Global::input_is_filename = 0; }
    if(defined $::opt_f) { $Global::input_is_filename = 1; }
    if(defined $::opt_0) { $/ = "\0"; }
    if(defined $::opt_d) { my $e="sprintf \"$::opt_d\""; $/ = eval $e; }
    if(defined $::opt_p) { $Global::interactive = $::opt_p; }
    if(defined $::opt_q) { $Global::quoting = 1; }
    if(defined $::opt_r) { $Global::ignore_empty = 1; }
    if(defined $::opt_verbose) { $Global::stderr_verbose = 1; }
    if(defined $::opt_I) { $Global::replacestring = $::opt_I; }
    if(defined $::opt_U) { $Global::replace_no_ext = $::opt_U; }
    if(defined $::opt_i and $::opt_i) { $Global::replacestring = $::opt_i; }
    if(defined $::opt_E and $::opt_E) { $Global::end_of_file_string = $::opt_E; }
    if(defined $::opt_n and $::opt_n) { $Global::max_number_of_args = $::opt_n; }
    if(defined $::opt_help) { die_usage(); }
    if(defined $::opt_number_of_cpus) { print no_of_cpus(),"\n"; exit(0); }
    if(defined $::opt_number_of_cores) { print no_of_cores(),"\n"; exit(0); }
    if(defined $::opt_max_line_length_allowed) { print real_max_length(),"\n"; exit(0); }
    if(defined $::opt_version) { version(); exit(0); }
    if(defined $::opt_show_limits) { show_limits(); }
    if(defined @::opt_sshlogin) { @Global::sshlogin = @::opt_sshlogin; }
    if(defined $::opt_sshloginfile) { read_sshloginfile($::opt_sshloginfile); }
    if(defined @::opt_return) { push @Global::ret_files, @::opt_return; }
    if(defined @::opt_trc) {
	push @Global::ret_files, @::opt_trc;
	$::opt_transfer = 1;
	$::opt_cleanup = 1;
    }

    if(defined $::opt_a) {
	if(not open(ARGFILE,"<",$::opt_a)) {
	    print STDERR "$Global::progname: Cannot open input file `$::opt_a': No such file or directory\n";
	    exit(-1);
	}
	$Global::argfile = *ARGFILE;
    }

    if(@ARGV) {
	if($Global::quoting) {
	    $Global::command = shell_quote(@ARGV);
	} else {
	    $Global::command = join(" ", @ARGV);
	}
    }

    parse_sshlogin();

    # Needs to be done after setting $Global::command and $Global::command_line_max_len
    # as '-m' influences the number of commands that needs to be run
    if(defined $::opt_P) {
	for my $sshlogin (keys %Global::host) {
	    $Global::host{$sshlogin}{'max_no_of_running'} =
		compute_number_of_processes($::opt_P,$sshlogin);
	}
    } else {
	for my $sshlogin (keys %Global::host) {
	    $Global::host{$sshlogin}{'max_no_of_running'} = $Global::default_simultaneous_sshlogins;
	}
    }
    $Global::job_end_sequence=1;
}

#
# Generating the command line
#

sub no_extension {
    my $no_ext = shift;
    $no_ext =~ s:\.[^/\.]*$::; # Remove .ext from argument
    return $no_ext;
}

sub generate_command_line {
    my $command = shift;
    my ($job_line,$last_good);
    my ($next_arg,@quoted_args,@quoted_args_no_ext,$arg_length);
    my ($number_of_substitution,$number_of_substitution_no_ext,$length_of_context,$length_of_command_no_args,$spaces);
    if($Global::xargs or $Global::Xargs) {
	($number_of_substitution, $number_of_substitution_no_ext,$spaces,
	 $length_of_command_no_args,$length_of_context) = xargs_computations($command);
    }

    my $number_of_args = 0;
    # max number of lines (-L) =
    # number_of_read_lines = 0
    while (defined($next_arg = get_next_arg())) {
	my $next_arg_no_ext = no_extension($next_arg);
	# if defined max_number_of_lines
	# number_of_read_lines++
	# if $next_arg =~ /\w$/ then number_of_read_lines--
	    # Trailing blanks cause an
	    # input line to be logically continued on the next input line.
	# if number_of_read_lines > max_number_of_lines
	    # last
	push (@quoted_args, $next_arg);
	push (@quoted_args_no_ext, $next_arg_no_ext);
	$number_of_args++;
	if(not $Global::xargs and not $Global::Xargs) {
	    # No xargs-mode: Just one argument per line
	    last;
	} else {
	    # Emulate xargs if there is a command and -x or -X is set
	    my $next_arg_len = $number_of_substitution * (length ($next_arg) + $spaces) +
		+ $number_of_substitution_no_ext * (length ($next_arg_no_ext) + $spaces)
		+ $length_of_context;

	    $arg_length += $next_arg_len;
	    my $job_line_length = $length_of_command_no_args + $arg_length;
	    if($job_line_length >= max_length_of_command_line()) {
		unget_arg(pop @quoted_args);
		if(defined $quoted_args[0]) {
		    last;
		} else {
		    die ("Command line too long ($job_line_length >= "
			 . max_length_of_command_line() . ") at number $number_of_args: $next_arg");
		}
	    }
	    if($Global::max_number_of_args and $number_of_args >= $Global::max_number_of_args) {
		last;
	    }
	}
    }
    if(@quoted_args) {
	$job_line = $command;
	if(defined $job_line and
	   ($job_line =~/\Q$Global::replacestring\E/o or $job_line =~/\Q$Global::replace_no_ext\E/o)) {
	    # substitute {} and {.} with args
	    if($Global::Xargs) {
		# Context sensitive replace (foo{}bar with fooargsbar)
		$job_line = context_replace($job_line, \@quoted_args, \@quoted_args_no_ext);
	    } else {
		# Normal replace {} with args and {.} with args without extension
		my $arg=join(" ",@quoted_args);
		my $arg_no_ext=join(" ",@quoted_args_no_ext);
		$job_line =~ s/\Q$Global::replacestring\E/$arg/go;
		$job_line =~ s/\Q$Global::replace_no_ext\E/$arg_no_ext/go;
	    }
	} else {
	    # append args
	    my $arg=join(" ",@quoted_args);
	    if($job_line) {
		$job_line .= " ".$arg;
	    } else {
		# Parallel behaving like '|sh'
		$job_line = $arg;
	    }
	}
	debug("Return jobline: !$job_line!\n");
    }
    return ($job_line,\@quoted_args);
}


sub xargs_computations {
    my $command = shift;
    if(not @Calculated::xargs_computations) {
	my ($length_of_command_no_args, $length_of_context, $spaces);

	# Count number of {}'s on the command line
	my $no_of_replace = ($command =~ s/\Q$Global::replacestring\E/$Global::replacestring/go);
	my $number_of_substitution = $no_of_replace || 1;
	# Count number of {.}'s on the command line
	my $no_of_no_ext = ($command =~ s/\Q$Global::replace_no_ext\E/$Global::replace_no_ext/go);
	my $number_of_substitution_no_ext = $no_of_no_ext || 0;
	# Count
	my $c = $command;
	if($Global::xargs) {
	    # remove all {}s
	    $c =~ s/\Q$Global::replacestring\E|\Q$Global::replace_no_ext\E//og;
	    $length_of_command_no_args = length($c) - $no_of_replace - $no_of_no_ext;
	    $length_of_context = 0;
	    $spaces = 1;
	}
	if($Global::Xargs) {
	    $c =~ s/\S*\Q$Global::replacestring\E\S*//go;
	    $c =~ s/\S*\Q$Global::replace_no_ext\E\S*//go;
	    $length_of_command_no_args = length($c) - 1;
	    $length_of_context = length($command) - $length_of_command_no_args
		- $no_of_replace * length($Global::replacestring)
		- $no_of_no_ext * length($Global::replace_no_ext);
	    $spaces = 0;
	}
	
	@Calculated::xargs_computations =
	    ($number_of_substitution, $number_of_substitution_no_ext,
	     $spaces,$length_of_command_no_args,$length_of_context);
    }
    return (@Calculated::xargs_computations);
}


sub shell_quote {
    # Quote the string so shell will not expand any special chars
    my (@strings) = (@_);
    my $arg;
    for $arg (@strings) {
	$arg =~ s/\\/\\\\/g;
	
	$arg =~ s/([\#\?\`\(\)\*\>\<\~\|\; \"\!\$\&\'])/\\$1/g;
	$arg =~ s/([\002-\011\013-\032])/\\$1/g;
	$arg =~ s/([\n])/'\n'/g; # filenames with '\n' is quoted using \'
    }
    return wantarray ? @strings : "@strings";
}


sub shell_unquote {
    # Unquote strings from shell_quote
    my (@strings) = (@_);
    my $arg;
    for $arg (@strings) {
	$arg =~ s/'\n'/\n/g; # filenames with '\n' is quoted using \'
	$arg =~ s/\\([\002-\011\013-\032])/$1/g;
	$arg =~ s/\\([\#\?\`\(\)\*\>\<\~\|\; \"\!\$\&\'])/$1/g;
	$arg =~ s/\\\\/\\/g;
    }
    return wantarray ? @strings : "@strings";
}


# Replace foo{}bar or foo{.}bar
sub context_replace {
    my ($job_line,$quoted,$no_ext) = (@_);
    while($job_line =~/\Q$Global::replacestring\E|\Q$Global::replace_no_ext\E/o) {
	$job_line =~ /(\S*(\Q$Global::replacestring\E|\Q$Global::replace_no_ext\E)\S*)/o
	    or die ("This should never happen");
	my $wordarg = $1; # This is the context that needs to be substituted
	my @all_word_arg;
	for my $n (0 .. $#$quoted) {
	    my $arg = $quoted->[$n];
	    my $arg_no_ext = $no_ext->[$n];
	    my $substituted = $wordarg;
	    $substituted=~s/\Q$Global::replacestring\E/$arg/go;
	    $substituted=~s/\Q$Global::replace_no_ext\E/$arg_no_ext/go;
	    push @all_word_arg, $substituted;
	}
	my $all_word_arg = join(" ",@all_word_arg);
	$job_line =~ s/\Q$wordarg\E/$all_word_arg/;
    }
    return $job_line;
}

#
# Number of processes, filehandles, max length of command line
#

# Maximal command line length (for -m and -X)
sub max_length_of_command_line {
    # Find the max_length of a command line
    # First find an upper bound
    if(not $Global::command_line_max_len) {
	$Global::command_line_max_len = real_max_length();
	if($::opt_s) {
	    if($::opt_s <= $Global::command_line_max_len) {
		$Global::command_line_max_len = $::opt_s;
	    } else {
		print STDERR "$Global::progname: ",
		"value for -s option should be < $Global::command_line_max_len\n";
	    }
	}
    }
    return $Global::command_line_max_len;
}

sub real_max_length {
    my $len = 10;
    do {
	$len *= 10;
    } while (is_acceptable_command_line_length($len));
    # Then search for the actual max length between 0 and upper bound
    return binary_find_max_length(int(($len)/10),$len);
}


sub binary_find_max_length {
    # Given a lower and upper bound find the max_length of a command line
    my ($lower, $upper) = (@_);
    if($lower == $upper or $lower == $upper-1) { return $lower; }
    my $middle = int (($upper-$lower)/2 + $lower);
    debug("Maxlen: $lower,$upper,$middle\n");
    if (is_acceptable_command_line_length($middle)) {
	return binary_find_max_length($middle,$upper);
    } else {
	return binary_find_max_length($lower,$middle);
    }
}

sub is_acceptable_command_line_length {
    # Test if a command line of this length can run
    my $len = shift;
    $Global::is_acceptable_command_line_length++;
    debug("$Global::is_acceptable_command_line_length $len\n");
    local *STDERR;
    open (STDERR,">/dev/null");
    system "true "."x"x$len;
    close STDERR;
    return not $?;
}

# Number of parallel processes to run

sub compute_number_of_processes {
    # Number of processes wanted and limited by system ressources
    my $opt_P = shift;
    my $sshlogin = shift;
    my $wanted_processes = user_requested_processes($opt_P,$sshlogin);
    debug("Wanted procs: $wanted_processes\n");
    my $system_limit = processes_available_by_system_limit($wanted_processes,$sshlogin);
    debug("Limited to procs: $system_limit\n");
    return $system_limit;
}

sub processes_available_by_system_limit {
    # If the wanted number of processes is bigger than the system limits:
    # Limit them to the system limits
    # Limits are: File handles, number of input lines, processes,
    # and taking > 1 second to spawn 10 extra processes

    my $wanted_processes = shift;
    my $sshlogin = shift;
    my $system_limit=0;
    my @command_lines=();
    my ($next_command_line, $args_ref);
    my $more_filehandles;
    my $max_system_proc_reached=0;
    my $spawning_too_slow=0;
    my $time = time;
    my %fh;
    my @children;
    DoNotReap();

    # Reserve filehandles
    # perl uses 7 filehandles for something?
    # parallel uses 1 for memory_usage
    for my $i (1..8) {
	open($fh{"init-$i"},"</dev/null");
    }
    do {
	$system_limit++;

	# If there are no more command lines, then we have a process
	# per command line, so no need to go further
	($next_command_line, $args_ref) = next_command_line();
	if(defined $next_command_line) {
	    push(@command_lines, $next_command_line, $args_ref);
	}

	# Every simultaneous process uses 2 filehandles when grouping
	$more_filehandles = open($fh{$system_limit*2},"</dev/null")
	    && open($fh{$system_limit*2+1},"</dev/null");

	# System process limit
	$system_limit % 10 or $time=time;
	my $child;
	if($child = fork()) {
	    push (@children,$child);
	} elsif(defined $child) {
	    # The child takes one process slot
	    # It will be killed later
	    sleep 100000;
	    exit;
	} else {
	    $max_system_proc_reached = 1;
	}
	debug("Time to fork ten procs ", time-$time, " process ", $system_limit);
	if(time-$time > 2) {
	    # It took more than 2 second to fork ten processes. We should stop forking.
	    # Let us give the system a little slack
	    debug("\nLimiting processes to: $system_limit-10%=".
		  (int ($system_limit * 0.9)+1)."\n");
	    $system_limit = int ($system_limit * 0.9)+1;
	    $spawning_too_slow = 1;
	}
    } while($system_limit < $wanted_processes
	    and defined $next_command_line
	    and $more_filehandles
	    and not $max_system_proc_reached
	    and not $spawning_too_slow);
    if($system_limit < $wanted_processes and not $more_filehandles) {
	print STDERR ("Warning: Only enough filehandles to run ",
		      $system_limit, " jobs in parallel. ",
		      "Raising ulimit -n may help\n");
    }
    if($system_limit < $wanted_processes and $max_system_proc_reached) {
	print STDERR ("Warning: Only enough available processes to run ",
		      $system_limit, " jobs in parallel.\n");
    }
    if($system_limit < $wanted_processes and $spawning_too_slow) {
	print STDERR ("Warning: Starting 10 extra processes takes > 2 sec.\n",
		      "Limiting to ", $system_limit, " jobs in parallel.\n");
    }
    # Cleanup: Close the files
    for (values %fh) { close $_ }
    # Cleanup: Kill the children
    for my $pid (@children) {
	kill 15, $pid;
	waitpid($pid,0);
    }
    wait();
    # Cleanup: Unget the command_lines (and args_refs)
    unget_command_line(@command_lines);
    if($sshlogin ne ":" and $system_limit > $Global::default_simultaneous_sshlogins) {
	$system_limit = simultaneous_sshlogin_limit($sshlogin,$system_limit);
    }
    return $system_limit;
}

sub simultaneous_sshlogin {
    # Using $sshlogin try to see if we can do $wanted_processes
    # simultaneous logins
    my $sshlogin = shift;
    my $wanted_processes = shift;
    my ($sshcmd,$serverlogin) = sshcommand_of_sshlogin($sshlogin);
    my $cmd = "$sshcmd $serverlogin echo simultaneouslogin 2>&1 &"x$wanted_processes;
    open (SIMUL, "($cmd)|grep simultaneouslogin | wc -l|") or die;
    my $ssh_limit = <SIMUL>;
    close SIMUL;
    chomp $ssh_limit;
    return $ssh_limit;
}

sub simultaneous_sshlogin_limit {
    # Test by logging in wanted number of times simultaneously
    # (ssh e echo simultaneouslogin &ssh e echo simultaneouslogin &...)|grep simul|wc -l
    # Return min($wanted_processes,$working_simultaneous_ssh_logins-1)
    my $sshlogin = shift;
    my $wanted_processes = shift;
    my ($sshcmd,$serverlogin) = sshcommand_of_sshlogin($sshlogin);
    # Try twice because it guesses wrong sometimes
    # Choose the minimal
    my $ssh_limit = min(simultaneous_sshlogin($sshlogin,$wanted_processes),
			simultaneous_sshlogin($sshlogin,$wanted_processes));
    if($ssh_limit < $wanted_processes) {
	print STDERR ("Warning: ssh to $serverlogin only allows for $ssh_limit simultaneous logins.\n",
		      "You may raise this by changing /etc/ssh/sshd_config:MaxStartup on $serverlogin\n",
		      "Using only ",$ssh_limit-1," connections to avoid race conditions\n");
    }
    # Race condition can cause problem if using all sshs.
    if($ssh_limit > 1) { $ssh_limit -= 1; }
    return $ssh_limit;
}

sub enough_file_handles {
    # check that we have enough filehandles available for starting
    # another job
    if($Global::grouped) {
	my %fh;
	my $enough_filehandles = 1;
	# We need a filehandle for STDOUT and STDERR
	# open3 uses 2 extra filehandles temporarily
	for my $i (1..4) {
	    $enough_filehandles &&= open($fh{$i},"</dev/null");
	}
	for (values %fh) { close $_; }
	return $enough_filehandles;
    } else {
	return 1;
    }
}

sub user_requested_processes {
    # Parse the number of processes that the user asked for
    my $opt_P = shift;
    my $sshlogin = shift;
    my $processes;
    if(defined $opt_P) {
	if($opt_P =~ /^\+(\d+)$/) {
	    # E.g. -P +2
	    my $j = $1;
	    $processes = $j + no_of_processing_units_sshlogin($sshlogin);
	} elsif ($opt_P =~ /^-(\d+)$/) {
	    # E.g. -P -2
	    my $j = $1;
	    $processes = no_of_processing_units_sshlogin($sshlogin) - $j;
	} elsif ($opt_P =~ /^(\d+)\%$/) {
	    my $j = $1;
	    $processes = no_of_processing_units_sshlogin($sshlogin) * $j / 100;
	} elsif ($opt_P =~ /^(\d+)$/) {
	    $processes = $1;
	    if($processes == 0) {
		# -P 0 = infinity (or at least close)
		$processes = 2**31;
	    }
	} else {
	    die_usage();
	}
	if($processes < 1) {
	    $processes = 1;
	}
    }
    return $processes;
}

sub no_of_processing_units_sshlogin {
    # Number of processing units (CPUs or cores) at this sshlogin
    my $sshlogin = shift;
    my ($sshcmd,$serverlogin) = sshcommand_of_sshlogin($sshlogin);
    if(not $Global::host{$sshlogin}{'ncpus'}) {
	if($serverlogin eq ":") {
	    if($::opt_use_cpus_instead_of_cores) {
		$Global::host{$sshlogin}{'ncpus'} = no_of_cpus();
	    } else {
		$Global::host{$sshlogin}{'ncpus'} = no_of_cores();
	    }
	} else {
	    my $ncpu;
	    if($::opt_use_cpus_instead_of_cores) {
		$ncpu = qx(echo|$sshcmd $serverlogin parallel --number-of-cpus);
		chomp($ncpu);
	    } else {
		$ncpu = qx(echo|$sshcmd $serverlogin parallel --number-of-cores);
		chomp($ncpu);
	    }
	    if($ncpu =~ /^[0-9]+$/) {
		$Global::host{$sshlogin}{'ncpus'} = $ncpu;
	    } else {
		print STDERR ("Warning: Could not figure out number of cpus on $serverlogin. Using 1");
		$Global::host{$sshlogin}{'ncpus'} = 1;
	    }
	}
    }
    return $Global::host{$sshlogin}{'ncpus'};
}

sub no_of_cpus {
    if(not $Global::no_of_cpus) {
	local $/="\n"; # If delimiter is set, then $/ will be wrong
	my $no_of_cpus = (0
			  || no_of_cpus_freebsd()
			  || no_of_cpus_darwin()
			  || no_of_cpus_solaris()
			  || no_of_cpus_gnu_linux()
	    );
	if($no_of_cpus) {
	    $Global::no_of_cpus = $no_of_cpus;
	} else {
	    warn("Cannot figure out number of cpus. Using 1");
	    $Global::no_of_cpus = 1;
	}
    }
    return $Global::no_of_cpus;
}

sub no_of_cores {
    if(not $Global::no_of_cores) {
	local $/="\n"; # If delimiter is set, then $/ will be wrong
	my $no_of_cores = (0
			   || no_of_cores_freebsd()
			   || no_of_cores_darwin()
			   || no_of_cores_solaris()
			   || no_of_cores_gnu_linux()
	    );
	if($no_of_cores) {
	    $Global::no_of_cores = $no_of_cores;
	} else {
	    warn("Cannot figure out number of CPU cores. Using 1");
	    $Global::no_of_cores = 1;
	}
    }
    return $Global::no_of_cores;
}

sub no_of_cpus_gnu_linux {
    my $no_of_cpus;
    if(-e "/proc/cpuinfo") {
	$no_of_cpus = 0;
	my %seen;
	open(IN,"cat /proc/cpuinfo|") || return undef;
	while(<IN>) {
	    if(/^physical id.*[:](.*)/ and not $seen{$1}++) {
		$no_of_cpus++;
	    }
	}
	close IN;
    }
    return $no_of_cpus;
}

sub no_of_cores_gnu_linux {
    my $no_of_cores;
    if(-e "/proc/cpuinfo") {
	$no_of_cores = 0;
	open(IN,"cat /proc/cpuinfo|") || return undef;
	while(<IN>) {
	    /^processor.*[:]/ and $no_of_cores++;
	}
	close IN;
    }
    return $no_of_cores;
}

sub no_of_cpus_darwin {
    my $no_of_cpus = `sysctl -a hw 2>/dev/null | grep -w physicalcpu | awk '{ print \$2 }'`;
    return $no_of_cpus;
}

sub no_of_cores_darwin {
    my $no_of_cores = `sysctl -a hw  2>/dev/null | grep -w logicalcpu | awk '{ print \$2 }'`;
    return $no_of_cores;
}

sub no_of_cpus_freebsd {
    my $no_of_cpus = `sysctl hw.ncpu 2>/dev/null | awk '{ print \$2 }'`;
    return $no_of_cpus;
}

sub no_of_cores_freebsd {
    my $no_of_cores = `sysctl -a hw  2>/dev/null | grep -w logicalcpu | awk '{ print \$2 }'`;
    return $no_of_cores;
}

sub no_of_cpus_solaris {
    if(-x "/usr/sbin/psrinfo") {
	my @psrinfo = `/usr/sbin/psrinfo`;
	if($#psrinfo >= 0) {
	    return $#psrinfo +1;
	}
    }
    if(-x "/usr/sbin/prtconf") {
	my @prtconf = `/usr/sbin/prtconf | grep cpu..instance`;
	if($#prtconf >= 0) {
	    return $#prtconf +1;
	}
    }
    return undef;
}

sub no_of_cores_solaris {
    if(-x "/usr/sbin/psrinfo") {
	my @psrinfo = `/usr/sbin/psrinfo`;
	if($#psrinfo >= 0) {
	    return $#psrinfo +1;
	}
    }
    if(-x "/usr/sbin/prtconf") {
	my @prtconf = `/usr/sbin/prtconf | grep cpu..instance`;
	if($#prtconf >= 0) {
	    return $#prtconf +1;
	}
    }
    return undef;
}

#
# General useful library functions
#

sub min {
    my $min = shift;
    my @args = @_;
    for my $a (@args) {
	$min = ($min < $a) ? $min : $a;
    }
    return $min;
}


#
# Running and printing the jobs
#

# Variable structure:
#    $Global::running{$pid}{'seq'} = printsequence
#    $Global::running{$pid}{sshlogin} = server to run on
#    $Global::host{$sshlogin}{'no_of_running'} = number of currently running jobs
#    $Global::host{$sshlogin}{'ncpus'} = number of cpus
#    $Global::host{$sshlogin}{'maxlength'} = max line length (currently buggy for remote)
#    $Global::host{$sshlogin}{'max_no_of_running'} = number of currently running jobs
#    $Global::host{$sshlogin}{'sshcmd'} = command to use as ssh
#    $Global::host{$sshlogin}{'serverlogin'} = username@hostname
#    $Global::running_jobs = total number of running jobs

sub init_run_jobs {
    # Remember the original STDOUT and STDERR
    open $Global::original_stdout, ">&STDOUT" or die "Can't dup STDOUT: $!";
    open $Global::original_stderr, ">&STDERR" or die "Can't dup STDERR: $!";
    open $Global::original_stdin, "<&STDIN" or die "Can't dup STDIN: $!";
    $Global::running_jobs=0;
    $SIG{USR1} = \&ListRunningJobs;
    $Global::original_sigterm = $SIG{TERM};
    $SIG{TERM} = \&StartNoNewJobs;
}

sub login_and_host {
    my $sshlogin = shift;
    $sshlogin =~ /(\S+$)/ or die;
    return $1;
}

sub next_command_line_with_sshlogin {
    my $sshlogin = shift;
    my ($next_command_line, $args_ref) = next_command_line();
    my ($sshcmd,$serverlogin) = sshcommand_of_sshlogin($sshlogin);
    my ($pre,$post)=("","");
    if($next_command_line and $serverlogin ne ":") {
	for my $file (@$args_ref) {
	    $file =~ s:/\./:/:g; # Rsync treats /./ special. We dont want that
	    my $noext = no_extension($file); # Remove .ext before prepending ./
	    my $relpath = ($file !~ m:^/:); # Is the path relative?
	    # If relative path: prepend ./ (to avoid problems with ':')
	    $noext = ($relpath ? "./".$noext : $noext);
	    my $rsync_opt = "-rlDzR -e".shell_quote($sshcmd);
	    # Use different subdirs depending on abs or rel path
	    my $rsync_destdir = ($relpath ? "./" : "/");
	    if($::opt_transfer) {
		# --transfer
		# Abs path: rsync -rlDzR /home/tange/dir/subdir/file.gz server:/
		# Rel path: rsync -rlDzR ./subdir/file.gz server:./
		if(-r shell_unquote($file)) {
		    $pre = "rsync $rsync_opt $file $serverlogin:$rsync_destdir ;";
		} else {
		    print STDERR "Warning: $file is not readable and will not be transferred\n";
		}
	    }
	    for my $ret_file (@Global::ret_files) {
		my $remove = $::opt_cleanup ? "--remove-source-files" : "";
		my $replaced = context_replace($ret_file,[$file],[$noext]);
		# --return
		# Abs path: rsync -rlDzR server:/home/tange/dir/subdir/file.gz /
		# Rel path: rsync -rlDzR server:./subsir/file.gz ./
		$post .= "rsync $rsync_opt $remove $serverlogin:".shell_quote($replaced)." $rsync_destdir ;";
	    }
	    if($::opt_cleanup) {
		$post .= "$sshcmd $serverlogin rm -f ".shell_quote($file).";";
	    }
	}
	return "$pre$sshcmd $serverlogin ".shell_quote($next_command_line)."; $post";
    } else {
	return $next_command_line;
    }
}

sub next_command_line {
    my ($cmd_line,$args_ref);
    if(@Global::unget_next_command_line) {
	$cmd_line = shift @Global::unget_next_command_line;
	$args_ref = shift @Global::unget_next_command_line;
    } else {
	do {
	    ($cmd_line,$args_ref) = generate_command_line($Global::command);
	} while (defined $cmd_line and $cmd_line =~ /^\s*$/); # Skip empty lines
    }
    return ($cmd_line,$args_ref);
}

sub unget_command_line {
    push @Global::unget_next_command_line, @_;
}

sub get_next_arg {
    my $arg;
    if(@Global::unget_arg) {
	$arg = shift @Global::unget_arg;
    } else {
	if(eof $Global::argfile) {
	    return undef;
	}
	$arg = <$Global::argfile>;
	chomp $arg;
	if($Global::end_of_file_string and $arg eq $Global::end_of_file_string) {
	    # Ignore the rest of STDIN
	    while (<$Global::argfile>) {}
	    return undef;
	}
	if($Global::ignore_empty) {
	    if($arg =~ /^\s*$/) {
		return get_next_arg();
	    }
	}
	if($Global::input_is_filename) {
	    $arg = shell_quote($arg);
	}
    }
    debug("Next arg: !".$arg."!\n");
    return $arg;
}

sub unget_arg {
    push @Global::unget_arg, @_;
}

sub drain_job_queue {
    while($Global::running_jobs > 0) {
	debug("jobs running: $Global::running_jobs Memory usage:".my_memory_usage()."\n");
	sleep 1;
    }
}

sub start_more_jobs {
    my $jobs_started = 0;

    # BC hack
    for (;;) {
      my($sockets) = `netstat -anp | grep -i tcp |wc -l`;
      if ($sockets < 50) {last;}
      if ($sockets > 50) {
	print STDERR "$sockets > 50 sockets open, waiting 1 second\n";
	sleep(1);
      }
    }

    if(not $Global::StartNoNewJobs) {
	for my $sshlogin (keys %Global::host) {
	    debug("Running jobs on $sshlogin: $Global::host{$sshlogin}{'no_of_running'}\n");
	    while ($Global::host{$sshlogin}{'no_of_running'} <
		$Global::host{$sshlogin}{'max_no_of_running'}) {
		if(start_another_job($sshlogin) == 0) {
		    # No more jobs to start
		    last;
		}
		$Global::host{$sshlogin}{'no_of_running'}++;
		$jobs_started++;
	    }
	    debug("Running jobs on $sshlogin: $Global::host{$sshlogin}{'no_of_running'}\n");
	}
    }
    return $jobs_started;
}

sub start_another_job {
    # Grab a job from @Global::command, start it
    # and remember the pid, the STDOUT and the STDERR handles
    # Return 1.
    # If no more jobs: do nothing and return 0
    # Do we have enough file handles to start another job?
    my $sshlogin = shift;
    if(enough_file_handles()) {
	my $command = next_command_line_with_sshlogin($sshlogin);
	if(defined $command) {
	    debug("Command to run on '$sshlogin': $command\n");
	    my %jobinfo = start_job($command,$sshlogin);
	    if(%jobinfo) {
		$Global::running{$jobinfo{"pid"}} = \%jobinfo;
		return 1;
	    } else {
		# If interactive says: Dont run the job, then skip it and run the next
		return start_another_job($sshlogin);
	    }
	} else {
	    # No more commands to run
	    return 0;
	}
    } else {
	# No more file handles
	return 0;
    }
}

sub start_job {
    # Setup STDOUT and STDERR for a job and start it.
    my $command = shift;
    my $sshlogin = shift;
    my ($pid,$out,$err,%out,%err,$outname,$errname,$name);
    if($Global::grouped) {
	# To group we create temporary files for STDOUT and STDERR
	# Filehandles are global, so to not overwrite the filehandles use a hash with new keys
	# To avoid the cleanup unlink the files immediately (but keep them open)
	$outname = ++$Global::TmpFilename;
	($out{$outname},$name) = tempfile(SUFFIX => ".par");
	unlink $name;
	$errname = ++$Global::TmpFilename;
	($err{$errname},$name) = tempfile(SUFFIX => ".par");
	unlink $name;

	open STDOUT, '>&', $out{$outname} or die "Can't redirect STDOUT: $!";
	open STDERR, '>&', $err{$errname} or die "Can't dup STDOUT: $!";
    }

    if($Global::interactive or $Global::stderr_verbose) {
	if($Global::interactive) {
	    print $Global::original_stderr "$command ?...";
	    open(TTY,"/dev/tty") || die;
	    my $answer = <TTY>;
	    close TTY;
	    my $run_yes = ($answer =~ /^\s*y/i);
	    if (not $run_yes) {
		open STDOUT, ">&", $Global::original_stdout or die "Can't dup \$oldout: $!";
		open STDERR, ">&", $Global::original_stderr or die "Can't dup \$oldout: $!";
		return;
	    }
	} else {
	    print $Global::original_stderr "$command\n";
	}
    }
    if($Global::verbose and not $Global::grouped) {
	print STDOUT $command,"\n";
    }
    $Global::running_jobs++;
    debug("$Global::running_jobs processes. Starting: $command\n");
    #print STDERR "LEN".length($command)."\n";
    $Global::job_start_sequence++;

    if($::opt_a and $Global::job_start_sequence == 1) {
	# Give STDIN to the first job if using -a
	$pid = open3("<&STDIN", ">&STDOUT", ">&STDERR", $command) ||
	    die("open3 failed. Report a bug to <bug-parallel\@gnu.org>\n");
	# Re-open to avoid complaining
	open STDIN, "<&", $Global::original_stdin or die "Can't dup \$Global::original_stdin: $!";
    } else {
	$pid = open3(gensym, ">&STDOUT", ">&STDERR", $command) ||
	    die("open3 failed. Report a bug to <bug-parallel\@gnu.org>\n");
    }
    debug("started: $command\n");
    open STDOUT, ">&", $Global::original_stdout or die "Can't dup \$Global::original_stdout: $!";
    open STDERR, ">&", $Global::original_stderr or die "Can't dup \$Global::original_stderr: $!";

    if($Global::grouped) {
	return ("seq" => $Global::job_start_sequence,
		"pid" => $pid,
		"out" => $out{$outname},
		"err" => $err{$errname},
		"sshlogin" => $sshlogin,
		"command" => $command);
    } else {
	return ("seq" => $Global::job_start_sequence,
		"pid" => $pid,
		"sshlogin" => $sshlogin,
		"command" => $command);
    }
}

sub print_job {
    # Print the output of the jobs
    # Only relevant for grouping
    $Global::grouped or return;
    my $fhs = shift;
    if(not defined $fhs) {
	return;
    }
    my $out = $fhs->{out};
    my $err = $fhs->{err};
    my $command = $fhs->{command};

    debug(">>joboutput $command\n");
    if($Global::verbose and $Global::grouped) {
	print STDOUT $command,"\n";
	# If STDOUT and STDERR is merged, we want the command to be printed first
	# so flush to avoid STDOUT being buffered
	flush STDOUT;
    }
    seek $_, 0, 0 for $out, $err;
    if($Global::debug) {
	print STDERR "ERR:\n";
    }
    my $buf;
    while(sysread($err,$buf,1000_000)) {
	print STDERR $buf;
    }
    if($Global::debug) {
	print STDOUT "OUT:\n";
    }
    while(sysread($out,$buf,1000_000)) {
	print STDOUT $buf;
    }
    debug("<<joboutput $command\n");
    close $out;
    close $err;
}

#
# Remote ssh
#

sub read_sshloginfile {
    my $file = shift;
    open(IN, $file) || die "Cannot open $file";
    while(<IN>) {
	chomp;
	push @Global::sshlogin, $_;
    }
    close IN;
}


sub parse_sshlogin {
    my (@login);
    if(not @Global::sshlogin) { @Global::sshlogin = (":"); }
    for my $sshlogin (@Global::sshlogin) {
	# Split up -S sshlogin,sshlogin
	push (@login, (split /,/, $sshlogin));
    }
    for my $sshlogin (@login) {
	if($sshlogin =~ s:^(\d*)/::) {
	    # Override default autodetected ncpus unless zero or missing
	    if($1) {
		$Global::host{$sshlogin}{'ncpus'} = $1;
	    }
	}
	$Global::host{$sshlogin}{'no_of_running'} = 0;
	$Global::host{$sshlogin}{'maxlength'} = max_length_of_command_line();
    }
    debug("sshlogin: ", my_dump(%Global::host));
    if($::opt_transfer or @::opt_return or $::opt_cleanup) {
	my @remote_hosts = grep !/^:$/, keys %Global::host;
	debug("Remote hosts: ",@remote_hosts);
	if(not @remote_hosts) {
	    # There are no remote hosts
	    if(defined @::opt_trc) {
		print STDERR "Warning: --trc ignored as there are no remote --sshlogin\n";
	    } elsif (defined $::opt_transfer) {
		print STDERR "Warning: --transfer ignored as there are no remote --sshlogin\n";
	    } elsif (defined @::opt_return) {
		print STDERR "Warning: --return ignored as there are no remote --sshlogin\n";
	    } elsif (defined $::opt_cleanup) {
		print STDERR "Warning: --cleanup ignored as there are no remote --sshlogin\n";
	    }
	}
    }
}

sub sshcommand_of_sshlogin {
    # 'server' -> ('ssh -S /tmp/parallel-ssh-RANDOM/host-','server')
    # 'user@server' -> ('ssh','user@server')
    # 'myssh user@server' -> ('myssh','user@server')
    # 'myssh -l user server' -> ('myssh -l user','server')
    # '/usr/local/bin/myssh -l user server' -> ('/usr/local/bin/myssh -l user','server')
    my $sshlogin = shift;
    my ($sshcmd, $serverlogin);
    if($sshlogin =~ /(.+) (\S+)$/) {
	# Own ssh command
	$sshcmd = $1; $serverlogin = $2;
    } else {
	# Normal ssh
	if($::opt_controlmaster) {
	    # Use control_path to make ssh faster
	    my $control_path = control_path_dir()."/ssh-%r@%h:%p";
	    $sshcmd = "ssh -S ".$control_path;
	    $serverlogin = $sshlogin;
	    #my $master = "ssh -MTS ".control_path_dir()."/ssh-%r@%h:%p ".$serverlogin;
	    my $master = "ssh -MTS ".control_path_dir()."/ssh-%r@%h:%p ".$serverlogin." sleep 1";
	    if(not $Global::control_path{$control_path}++) {
		my $pid = fork();
		if($pid) {
		    $Global::sshmaster{$pid}++;
		} else {
		    debug($master,"\n");
		    `$master`;
		    exit;
		}
	    }
	} else {
	    $sshcmd = "ssh"; $serverlogin = $sshlogin;
	}
    }
    return ($sshcmd, $serverlogin);
}

sub control_path_dir {
    if(not $Global::control_path_dir) {
	$Global::control_path_dir = tempdir("/tmp/parallel-ssh-XXXX", CLEANUP => 1 );
    }
    return $Global::control_path_dir;
}


#
# Signal handling
#

sub ListRunningJobs {
    for my $v (values %Global::running) {
	print STDERR "$Global::progname: ",$v->{'command'},"\n";
    }
}

sub StartNoNewJobs {
    print STDERR ("$Global::progname: SIGTERM received. No new jobs will be started.\n",
		  "$Global::progname: Waiting for these ", scalar(keys %Global::running),
		  " jobs to finish. Send SIGTERM again to stop now.\n");
    ListRunningJobs();
    $Global::StartNoNewJobs++;
    $SIG{TERM} = $Global::original_sigterm;
}

sub CountSigChild {
    $Global::SigChildCaught++;
}

sub DoNotReap {
    # This will postpone SIGCHILD for sections that cannot be distracted by a dying child
    # (Racecondition)
    $SIG{CHLD} = \&CountSigChild;
}

sub ReapIfNeeded {
    # Do the postponed SIGCHILDs if any and re-install normal reaper for SIGCHILD
    # (Racecondition)
    if($Global::SigChildCaught) {
	$Global::SigChildCaught = 0;
	Reaper();
    }
    $SIG{CHLD} = \&Reaper;
}

sub Reaper {
    # A job finished.
    # Print the output.
    # Start another job
    DoNotReap();
    $Global::reaperlevel++;
    my $stiff;
    debug("Reaper called $Global::reaperlevel\n");
    while (($stiff = waitpid(-1, &WNOHANG)) > 0) {
	if($Global::sshmaster{$stiff}) {
	    # This is one of the ssh -M: ignore
	    next;
	}
	if($Global::keeporder) {
	    $Global::print_later{$Global::running{$stiff}{"seq"}} = $Global::running{$stiff};
	    debug("died: $Global::running{$stiff}{'seq'}");
	    while($Global::print_later{$Global::job_end_sequence}) {
		debug("Found job end $Global::job_end_sequence");
		print_job($Global::print_later{$Global::job_end_sequence});
		delete $Global::print_later{$Global::job_end_sequence};
		$Global::job_end_sequence++;
	    }
	} else {
	    print_job ($Global::running{$stiff});
	}
	my $sshlogin = $Global::running{$stiff}{'sshlogin'};
	$Global::host{$sshlogin}{'no_of_running'}--;
	$Global::running_jobs--;
	delete $Global::running{$stiff};
	start_more_jobs();
    }
    ReapIfNeeded();
    debug("Reaper exit $Global::reaperlevel\n");
    $Global::reaperlevel--;
}

#
# Usage
#

sub die_usage {
    usage();
    exit(1);
}

sub usage {
    print "Usage:\n";
    print "$Global::progname [options] [command [arguments]] < list_of_arguments\n";
    print "\n";
    print "See 'man $Global::progname' for the options\n";
}

sub version {
    print join("\n",
	       "$Global::progname $Global::version",
	       "Copyright (C) 2007,2008,2009,2010 Ole Tange and Free Software Foundation, Inc.",
	       "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>",
	       "This is free software: you are free to change and redistribute it.",
	       "$Global::progname comes with no warranty.",
	       "",
	       "Web site: http://www.gnu.org/software/${Global::progname}\n"
	);
}

sub show_limits {
    print("Maximal size of command: ",real_max_length(),"\n",
	  "Maximal used size of command: ",max_length_of_command_line(),"\n",
	  "\n",
	  "Execution of  will continue now, and it will try to read its input\n",
	  "and run commands; if this is not what you wanted to happen, please\n",
	  "press CTRL-D or CTRL-C\n");
}


#
# Debugging
#

sub debug {
    $Global::debug or return;
    if($Global::original_stdout) {
	print $Global::original_stdout @_;
    } else {
	print @_;
    }
}

sub my_memory_usage {
    use strict;
    use FileHandle;


    my $pid = $$;
    if(-e "/proc/$pid/stat") {
	my $fh = FileHandle->new("</proc/$pid/stat");

	my $data = <$fh>;
	chomp $data;
	$fh->close;

	my @procinfo = split(/\s+/,$data);

	return $procinfo[22];
    } else {
	return 0;
    }
}

sub my_size {
    my @size_this = (@_);
    eval "use Devel::Size qw(size total_size)";
    if ($@) {
	return -1;
    } else {
	return total_size(@_);
    }
}


sub my_dump {
    my @dump_this = (@_);
    eval "use Data::Dump qw(dump);";
    if ($@) {
        # Data::Dump not installed
        eval "use Data::Dumper;";
        if ($@) {
            my $err =  "Neither Data::Dump nor Data::Dumper is installed\n".
                "Not dumping output\n";
            print STDERR $err;
            return $err;
        } else {
            return Dumper(@dump_this);
        }
    } else {
        eval "use Data::Dump qw(dump);";
        return (Data::Dump::dump(@dump_this));
    }
}

# Keep perl -w happy
$main::opt_u = $main::opt_e = $main::opt_c = $main::opt_f =
$main::opt_q = $main::opt_0 = $main::opt_s = $main::opt_v =
$main::opt_g = $main::opt_P = $main::opt_D = $main::opt_m =
$main::opt_X = $main::opt_x = $main::opt_k = $main::opt_d =
$main::opt_P = $main::opt_i = $main::opt_p = $main::opt_a =
$main::opt_version = $main::opt_L = $main::opt_l =
$main::opt_show_limits = $main::opt_n = $main::opt_e = $main::opt_verbose =
$main::opt_E = $main::opt_r = $Global::xargs = $Global::keeporder =
$Global::control_path = 0;

# Hvordan udregnes system limits på remote systems hvis jeg ikke ved, hvormange
# argumenter, der er? Lav system limits lokalt og lad det være max

# TODO max_line_length on remote
# TODO compute how many can be transferred within max_line_length
# TODO Unittest with filename that is long and requires a lot of quoting. Will there be to many
# TODO --max-number-of-jobs print the system limited number of jobs

# TODO Debian package
# TODO transfer a script to be run
