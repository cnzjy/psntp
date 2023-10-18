<?php
date_default_timezone_set('UTC');

// 获取当前时间的毫秒数
function getMilliseconds() {
    $mt = explode(' ', microtime());
    return (int)round($mt[0] * 1000);
}

// 获取当前时间的年月日时分秒毫秒格式
function getCurrentTime() {
    $milliseconds = getMilliseconds();
    $date = date('Y-m-d H:i:s', time());
    return $date . '.' . $milliseconds;
}

// 输出当前时间
echo getCurrentTime();
?>