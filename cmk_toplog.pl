#!/usr/bin/perl
use strict;

my $message_log="/var/log/messages";
my @log;
my (%res, $element) = ();
my $item;
my $crit_count="2";
my $check_name="top_log";
my $status="0";
my $checkinfo;
my $size;
my $ssize;
my $position;
my $ldf="/var/log/.ldf";

open LDF, "$ldf";
my $ssize=<LDF>;
close LDF;

(undef, undef, undef, undef, undef, undef, undef, $size, undef, undef, undef, undef, undef) = stat("$message_log");

if ($size<$ssize) { 
        $position="0";
} else {
        $position=$ssize;
}
print"position1:$position\n";

open MSG, "<$message_log" or die "Failed to open messages: $!\n";
seek(MSG,"$position",0);
while (my $msg = <MSG>) {
        $msg=~s/(^\w+) (\d+ )(\d+):(\d+):(\d+ )//g;
        push  @log, $msg;
}
print "@log\n";

chomp @log;
my $position=tell MSG;
close MSG;

foreach $item (@log) {
        $res{$item}++ ;
               print "$item $res{$item}\n";
}

my @sorted_keys = (sort {$res{$a} <=>  $res{$b}} keys %res);
print "@sorted_keys\n";
my $max=pop @sorted_keys;

open LDF, ">$ldf";
print LDF "$position";
close LDF;

print "Debug:$max $res{$max} size:$size ssize:$ssize position:$position\n";

if ($res{$max}>=$crit_count) {
        $status="2";
        print "$status $check_name - $check_name: $max $res{$max}\n";
} else {
        $status="0";
        print "$status $check_name - $check_name: critical level not reached\n";
}
