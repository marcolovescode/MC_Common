//+------------------------------------------------------------------+
//|                                                   GenoClient.mq5 |
//|                                                          mazmazz |
//|                                       https://github.com/mazmazz |
//+------------------------------------------------------------------+
#property copyright "mazmazz"
#property link      "https://github.com/mazmazz"
#property version   "1.00"
#property strict

//#define _ApiDev
//#define _ApiHostname "localhost"
//#define _ApiPort 8080

#include "depends/CsvString.mqh"
#include "depends/internetlib.mqh"
#include "MC_Common.mqh"
#include "ApiKey.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SendApiRequest(CsvString &csvOut, string hostname, int port, string dest, string &varKey[], string &varVal[]) {
    MqlNet net;
    tagRequest request;
    
    request.stVerb = "POST";
    request.stObject = StringFormat("/%s", dest);
    request.stHead = "Content-Type: application/x-www-form-urlencoded";
    request.stData = NULL;
    request.toFile = false;
    request.fromFile = false;

    for(int i = 0; i < ArraySize(varKey); i++) {
        request.stData += StringFormat("&%s=%s", varKey[i], varVal[i]);
    }
    
    Common::ArrayPush(request.stHeaderNamesIn, "Mmc-Api-Version");
    Common::ArrayPush(request.stHeaderDataIn, "1");
    Common::ArrayPush(request.stHeaderNamesOut, "Mmc-Api-Success");
    Common::ArrayPush(request.stHeaderDataOut, "");

#ifndef _ApiDev
    Common::ArrayPush(request.stHeaderNamesIn, "Mmc-Api-Request-Key");
    Common::ArrayPush(request.stHeaderDataIn, MakeApiKey(GetApiDatetime(), true));
    Common::ArrayPush(request.stHeaderNamesOut, "Mmc-Api-Response-Key");
    Common::ArrayPush(request.stHeaderDataOut, "");
#endif
    
    if(net.Open(hostname, port, NULL, NULL, INTERNET_SERVICE_HTTP)) {
        net.Request(request);
        if(request.stHeaderDataOut[0] != "true") { return false; } // try again next tick
#ifndef _ApiDev
        if(request.stHeaderDataOut[1] == NULL || !ValidateApiKey(request.stHeaderDataOut[1], false)) { return false; }
#endif
    }
    
    csvOut.reopen(request.stOut, 0);
    return true;
}
