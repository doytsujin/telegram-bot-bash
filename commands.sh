#!/bin/bash
# file: commands.sh
# do not edit this file, instead place all your commands in mycommands.sh

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.70-10-gcbdfc7c
#
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# adjust your language setting here, e.g.when run from other user or cron.
# https://github.com/topkecleon/telegram-bot-bash#setting-up-your-environment
export 'LC_ALL=C.UTF-8'
export 'LANG=C.UTF-8'
export 'LANGUAGE=C.UTF-8'

unset IFS
# set -f # if you are paranoid use set -f to disable globbing

# to change the default info message overwrite bashbot_info in mycommands.sh
bashbot_info='This is bashbot, the Telegram bot written entirely in bash.
It features background tasks and interactive chats, and can serve as an interface for CLI programs.
It currently can send, recieve and forward messages, custom keyboards, photos, audio, voice, documents, locations and video files.
'

# to change the default help messages overwrite in mycommands.sh
bashbot_help='*Available commands*:
*• /start*: _Start bot and get this message_.
*• /help*: _Get this message_.
*• /info*: _Get shorter info message about this bot_.
*• /question*: _Start interactive chat_.
*• /cancel*: _Cancel any currently running interactive chats_.
*• /kickme*: _You will be autokicked from the chat_.
*• /leavechat*: _The bot will leave the group with this command _.
Written by Drew (@topkecleon), Daniil Gentili (@danogentili) and KayM(@gnadelwartz).
Get the code in my [GitHub](http://github.com/topkecleon/telegram-bot-bash)
'

if [ "${1}" != "source" ]; then
	# load modules needed for commands.sh only
	# shellcheck source=./modules/aliases.sh
	[ -r "${MODULEDIR:-.}/aliases.sh" ] && source "${MODULEDIR:-.}/aliases.sh"
	# shellcheck source=./modules/background.sh
	[ -r "${MODULEDIR:-.}/background.sh" ] && source "${MODULEDIR:-.}/background.sh"
else
	# defaults to no inline and nonsense home dir
	INLINE="0"
	FILE_REGEX='/home/user/allowed/.*'

	# load modules needed for bashbot.sh also
	# shellcheck source=./modules/background.sh
	[ -r "${MODULEDIR:-.}/inline.sh" ] && source "${MODULEDIR:-.}/inline.sh"

fi

# load mycommands
# shellcheck source=./commands.sh
[ -r "${BASHBOT_ETC:-.}/mycommands.sh" ] && source "${BASHBOT_ETC:-.}/mycommands.sh"  "${1}"


if [ "${1}" != "source" ];then
    if ! tmux ls | grep -v send | grep -q "$copname"; then
		# interactive running?
		[ ! -z "${URLS[*]}" ] && {
			curl -s "${URLS[*]}" -o "$NAME"
			send_file "${CHAT[ID]}" "$NAME" "$CAPTION"
			rm -f "$NAME"
		}
		[ ! -z "${LOCATION[*]}" ] && send_location "${CHAT[ID]}" "${LOCATION[LATITUDE]}" "${LOCATION[LONGITUDE]}"

    fi


    if [ "$INLINE" != "0" ] && [ "${iQUERY[ID]}" != "" ]; then
	if _is_function process_inline; then
	    #######################
	    # Inline query examples
	    # shellcheck disable=SC2128
	    case "${iQUERY}" in
		"photo")
			answer_inline_multi "${iQUERY[ID]}" "
			    $(inline_query_compose "$RANDOM" "photo" "https://avatars0.githubusercontent.com/u/13046303"), 
			    $(inline_query_compose "$RANDOM" "photo" "https://avatars1.githubusercontent.com/u/4593242")
			    "
			;;

		"sticker")
			answer_inline_query "${iQUERY[ID]}" "cached_sticker" "BQADBAAD_QEAAiSFLwABWSYyiuj-g4AC"
			;;
		"gif")
			answer_inline_query "${iQUERY[ID]}" "cached_gif" "BQADBAADIwYAAmwsDAABlIia56QGP0YC"
			;;
		"web")
			answer_inline_query "${iQUERY[ID]}" "article" "GitHub" "http://github.com/topkecleon/telegram-bot-bash"
			;;
		################################################
		# GLOBAL commands start here, edit messages only
		'info')
			  answer_inline_query "${iQUERY[ID]}" "article" "${bashbot_info}"
			;;
		*)	# forward iinline query to optional dispatcher
			_is_function myinlines && myinlines
	    esac
	fi
    else
	
	case "${MESSAGE}" in
		################################################
		# GLOBAL commands start here, edit messages only
		'/info'*)
			_markdown_message "${bashbot_info}"
			;;
		'/start'*)
			send_action "${CHAT[ID]}" "typing"
			_is_botadmin && _markdown_message "You are *BOTADMIN*."
			if _is_botadmin || _is_allowed "start" ; then
				_markdown_message "${bashbot_help}"
			else
				_message "You are not allowed to start Bot."
			fi
			;;
			
		'/help'*)
			_markdown_message "${bashbot_help}"
			;;
		'/leavechat'*) # bot leave chat if user is admin in chat
			if _is_admin ; then 
				_markdown_message "*LEAVING CHAT...*"
   				_leave
			fi
     			;;
     			
     		'/kickme'*)
     			_kick_user "${USER[ID]}"
     			_unban_user "${USER[ID]}"
     			;;
     			
		'/cancel'*)
			checkproc
			if [ "$res" -eq 0 ] ; then killproc && _message "Command canceled.";else _message "No command is currently running.";fi
			;;
		*)	# forward messages to optional dispatcher
			_is_function startproc && if tmux ls | grep -v send | grep -q "$copname"; then inproc; fi # interactive running
			_is_function mycommands && mycommands
			;;
	esac
    fi
fi
