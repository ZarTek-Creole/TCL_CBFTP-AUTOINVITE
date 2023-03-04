# CBFTP Invite Bot Script
# This script allows an Eggdrop bot to automatically invite itself to specific channels on CBFTP sites that it cannot join due to +i (invitation) or +k (key) modes.
# Visit:  https://github.com/ZarTek-Creole/TCL_CBFTP-AUTOINVITE
#
# Configuration file: cb_autoinvite.cfg
# You need rename cb_autoinvite.cfg.example to cb_autoinvite.cfg and edit it with your own CBFTP connection information and channel information.

package require http
package require json
package require tls
package require base64

namespace eval ::cbftp_autoinvite {
    variable cb_api
    variable chan_info
    # Load the configuration file
    if { [file exists cb_autoinvite.cfg] } {
        if { [catch { source cb_autoinvite.cfg } err] } {
            putlog "[namespace current] :: Error: Configuration file cb_autoinvite.cfg is not valid."
            return
        }
    } else {
        putlog "[namespace current] :: Error: Configuration file cb_autoinvite not found."
        return
    }

    bind need - "% invite" ::cbftp_autoinvite::invite
    bind need - "% key" ::cbftp_autoinvite::invite

    proc invite { CHANNAME args } {
        variable ignoreBotlist
        if {[lsearch -nocase ${ignoreBotlist} ${::botnick}] != -1} { return }
        putlog "Need $args on $CHANNAME try by [namespace current]"
        # Find the site name associated with the channel
        set site_name [find_site $CHANNAME]
        if { $site_name != "" } {
            # Send an invite to the site
            send_invite $site_name
        } else {
            putlog "[namespace current] :: Error: Invalid channel name or not found $CHANNAME"
        }
    }
    proc find_site { CHANNAME } {
        variable chan_info
        foreach key [array names chan_info] {
            if {[lsearch -nocase $chan_info($key) ${CHANNAME}] != -1} {
                return $key
            }
        }
        return ""
    }
    proc send_invite { SITENAME } {
        variable cb_api
        set BODY        "{\"command\": \"site invite ${::botnick}\", \"sites\": \[\"${SITENAME}\"\]}"
        set response    [Send_api $BODY]
        if {[dict exists $response failures]} {
            putlog "[namespace current] :: Error sending invite: [dict get $response failures]"
        } else {
            putlog "[namespace current] :: Invite sent to site ${SITENAME}"
        }
    }

    proc Send_api { BODY } {
        variable cb_api
        set URL			"https://${cb_api(HOST)}:${cb_api(PORT)}/raw"
        set HEADERS		[list Authorization "Basic [base64::encode :${cb_api(PASSWORD)}]"]
        ::http::register https ${cb_api(PORT)} [list ::tls::socket];
        set t		    [http::geturl	    \
            $URL	                        \
            -headers	$HEADERS	        \
            -query		$BODY		        \
            -method		POST                \
            ];
        set WSDATA		[http::data  $t]
        set WSCODE	    [http::ncode $t]
        set WSSTATUS	[::http::status  $t]
        ::http::cleanup $t
        ::http::unregister https
        if { ${WSDATA} != "" } { set WSDATA	[json::json2dict ${WSDATA}] }
        dict set RESSOURCE http code $WSCODE
        dict set RESSOURCE http status $WSSTATUS
        dict set RESSOURCE successes result NULL
        dict set RESSOURCE failures result NULL
        if { $WSCODE == "200" && [dict exists ${WSDATA} failures] } {
            dict set RESSOURCE failures [dict get ${WSDATA} failures]

            if {[dict exists ${WSDATA} successes] && [dict get ${WSDATA} successes] != ""} {
                dict set RESSOURCE successes {*}[dict get ${WSDATA} successes]
            }
        } elseif { $WSCODE == "200" && [dict exists ${WSDATA} successes] } {
            dict set RESSOURCE successes result ${WSDATA}
        } elseif { $WSCODE != "200" && [dict exists ${WSDATA} failures] } {
            dict set RESSOURCE failures result [dict get ${WSDATA} error]
        } elseif { [dict exists ${WSDATA} error] } {
            dict set RESSOURCE failures result [dict get ${WSDATA} error]
        } elseif { $WSCODE == "200" } {
            dict set RESSOURCE successes result ${WSDATA}
        } elseif { $WSCODE != "200" } {
            if {$WSCODE == 409} {
                dict set RESSOURCE failures result "Conflict : Resource already exists (likely)."
            } elseif {$WSCODE == 201} {
                dict set RESSOURCE successes result "Created : Request processed successfully and document created."
            } elseif {$WSCODE == 204} {
                dict set RESSOURCE successes result "No Content: Request processed successfully but no information to return."
            } elseif {$WSCODE == 400} {
                dict set RESSOURCE failures result "Bad request: The syntax of the request is incorrect."
            } elseif {$WSCODE == 401} {
            } elseif {$WSCODE == 403} {
                dict set RESSOURCE failures result "Forbidden: The server refuses to execute the request."
            } elseif {$WSCODE == 404} {
                dict set RESSOURCE failures result "Not Found : Not Found: The requested resource was not found."
            } elseif {$WSCODE == 405} {
                dict set RESSOURCE failures result "Method Not Allowed: The method used is not allowed."
            } elseif {$WSCODE == 500} {
                dict set RESSOURCE failures result "Internal Server Error."
            } else {
                dict set RESSOURCE failures result "Unknow Error : Unhandled HTTP code."
            }
        }
        return ${RESSOURCE}
    }

    putlog "[namespace current] :: by ZarTek-Creole loaded. ( https://github.com/ZarTek-Creole )"
}
