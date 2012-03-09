onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider Axi4Lite
add wave -noupdate -format Logic -Radix Hexadecimal /tb/axi4lite/*

add wave -noupdate -divider Axi4
add wave -noupdate -format Logic -Radix Hexadecimal /tb/axi4/*

add wave -noupdate -divider Axi4Stream
add wave -noupdate -format Logic -Radix Hexadecimal /tb/axi4stream/*

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 50
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {0 ps} {1 ns}
