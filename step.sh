#!/usr/bin/env bash
# fail if any commands fails
set -e
# debug log
if [ "${show_debug_logs}" == "yes" ]; then
  set -x
fi

function getToken()
{
  TOKEN_URL=$( getTokenUrl ) 

  printf "\n\nObtaining a Token\n"  
  
  curl --silent -X POST \
    "${TOKEN_URL}" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    -d '{
      "grant_type": "client_credentials",
      "client_id": "'${huawei_client_id}'",
      "client_secret": "'${huawei_client_secret}'"
  }' > token.json

  printf "\nObtaining a Token - DONE\n"
} 

function getTokenUrl()
{
   if [ "${paid_download_domain}" == "Russia" ] ;then
        URL="https://connect-api-drru.cloud.huawei.com/api/oauth2/v1/token"
    elif [ "${paid_download_domain}" == "Europe" ] ;then 
        URL="https://connect-api-dre.cloud.huawei.com/api/oauth2/v1/token"
    elif [ "${paid_download_domain}" == "Asia Pacific" ] ;then 
        URL="https://connect-api-dra.cloud.huawei.com/api/oauth2/v1/token"
    else  
        URL="https://connect-api.cloud.huawei.com/api/oauth2/v1/token"
    fi 
    echo $URL
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

function getInAppPaymentReport()
{
  ACCESS_TOKEN=`jq -r '.access_token' token.json` 

  printf "\nGetting In-App Payment Report\n"

  curl --silent -X GET \
  'https://connect-api.cloud.huawei.com/api/report/distribution-operation-quality/v1/IAPExport/'"${huawei_app_id}"'?language='"${in_app_payment_language}"'&startTime='"${in_app_payment_start_time}"'&endTime='"${in_app_payment_end_time}"'&exportType='"${in_app_payment_export_type}"'&currency='"${in_app_payment_currency}" \
  -H 'Authorization: Bearer '"${ACCESS_TOKEN}"'' \
  -H 'client_id: '"${huawei_client_id}"'' > InAppPaymentReport.json
  REPORT_LINK=`jq -r '.fileURL' InAppPaymentReport.json` 
  envman add --key "IN_APP_PAYMENT_REPORT_REPORT_LINK" --value "$REPORT_LINK"
  printf "Log URL obtained (\${IN_APP_PAYMENT_REPORT_REPORT_LINK}=${REPORT_LINK})"

  printf "\nGetting In-App Payment Report - DONE\n"
}

function getPaidDownloadReport()
{
  ACCESS_TOKEN=`jq -r '.access_token' token.json` 
  DOMAIN=$( getDomainFromSelection ) 

  printf "\nGetting Paid Download Report\n"

  curl --silent -X GET \
  'https://'"${DOMAIN}"'/api/report/distribution-operation-quality/v1/orderDetailExport/'"${huawei_app_id}"'?language='"${paid_download_language}"'&startTime='"${paid_download_start_time}"'&endTime='"${paid_download_end_time}"'&exportType='"${paid_download_export_type}"'&filterCondition='"countryId"'&filterConditionValue='"${paid_download_country_id}" \
  -H 'Authorization: Bearer '"${ACCESS_TOKEN}"'' \
  -H 'client_id: '"${huawei_client_id}"'' > PaidDownloadReport.json
  REPORT_LINK=`jq -r '.fileURL' PaidDownloadReport.json` 
  envman add --key "PAID_DOWNLOAD_REPORT_LINK" --value "$REPORT_LINK"
  printf "Log URL obtained (\${PAID_DOWNLOAD_REPORT_LINK}=${REPORT_LINK})"

  printf "\nGetting Paid Download Report - DONE\n"
}

function getInstallationFailureDataReport()
{
  ACCESS_TOKEN=`jq -r '.access_token' token.json` 

  printf "\nGetting Installation Failure Data Report\n"

  curl --silent -X GET \
  'https://connect-api.cloud.huawei.com/api/report/distribution-operation-quality/v1/appDownloadFailExport/'"${huawei_app_id}"'?language='"${installation_failure_data_language}"'&startTime='"${installation_failure_data_start_time}"'&endTime='"${installation_failure_data_end_time}" \
  -H 'Authorization: Bearer '"${ACCESS_TOKEN}"'' \
  -H 'client_id: '"${huawei_client_id}"'' > InstallationFailureDataReport.json
  REPORT_LINK=`jq -r '.fileURL' InstallationFailureDataReport.json` 
  envman add --key "INSTALLATION_FAILURE_DATA_REPORT_LINK" --value "$REPORT_LINK"
  printf "Log URL obtained (\${INSTALLATION_FAILURE_DATA_REPORT_LINK}=${REPORT_LINK})"

  printf "\nGetting Installation Failure Data Report - DONE\n"
}

function getDomainFromSelection()
{ 
    if [ "${paid_download_domain}" == "China" ] ;then
        DOMAIN="connect-api.cloud.huawei.com"
    elif [ "${paid_download_domain}" == "Europe" ] ;then 
        DOMAIN="connect-api-dre.cloud.huawei.com"
    elif [ "${paid_download_domain}" == "Asia Pacific" ] ;then 
        DOMAIN="connect-api-dra.cloud.huawei.com"
    else  
        DOMAIN="connect-api-drru.cloud.huawei.com"
    fi 
    echo $DOMAIN
}

getToken  

#getDownloadAndInstallationReport 

#getInAppPaymentReport

getPaidDownloadReport

#getInstallationFailureDataReport

exit 0
