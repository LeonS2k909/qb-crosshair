fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'qb-crosshair'
author 'Lyra'
version '1.3.1'
description 'Minimal, theme-aligned crosshair with compact popup selector'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

client_scripts {
    'client.lua'
}

dependencies {
    'qb-core'
}
