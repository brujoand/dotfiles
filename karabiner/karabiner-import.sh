#!/bin/sh

cli=/Applications/Karabiner.app/Contents/Library/bin/karabiner

$cli set repeat.wait 33
/bin/echo -n .
$cli set repeat.initial_wait 250
/bin/echo -n .
$cli set remap.optionrcommandr 1
/bin/echo -n .
$cli set remap.controlL2controlL_escape 1
/bin/echo -n .
$cli set remap.commandR2optionR 1
/bin/echo -n .
/bin/echo
