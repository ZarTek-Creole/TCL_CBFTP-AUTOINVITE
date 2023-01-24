# CBFTP Invite Bot Script
# This script allows an Eggdrop bot to automatically invite itself to specific channels on CBFTP sites that it cannot join due to +i (invitation) or +k (key) modes.
# Visit:  https://github.com/ZarTek-Creole/TCL_CBFTP-AUTOINVITE

package require http
package require json
package require tls
package require base64

namespace eval ::cbftp_autoinvite {
    variable cb_api
    variable chan_info

    # Initialize the api_ variable with the connection information
    # User should update these values with their own CBFTP connection information
    array set cb_api {
        "HOST"      "localhost"
        "PORT"      "55400"
        "PASSWORD"  "bestpass"
    }

    # Initialize the chan_info variable with the channel information
    # User should update this array with their own channel information
    array set chan_info {
        "Your_CB_sitename"           {#chan1 #chan2}
    }

    bind need - "% invite" ::cbftp_autoinvite::invite
    bind need - "% key" ::cbftp_autoinvite::invite

    proc invite { CHANNAME args } {
        putlog "Need $args on $CHANNAME try by [namespace current]"
        # Find the site name associated with the channel
        set site_name [find_site $CHANNAME]
        if { $site_name != "" } {
            # Send an invite to the site
            send_invite $site_name
        } else {
            putlog "[namespace current] :: Error: Invalid channel name or not found $CHANNAM"
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
                dict set RESSOURCE failures result "Conflict : Ressource déja existante (surement)"
            } elseif {$WSCODE == 201} {
                dict set RESSOURCE successes result "Created : Requête traitée avec succès et création d’un document."
            } elseif {$WSCODE == 204} {
                dict set RESSOURCE successes result "No Content : Requête traitée avec succès mais pas d’information à renvoyer."
            } elseif {$WSCODE == 400} {
                dict set RESSOURCE failures result "Bad request : La syntaxe de la requête est erronée."
            } elseif {$WSCODE == 401} {
            } elseif {$WSCODE == 403} {
                dict set RESSOURCE failures result "Forbidden : Le serveur refuse d’exécuter la requête."
            } elseif {$WSCODE == 404} {
                dict set RESSOURCE failures result "Not Found : La ressource demandée n’a pas été trouvée."
            } elseif {$WSCODE == 405} {
                dict set RESSOURCE failures result "Method Not Allowed : La méthode utilisée n’est pas autorisée."
            } elseif {$WSCODE == 500} {
                dict set RESSOURCE failures result "Internal Server Error : Erreur interne du serveur."
            } else {
                dict set RESSOURCE failures result "Unknow Error : Code HTTP non géré."
            }
        }
        return ${RESSOURCE}
    }

    putlog "[namespace current] :: by ZarTek-Creole loaded. ( https://github.com/ZarTek-Creole )"
}