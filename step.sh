#!/usr/bin/env bash
# fail if any commands fails
set -e
# debug log
if [ "${show_debug_logs}" == "yes" ]; then
  set -x
fi

function getToken()
{
  printf "\n\nObtaining a Token\n"  
  
  curl --silent -X POST \
    https://connect-api.cloud.huawei.com/api/oauth2/v1/token \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    -d '{
      "grant_type": "client_credentials",
      "client_id": "'${huawei_client_id}'",
      "client_secret": "'${huawei_client_secret}'"
  }' > token.json

  printf "\nObtaining a Token - DONE\n"
} 

function getDownloadAndInstallationReport()
{
  ACCESS_TOKEN=`jq -r '.access_token' token.json` 

  printf "\nGetting Download&Installation Report\n"
  curl --silent -X GET \
  'https://connect-api.cloud.huawei.com/api/report/distribution-operation-quality/v1/appDownloadExport/'"${huawei_app_id}"'?language='"${download_installation_language}"'&startTime='"${download_installation_start_time}"'&endTime='"${download_installation_end_time}"'&exportType='"${download_installation_export_type}" \
  -H 'Authorization: Bearer '"${ACCESS_TOKEN}"'' \
  -H 'client_id: '"${huawei_client_id}"'' > DownloadAndInstallationReport.json
  REPORT_LINK=`jq -r '.fileURL' DownloadAndInstallationReport.json` 
  envman add --key "DOWNLOAD_INSTALLATION_REPORT_LINK" --value "$REPORT_LINK"
  printf "Log URL obtained (\${DOWNLOAD_INSTALLATION_REPORT_LINK}=${REPORT_LINK})"

  printf "\nGetting Download&Installation Report - DONE\n"
}

getToken  

getDownloadAndInstallationReport 

exit 0
