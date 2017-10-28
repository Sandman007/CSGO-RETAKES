<?php

header('Content-Type: text/plain');

define('STEAM_KEY', '');
define('CACHE_TIME', 1800);
define('CACHE_PREFIX', 'vacbans_');

$filterOpts = array(
    'options' => array(
        'regexp' => '/^\d{17}$/'
    )
);
$steamId = filter_input(INPUT_GET, 's', FILTER_VALIDATE_REGEXP, $filterOpts);
if($steamId) {
    $mc = new Memcached();
    $mc->addServer('127.0.0.1', 11211);
    $cached = $mc->get(CACHE_PREFIX . $steamId);
    if($cached) {
        echo $cached;
    } else {
        $output = fetchFromSteam($steamId);
        if($output) {
            $mc->set(CACHE_PREFIX . $steamId, $output, CACHE_TIME);
            echo $output;
        } else {
            echo 'null';
        }
    }
} else {
    header($_SERVER['SERVER_PROTOCOL'] . ' 400 Bad Request');
    echo 'null';
}

function fetchFromSteam($steamId) {
    $url = sprintf('http://api.steampowered.com/ISteamUser/GetPlayerBans/v1/?key=%s&steamids=%d', STEAM_KEY, $steamId);
    $result = file_get_contents($url);
    if($result) {
        $players = json_decode($result, true);
        if(is_array($players) && array_key_exists('players', $players) && !empty($players['players'])) {
            $player = $players['players'][0];
            $output = array(
                $player['NumberOfVACBans'],
                $player['DaysSinceLastBan'],
                $player['NumberOfGameBans'],
                (int)$player['CommunityBanned'],
                econValueAsInt($player['EconomyBan'])
            );
            return implode(',', $output);
        }
        header($_SERVER['SERVER_PROTOCOL'] . ' 404 Not Found');
        return false;
   }
    header($_SERVER['SERVER_PROTOCOL'] . ' 503 Service Unavailable');
    return false;
}

function econValueAsInt($value) {
    switch($value) {
        case 'probation':
            return 1;
        case 'banned':
            return 2;
    }
    return 0;
}
