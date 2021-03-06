--// English language translations
-- Letters prefixed with a '%' (ex: %s, %i) are for formatted strings, don't break those
-- '\n' and '\r\n' are used to create a new line, try to keep those in similar spots to preserve spacing

local l = gPhone.createLanguage( "english" )
--local trans = gPhone.getTranslation

-- General
l.title = "The Garry Phone"
l.slide_unlock = "slide to unlock"
l.update_check_fail = "Connection to the gPhone site has failed, please report this on the Workshop page and verify your version!"
l.kick = "[gPhone]: ILLEGAL REQUEST - ERROR: 0x01B4D0%s"
l.feature_deny = "The selected feature has not been implemented yet"
l.error = "Error"

l.settings = "Settings"
l.general = "General"
l.wallpaper = "Wallpaper"
l.homescreen = "Homescreen"
l.about = "About"
l.color = "Color"

-- Homescreen
l.battery_dead = "Your phone has run out of battery and died! Recharging..."
l.battery_okay = "Recharged!"
l.service_provider = "Garry"
l.folder_fallback = "Folder"
l.invalid_folder_name = "Invalid"

-- App base
l.app_error = "[App Error]"
l.app_deny_gm = "This app cannot be used in this gamemode!"
l.app_deny_group = "You are not in the correct group to use this app!"

-- Requests
l.confim = "Confirmation"
l.request = "Request"
l.deny = "Deny"
l.accept = "Accept"
l.no = "No"
l.yes = "Yes"
l.okay = "Okay"

l.accept_fallback = "%s has accepted your request to use %s"
l.phone_accept = "%s has accepted your call"
l.gpong_accept = "%s has accepted your request to play gPong"

l.deny_fallback = "%s has denied your request to use %s"
l.phone_deny = "%s has denied your call"
l.gpong_deny = "%s has denied your request to play gPong"

-- Data transfer
l.transfer_fail_gm = "You cannot wire money in gamemodes that are not DarkRP"
l.transfer_fail_cool = "You must wait %i's before you can transfer more money"
l.transfer_fail_ply = "Unable to complete transaction - invalid recipient"
l.transfer_fail_amount = "Unable to complete transaction - nil amount"
l.transfer_fail_generic = "Unable to complete transaction, sorry"
l.transfer_fail_funs = "Unable to complete transaction - lack of funds" 

l.received_money = "Received $%i from %s!"
l.sent_money = "Wired $%i to %s successfully!"

l.text_cooldown = "You cannot text for %i more seconds!"
l.text_flagged = "To prevent spam, you have been blocked from texting for %i seconds!"

l.being_called = "%s is calling you!"

-- Settings
l.show_unusable_apps = "Show unusable apps"
l.reset_app_pos = "Reset icon positions"
l.archive_cleanup = "Archive cleanup"
l.file_life = "File life (days)"
l.wipe_archive = "Wipe archive"

l.choose_new_wp = "Choose new wallpaper"
l.wp_selector = "Wallpaper selector"
l.dark_status = "Darken status bar"
l.set_lock = "Set lockscreen"
l.set_home = "Set homescreen"
l.reset_homescreen = "Are you sure you want to reset the homescreen icon positions?"

l.no_description = "No description provided"
l.install_u = "Install Update"
l.wipe_archive_confirm = "Are you sure you want to delete all files in the archive? (this cannot be undone)"
l.archive = "Archive"
l.update = "Update"

-- Contacts
l.contacts = "Contacts"
l.search = "Search"
l.back = "Back"
l.number = "Number"

-- Phone
l.mute = "Mute"
l.unmute = "Unmute"
l.keypad = "Keypad"
l.speaker = "Speaker"
l.add = "Add"
l.end_call = "End call"

-- Pong
l.gpong = "gPong"
l.playerbot = "Player v Bot"
l.playerplayer = "Player v Player"
l.playerself = "Player v Self"
l.easy = "Easy"
l.medium = "Intermediate"
l.hard = "Hard"

l.challenge_ply = "Challenge Player!"
l.gpong_self_instructions = " Player 1:\r\n W and S\r\n Player 2:\r\n Up and Down arrow keys" 
l.start = "Start!"
l.resume = "Resume"
l.quit = "Quit"
l.p1_win = "P1 wins!"
l.p2_win = "P2 wins!"

-- Text/Messages
l.messages = "Messages"
l.delete = "Delete"
l.last_year = "Last year"
l.yesterday = "Yesterday"
l.years_ago = "years ago"
l.days_ago = "days ago"
l.send = "Send"
l.new_msg = "New message"
l.to = "To:"

-- Store
l.no_homescreen_space = "You do not have enough homescreen space to add a new app!"
l.app_store = "App Store"
l.no_apps = "No apps"
l.no_apps_phrase = "There are no apps available, sorry :("
l.get = "Get"
l.have = "Have"