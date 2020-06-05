# onset-conquest

### Please note that onset-conquest is in BETA

#### Informations
* In this gamemode you need to capture the flags. The first team at 0 points will loose
* Maps located in server/maps.lua

#### Models
* [Sherman](https://sketchfab.com/3d-models/sherman-00ec6397c1634430a828c22101abfad5) by [Daniel Campos](https://sketchfab.com/danielpinhocampos)
* [Panzer IV](https://sketchfab.com/3d-models/panzer-iv-medium-tank-toshueyi-14c74d148326448c8edb5fee81be3894) by [Shue-Yi To](https://sketchfab.com/Toshueyi)
* [Sandbags](https://sketchfab.com/3d-models/sandbag-wall-04-a5ea125e9d534b54a3185f349da6aabd) by [Pieter Snauwaert](https://sketchfab.com/PieterSnauwaert)
* flag models and flag zones models by Ayanokōji#0413

#### You can configure the gamemode in config.lua
* dev : activate some commands for testing (don't use it if your server is public)
* weapon_id : it's the primary weapon used by players
* weapon_id2 : it's the secondary weapon used by players
* startpoints : at how many points teams will start (without extra)
* startpoints_added_per_player : how many points will be added in teams points for each player in the game
* veh_respawn_time_ms : how often vehicles respawn (in ms)
* distance2d_flag_capture : at how many distance of the flag a player will capture it
* max_z : max value on z axis (to avoid helicopters being too high or collisions bugs)
* invincible_time_respawn_ms : how many time a player will be invincible when he respawn (in ms)
* clothes_team1 : clothes preset id used by team 1
* clothes_team2 : clothes preset id used by team 2
* time_win_label_ms : time win label will be shown (in ms)
* kill_indicator_show_time_ms : time a kill indicator will be shown (in ms)



