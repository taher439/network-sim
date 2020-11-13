set ns [new Simulator]

set nf [open out2.nam w]
set tr [open trace.tr w]
$ns namtrace-all $nf 
$ns trace-all $tr

$ns color 0 Blue
$ns color 1 Green
$ns color 2 Orange
$ns color 3 Yellow

proc finish {} {
    global ns nf tr
    puts "entered finish"
    $ns flush-trace
    close $nf
    exec nam out2.nam &
    close $tr
    exit 0
}

for {set i 0} {$i < 4} {incr i} {
  set n($i) [$ns node] 
}

for {set i 0} {$i < 100} {incr i} {
  set m($i) [$ns node]
}

for {set i 0} {$i < 100} {incr i} {
  set j [expr {$i / 25}]
  $ns duplex-link $m($i)  $n($j) 1.5Mb 10ms DropTail
}

for {set i 0} {$i < 4} {incr i} {
  set j [expr {($i + 1) % 4}]
  $ns simplex-link $n($i)  $n($j) 2Mb 10ms DropTail
  $ns queue-limit  $n($i)  $n($j) 5
}


for {set i 0} {$i < 4} {incr i} {
  set null($i) [new Agent/Null]
  $ns attach-agent $n($i) $null($i)
}

for {set i 0} {$i < 100} {incr i} {
  set udp($i) [new Agent/UDP]
  $ns attach-agent $m($i) $udp($i)
     
  set j [expr {($i + 25) % 100}]
  set k [expr {$i / 25}]
  puts "($i, $j)"

  set null($j) [new Agent/Null]
  $ns attach-agent $m($j) $null($j)

  $ns connect $udp($i) $null($j)

  $udp($i) set fid_ $k
  set cbr($i) [new Application/Traffic/CBR]
  $cbr($i) attach-agent $udp($i)
  $cbr($i) set type_ CBR
  $cbr($i) set packet_size_ 1000
  $cbr($i) set rate_ 1mb
  $cbr($i) set random_ false
  $ns at 0.0 "$cbr($i) start"
  $ns at 4.5 "$cbr($i) stop"
}

$ns at 5.0 "finish"
$ns run
