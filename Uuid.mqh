#property copyright "mazmazz"
#property link      "https://github.com/mazmazz"
#property version   "1.00"
#property strict

#include "ApiRequest.mqh"
#include "depends/CsvString.mqh"

#ifndef _ApiHostname
#define _ApiHostname "localhost"
#define _ApiPort 8080
#endif

CsvString UuidPool(NULL, 0);
// Net-generated UUID server does not exist right now, so dummy it out.
// Just generate UUID's locally.
bool IgnorePool = true;

string GetUuid() {
    if(IgnorePool || (UuidPool.isLineEnding() && !GetUuidPoolNet(UuidPool))) {
        return GetUuidNative();
    } else {
        return UuidPool.readString();
    }
}

bool GetUuidPoolNet(CsvString &pool, int type=4, int count=50) {
    string varKey[2], varVal[2];
    varKey[0] = "type"; varVal[0] = IntegerToString(type);
    varKey[1] = "count"; varVal[1] = IntegerToString(count);

    if(SendApiRequest(
        pool
        , _ApiHostname, _ApiPort, "uuid"
        , varKey, varVal
    )) {
        return true;
    } else {
        UuidPool.reopen(NULL, 0);
        IgnorePool = true;
        Print("Creating UUID natively; restart EA to enable net-generated UUID.");
        return false;
    }
}

// https://github.com/femtotrader/rabbit4mt4/blob/master/emit/MQL4/Include/uuid.mqh
//http://en.wikipedia.org/wiki/Universally_unique_identifier
//RFC 4122
//  A Universally Unique IDentifier (UUID) URN Namespace
//  http://tools.ietf.org/html/rfc4122.html

//+------------------------------------------------------------------+
//|UUID Version 4 (random)                                           |
//|Version 4 UUIDs use a scheme relying only on random numbers.      |
//|This algorithm sets the version number (4 bits) as well as two    |
//|reserved bits. All other bits (the remaining 122 bits) are set    |
//|using a random or pseudorandom data source. Version 4 UUIDs have  |
//|the form xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx                     |
//|where x is any hexadecimal digit and y is one of 8, 9, A, or B    |
//|(e.g., f47ac10b-58cc-4372-a567-0e02b2c3d479).                                                               |
//+------------------------------------------------------------------+
string GetUuidNative()
  {
   string alphabet_x="0123456789abcdef";
   string alphabet_y="89ab";
   string id="xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"; // 36 char = (8-4-4-4-12)
   ushort character = 0;
   for(int i=0; i<36; i++)
     {
      if(i==8 || i==13 || i==18 || i==23)
        {
         character='-';
        }
      else if(i==14)
        {
         character='4';
        }
      else if(i==19)
        {
         character = (ushort) MathRand() % 4;
         character = StringGetCharacter(alphabet_y, character);
        }
      else
        {
         character = (ushort) MathRand() % 16;
         character = StringGetCharacter(alphabet_x, character);
        }
      StringSetCharacter(id,i,character);
     }
   return id;
  }