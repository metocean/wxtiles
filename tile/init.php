<?php
$wxserver="http://wx.wxtiles.com";
$satserver="http://sat.wxtiles.com";
header('Content-Type: application/json');
$satout=file_get_contents("$satserver/tile/init");
$wxout=file_get_contents("$wxserver/tile/init");
$satout='{"server":"'.$satserver.'",'.ltrim($satout,'{');
$wxout='{"server":"'.$wxserver.'",'.ltrim($wxout,'{');
print $_GET['callback']."([$satout,$wxout])";
exit(0);
?>
