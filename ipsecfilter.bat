@echo off
:: Define the IPs and Domains to block
:: Empty lists won't be processed, no need to edit the script
:: Cleanup: netsh ipsec static delete policy name=BlockPolicy
setlocal

set "BLOCKED_IPS=192.168.1.1 192.168.1.5 192.168.1.10"
set "BLOCKED_RANGES=192.168.10.0-192.168.10.255"
set "BLOCKED_DOMAINS=DOMAIN1.COM DOMAIN2.COM DOMAIN3.COM"

:: Define the IPSec policy and rule names
set "POLICY_NAME=BlockPolicy"
set "FILTERLIST_NAME=BlockFilterList"
set "FILTERACTION_NAME=BlockFilterAction"
set "RULE_NAME=BlockRule"

:: Create and assign the IPSec policy
netsh ipsec static add policy name=%POLICY_NAME% description=%POLICY_NAME%
netsh ipsec static set policy name=%POLICY_NAME% assign=yes

:: Create the filter action to block traffic
netsh ipsec static add filteraction name=%FILTERACTION_NAME% action=block

:: Check if IP list is not empty, then add IP filters
if not "%BLOCKED_IPS%"=="" (
    for %%I in (%BLOCKED_IPS%) do (
        netsh ipsec static add filter filterlist=%FILTERLIST_NAME% srcaddr=me dstaddr=%%I protocol=tcp description="Block IP %%I"
    )
)

:: Check if IP range list is not empty, then add IP range filters
if not "%BLOCKED_RANGES%"=="" (
    for %%R in (%BLOCKED_RANGES%) do (
        netsh ipsec static add filter filterlist=%FILTERLIST_NAME% srcaddr=me dstaddr=%%R protocol=tcp description="Block IP Range %%R"
    )
)

:: Check if Domain list is not empty, then add Domain filters
if not "%BLOCKED_DOMAINS%"=="" (
    for %%D in (%BLOCKED_DOMAINS%) do (
        netsh ipsec static add filter filterlist=%FILTERLIST_NAME% srcaddr=me dstaddr=%%D protocol=tcp description="Block Domain %%D"
    )
)

:: Add the rule to link the filter list with the block action
netsh ipsec static add rule name=%RULE_NAME% policy=%POLICY_NAME% filterlist=%FILTERLIST_NAME% filteraction=%FILTERACTION_NAME% description="IPSec Block Rule"

endlocal
@echo Script completed successfully.
