set ns [new Simulator]

set nf [open out.nam w]
$ns namtrace-all $nf

$ns color 1 Blue
$ns color 2 Green
$ns color 3 Orange
$ns color 4 Yellow
$ns color 5 Purple

proc finish {} {
    global ns nf
    puts "entered finish"
    $ns flush-trace
    close $nf
    exec nam out.nam &
    exit 0
}

for {set i 0} {$i < 6} {incr i} {
    set n($i) [$ns node]
}

for {set i 1} {$i <= 5 } {incr i} {
    $ns simplex-link $n(0) $n($i) 0.1Mb 10ms DropTail
    $ns simplex-link $n($i) $n(0) 2Mb 10ms DropTail
    $ns queue-limit $n(0) $n($i) 5
    $ns queue-limit $n($i) $n(0) 5
}

set null(0) [new Agent/Null]
$ns attach-agent $n(0) $null(0)

for {set i 1} {$i < 6} {incr i} {
    set udp($i) [new Agent/UDP]
    $ns attach-agent $n($i) $udp($i)

    if {[expr {($i - 1) % 5}] == 0} {
      set null(5) [new Agent/Null]
      $ns attach-agent $n(5) $null(5)
      $ns connect $udp($i) $null(5)
    } else {
      set null([expr {($i - 1) % 5}]) [new Agent/Null]
      $ns attach-agent $n([expr {($i - 1) % 5}]) $null([expr {($i - 1) % 5}])
      $ns connect $udp($i) $null([expr {($i - 1) % 5}])
    }
    
    $udp($i) set fid_ $i
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
