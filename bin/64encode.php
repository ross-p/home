#!/usr/bin/php
<?php

$ARGV =& $_SERVER['argv'];

if( ! isset($ARGV[1]) )
  die( "Usage: {$ARGV[0]} raw_data\n" );

$enc = urlencode( preg_replace( "/==$/", '', base64_encode($ARGV[1]) ) );

echo "encoded: {$enc}\n"
.    "decoded: {$ARGV[1]}\n"
;
