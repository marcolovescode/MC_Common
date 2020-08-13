//+------------------------------------------------------------------+
//|															 				InetHttp |
//|                                    Copyright © 2010, FXmaster.de |
//|                                						  www.FXmaster.de |
//|     programming & support - Alexey Sergeev (profy.mql@gmail.com) |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, FXmaster.de"
#property link      "www.FXmaster.de"
#property version		"1.00"
#property description  "WinHttp & WinInet API"
#property library

#define FALSE 0

#define HINTERNET int
#define BOOL int
#define INTERNET_PORT int
#define LPINTERNET_BUFFERS int
#define DWORD int
#define DWORD_PTR int
#define LPDWORD int&
#define LPVOID uchar& 
#define LPSTR string
#define LPCWSTR	string&
#define LPCTSTR string&
#define LPTSTR string&
//LPCTSTR *		int
//LPVOID			uchar& +_[]

#import	"Kernel32.dll"
	DWORD GetLastError(int);
#import

#import "wininet.dll"
	DWORD InternetAttemptConnect(DWORD dwReserved);
	HINTERNET InternetOpenW(LPCTSTR lpszAgent, DWORD dwAccessType, LPCTSTR lpszProxyName, LPCTSTR lpszProxyBypass, DWORD dwFlags);
	HINTERNET InternetConnectW(HINTERNET hInternet, LPCTSTR lpszServerName, INTERNET_PORT nServerPort, LPCTSTR lpszUsername, LPCTSTR lpszPassword, DWORD dwService, DWORD dwFlags, DWORD_PTR dwContext);
	HINTERNET HttpOpenRequestW(HINTERNET hConnect, LPCTSTR lpszVerb, LPCTSTR lpszObjectName, LPCTSTR lpszVersion, LPCTSTR lpszReferer, int /*LPCTSTR* */ lplpszAcceptTypes, uint/*DWORD*/ dwFlags, DWORD_PTR dwContext);
	BOOL HttpAddRequestHeadersW(HINTERNET hRequest, LPCTSTR lpszHeaders, DWORD dwHeadersLength, DWORD dwModifiers);
	BOOL HttpSendRequestW(HINTERNET hRequest, LPCTSTR lpszHeaders, DWORD dwHeadersLength, LPVOID lpOptional[], DWORD dwOptionalLength);
	BOOL HttpQueryInfoW(HINTERNET hRequest, DWORD dwInfoLevel, LPVOID lpvBuffer[], LPDWORD lpdwBufferLength, LPDWORD lpdwIndex);
	HINTERNET InternetOpenUrlW(HINTERNET hInternet, LPCTSTR lpszUrl, LPCTSTR lpszHeaders, DWORD dwHeadersLength, uint/*DWORD*/ dwFlags, DWORD_PTR dwContext);
	BOOL InternetReadFile(HINTERNET hFile, LPVOID lpBuffer[], DWORD dwNumberOfBytesToRead, LPDWORD lpdwNumberOfBytesRead);
	BOOL InternetCloseHandle(HINTERNET hInternet);
	BOOL InternetSetOptionW(HINTERNET hInternet, DWORD dwOption, LPDWORD lpBuffer, DWORD dwBufferLength);
	BOOL InternetQueryOptionW(HINTERNET hInternet, DWORD dwOption, LPDWORD lpBuffer, LPDWORD lpdwBufferLength);
//	BOOL InternetSetCookieW(LPCTSTR lpszUrl, LPCTSTR lpszCookieName, LPCTSTR lpszCookieData);
	BOOL InternetGetCookieW(LPCTSTR lpszUrl, LPCTSTR lpszCookieName, LPVOID lpszCookieData[], LPDWORD lpdwSize);
#import

#define OPEN_TYPE_PRECONFIG		0   // use default configuration
#define INTERNET_SERVICE_FTP						1 // Ftp service
#define INTERNET_SERVICE_HTTP						3	// Http service 
#define HTTP_QUERY_CONTENT_LENGTH 			5
#define HTTP_QUERY_CUSTOM 65535
#define HTTP_QUERY_RAW_HEADERS 21
#define HTTP_QUERY_RAW_HEADERS_CRLF 22

#define ERROR_INSUFFICIENT_BUFFER 122
#define ERROR_HTTP_HEADER_NOT_FOUND 12150

#define HTTP_ADDREQ_INDEX_MASK 0x0000FFFF

#define HTTP_ADDREQ_FLAGS_MASK 0xFFFF0000

#define HTTP_ADDREQ_FLAG_ADD_IF_NEW 0x10000000

#define HTTP_ADDREQ_FLAG_ADD 0x20000000

#define HTTP_ADDREQ_FLAG_COALESCE_WITH_COMMA 0x40000000

#define HTTP_ADDREQ_FLAG_COALESCE_WITH_SEMICOLON 0x01000000

#define HTTP_ADDREQ_FLAG_COALESCE HTTP_ADDREQ_FLAG_COALESCE_WITH_COMMA

#define HTTP_ADDREQ_FLAG_REPLACE 0x80000000

#define INTERNET_FLAG_PRAGMA_NOCACHE						0x00000100  // no caching of page
#define INTERNET_FLAG_KEEP_CONNECTION						0x00400000  // keep connection
#define INTERNET_FLAG_SECURE            				0x00800000
#define INTERNET_FLAG_RELOAD										0x80000000  // get page from server when calling it
#define INTERNET_OPTION_SECURITY_FLAGS    	     31

#define ERROR_INTERNET_INVALID_CA								12045
#define INTERNET_FLAG_IGNORE_CERT_DATE_INVALID  0x00002000
#define INTERNET_FLAG_IGNORE_CERT_CN_INVALID    0x00001000
#define SECURITY_FLAG_IGNORE_CERT_CN_INVALID    INTERNET_FLAG_IGNORE_CERT_CN_INVALID
#define SECURITY_FLAG_IGNORE_CERT_DATE_INVALID  INTERNET_FLAG_IGNORE_CERT_DATE_INVALID
#define SECURITY_FLAG_IGNORE_UNKNOWN_CA         0x00000100
#define SECURITY_FLAG_IGNORE_WRONG_USAGE        0x00000200

//------------------------------------------------------------------ struct tagRequest
struct tagRequest
{
	string stVerb; // method of the GET/POST request
	string stObject; // path to the page "/get.php?a=1" or "/index.htm"
	string stHead; // request header, 
								// "Content-Type: multipart/form-data; boundary=1BEF0A57BE110FD467A\r\n"
								// or "Content-Type: application/x-www-form-urlencoded"
	string stData; // additional string of information
	bool fromFile; // if =true, then stData is the name of the data file
	string stOut; // field for receiving the answer
	bool toFile; // if =true, then stOut is the name of file for receiving the answer
	string stHeaderNamesIn[]; // specify custom headers to send
	string stHeaderDataIn[]; // specify custom header data to send
	string stHeaderNamesOut[]; // specify custom headers to receive
	string stHeaderDataOut[]; // specify custom header data to receive
	void Init(string aVerb, string aObject, string aHead, string aData, bool from, string aOut, bool to);
};
//------------------------------------------------------------------ class MqlNet
void tagRequest::Init(string aVerb, string aObject, string aHead, string aData, bool from, string aOut, bool to)
{
	stVerb=aVerb; // method of the GET/POST request
	stObject=aObject; // path to the page "/get.php?a=1" or "/index.htm"
	stHead=aHead; // request header, "Content-Type: application/x-www-form-urlencoded"
	stData=aData; // additional string of information
	fromFile=from; // if =true, then stData is the name of the data file
	stOut=aOut; // field for receiving the answer
	toFile=to; // if =true, then stOut is the name of file for receiving the answer
}
//------------------------------------------------------------------ class MqlNet
class MqlNet
{
public:
	string Host; // host name
	int Port; // port
	string User; // user name
	string Pass; // user password
	int Service; // service type 
	// obtained parameters
	int hSession; // session descriptor
	int hConnect; // connection descriptor
public:
	MqlNet(); // class constructor
	~MqlNet(); // destructor
	bool Open(string aHost, int aPort, string aUser, string aPass, int aService); // create a session and open a connection
	void Close(); // close the session and the connection
	bool Request(tagRequest &req); // send the request
	bool OpenURL(string aURL, string &Out, bool toFile = false, string headers = NULL); // just read the page to to a file or variable
	void ReadPage(int hRequest, string &Out, bool toFile = false); // read the page
	void ReadHeaders(int hRequest, string &headerNames[], string &headerData[]);
	long GetContentSize(int hURL); //get information about the size of downloaded page
	int FileToArray(string FileName, uchar& data[]); // copy the file to the array for sending
	string StringToBase64(string data);
	string Base64ToString(string encodedData);
	string UrlEncode(string source, bool isForm = false);
	string UrlDecode(string source);
	string HexCharToString(char firstHexDigit, char secondHexDigit);
	void StringToCharArrayW(const string text_string, uchar &char_array[], int start_pos = 0, int count = WHOLE_ARRAY, uint codepage = CP_ACP);
	string CharArrayToStringW(const uchar &char_array[], int start_pos = 0, int count = WHOLE_ARRAY, uint codepage = CP_ACP);
	bool DllsAllowed();
};

//------------------------------------------------------------------ MqlNet
void MqlNet::MqlNet()
{
	hSession=-1; hConnect=-1; Host=""; User=""; Pass=""; Service=-1; // zeroize the parameters
}
//------------------------------------------------------------------ ~MqlNet
void MqlNet::~MqlNet()
{
	Close(); // close all descriptors 
}
//------------------------------------------------------------------ Open
bool MqlNet::Open(string aHost, int aPort, string aUser, string aPass, int aService)
{
    // todo: Timeout? Likely not possible, SetInternetOption might change system settings
    // https://stackoverflow.com/a/14986960

	if (aHost=="") { Print("-Host not specified"); return(false); }
	if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED)) { Print("-DLL not allowed"); return(false); } // checking whether DLLs are allowed in the terminal
	if(!DllsAllowed()) { Print("-DLL not allowed"); return(false); } // checking whether DLLs are allowed in the terminal
	if (hSession>0 || hConnect>0) Close(); // close if a session was determined 
	Print("+Open Inet..."); // print a message about the attempt of opening in the journal
	if (InternetAttemptConnect(0)!=0) { Print("-Err AttemptConnect"); return(false); } // exit if the attempt to check the current Internet connection failed
	string UserAgent="Mozilla"; string nill="";
	hSession=InternetOpenW(UserAgent, OPEN_TYPE_PRECONFIG, nill, nill, 0); // open session
	if (hSession<=0) { Print("-Err create Session"); Close(); return(false); } // exit if the attempt to open the session failed
	hConnect=InternetConnectW(hSession, aHost, aPort, aUser, aPass, aService, 0, 0); 
	if (hConnect<=0) { Print("-Err create Connect"); Close(); return(false); }
	Host=aHost; Port=aPort; User=aUser; Pass=aPass; Service=aService;
	return(true); // otherwise all the checks are successfully finished
}
//------------------------------------------------------------------ Close
void MqlNet::Close()
{
	if (hSession>0) { InternetCloseHandle(hSession); hSession=-1; Print("-Close Session..."); }
	if (hConnect>0) { InternetCloseHandle(hConnect); hConnect=-1; Print("-Close Connect..."); }
}
//------------------------------------------------------------------ Request
bool MqlNet::Request(tagRequest &req)
{
	if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED)) { Print("-DLL not allowed"); return(false); } // checking whether DLLs are allowed in the terminal
	if(!DllsAllowed()) { Print("-DLL not allowed"); return(false); } // checking whether DLLs are allowed in the terminal
	if (req.toFile && req.stOut=="") { Print("-File not specified "); return(false); }
	uchar data[]; int hRequest = 0, hSend = 0; 
	string Vers="HTTP/1.1"; string nill="";
	if (req.fromFile) { if (FileToArray(req.stData, data)<0) { Print("-Err reading file "+req.stData); return(false); } }// reading file to the array
	else StringToCharArray(req.stData, data);
	if(data[ArraySize(data)-1] == 0) { ArrayResize(data, ArraySize(data)-1); } // strip terminating null char

	if (hSession<=0 || hConnect<=0) { Close(); if (!Open(Host, Port, User, Pass, Service)) { Print("-Err Connect"); Close(); return(false); } }
	// creating descriptor of the request
	uchar nullChar = 0;
	hRequest=HttpOpenRequestW(hConnect, req.stVerb, req.stObject, Vers, nill, NULL, INTERNET_FLAG_KEEP_CONNECTION|INTERNET_FLAG_RELOAD|INTERNET_FLAG_PRAGMA_NOCACHE, 0); 
	if (hRequest<=0) { Print("-Err OpenRequest"); InternetCloseHandle(hConnect); return(false); }

    // add custom headers
    int headersInSize = ArraySize(req.stHeaderNamesIn); string headersIn = "";
    for(int i = 0; i < headersInSize; i++) {
        headersIn += req.stHeaderNamesIn[i] + ": " + req.stHeaderDataIn[i] + "\r\n";
    }
    int headersInDataSize = StringLen(headersIn);
    if(headersInDataSize > 0) {
        int modifiers = HTTP_ADDREQ_FLAG_ADD_IF_NEW | HTTP_ADDREQ_FLAG_REPLACE;
        BOOL headerResult = HttpAddRequestHeadersW(hRequest, headersIn, headersInDataSize, modifiers);
    }

	// sending the request
	int n=0;
	while (n<3)
	{
		n++;
		hSend=HttpSendRequestW(hRequest, req.stHead, StringLen(req.stHead), data, ArraySize(data)); // file is sent
		if (hSend<=0) 
		{ 	
			int err=0; err=GetLastError(err); Print("-Err SendRequest= ", err); 
			if (err!=ERROR_INTERNET_INVALID_CA)
			{
				int dwFlags;
				int dwBuffLen = sizeof(dwFlags);
				InternetQueryOptionW(hRequest, INTERNET_OPTION_SECURITY_FLAGS, dwFlags, dwBuffLen);
				dwFlags |= SECURITY_FLAG_IGNORE_UNKNOWN_CA;
				int rez=InternetSetOptionW(hRequest, INTERNET_OPTION_SECURITY_FLAGS, dwFlags, sizeof (dwFlags));
				if (!rez) { Print("-Err InternetSetOptionW= ", GetLastError(err)); break; }
			}
			else break;
		} 
		else break;
	}
	if (hSend>0) {
	    if(ArraySize(req.stHeaderNamesOut) > 0) {
	        ReadHeaders(hRequest, req.stHeaderNamesOut, req.stHeaderDataOut); 
	    }
	    ReadPage(hRequest, req.stOut, req.toFile); // read the page
	}
	InternetCloseHandle(hRequest); InternetCloseHandle(hSend); // close all handles
	if (hSend<=0) Close();
	return(true);
}
//------------------------------------------------------------------ OpenURL
bool MqlNet::OpenURL(string aURL, string &Out, bool toFile = false, string headers = NULL)
{
	if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED)) { Print("-DLL not allowed"); return(false); } // checking whether DLLs are allowed in the terminal
	if(!DllsAllowed()) { Print("-DLL not allowed"); return(false); } // checking whether DLLs are allowed in the terminal
	string nill="";
	if (hSession<=0 || hConnect<=0) { Close(); if (!Open(Host, Port, User, Pass, Service)) { Print("-Err Connect"); Close(); return(false); } }
	int hURL=InternetOpenUrlW(hSession, aURL, nill, 0, INTERNET_FLAG_RELOAD|INTERNET_FLAG_PRAGMA_NOCACHE, 0); 
	if(hURL<=0) { Print("-Err OpenUrl"); return(false); }
	ReadPage(hURL, Out, toFile); // read in Out
	InternetCloseHandle(hURL); // close 
	return(true);
}
//------------------------------------------------------------------ ReadPage
void MqlNet::ReadPage(int hRequest, string &Out, bool toFile = false)
{
	if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED)) { Print("-DLL not allowed"); return; } // checking whether DLLs are allowed in the terminal
	if(!DllsAllowed()) { Print("-DLL not allowed"); return; } // checking whether DLLs are allowed in the terminal
	// read the page 
	uchar ch[100]; string toStr=""; int dwBytes, h=-1;
	if (toFile) h=FileOpen(Out, FILE_ANSI|FILE_BIN|FILE_WRITE);
	while(InternetReadFile(hRequest, ch, 100, dwBytes)) 
	{
		if (dwBytes<=0) break; toStr=toStr+CharArrayToString(ch, 0, dwBytes);
		if (toFile) for (int i=0; i<dwBytes; i++) FileWriteInteger(h, ch[i], CHAR_VALUE);
	}
	if (toFile) { FileFlush(h); FileClose(h); }
	else Out=toStr;
}
//------------------------------------------------------------------ ReadHeaders
void MqlNet::ReadHeaders(int hRequest, string &headerNames[], string &headerData[])
{
	if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED)) { Print("-DLL not allowed"); return; } // checking whether DLLs are allowed in the terminal
	if(!DllsAllowed()) { Print("-DLL not allowed"); return; } // checking whether DLLs are allowed in the terminal
	int headerSize = ArraySize(headerNames);
	if(headerSize <= 0) { return; }
	ArrayFree(headerData);
	ArrayResize(headerData, headerSize);
	// read headers
	
	uchar ch[]; string rawHeaders=""; int dwBytes = 4096, h=0;
	for(int i = 0; i < 1; i++) {
	    ArrayFree(ch);
	    StringToCharArrayW(headerNames[0], ch, 0, WHOLE_ARRAY, CP_UTF8);
	    int postArrayPos = ArraySize(ch);
	    if(dwBytes > postArrayPos) { // StringToCharArrayW resizes the array shorter, so resize it back
	        ArrayResize(ch, dwBytes);
	        ArrayFill(ch, postArrayPos, dwBytes-postArrayPos, 0);
	    }
	    
	    // Would be nice to use HTTP_CUSTOM_HEADER, but that's unreliable and doesn't return existing headers
	    // So process raw headers ourselves
	    int result = HttpQueryInfoW(hRequest, HTTP_QUERY_RAW_HEADERS_CRLF, ch, dwBytes, h);
	    if(result == FALSE) {
	        int errCode = 0;
	        errCode = Kernel32::GetLastError(errCode); // 12150 is header not found
	        if(errCode == ERROR_INSUFFICIENT_BUFFER) {
	            i--; // do this iteration again with the correct dwBytes, which is already set
	            continue;
	        } else { 
	            break;
	        }// dwBytes contains proper size of array
	    } else { // todo: h holds an index of a non-unique header, or ERROR_HTTP_HEADER_NOT_FOUND
	        rawHeaders = CharArrayToStringW(ch, 0, dwBytes, CP_UTF8);
	        break;
	    }
	}
	
	if(StringLen(rawHeaders) <= 0) { return; }
	
	StringReplace(rawHeaders, "\r\n", "\n");
	string rawHeaderList[];
	StringSplit(rawHeaders, '\n', rawHeaderList);
	for(int i = 0; i < ArraySize(rawHeaderList); i++) {
	    if(StringLen(rawHeaderList[i]) <= 0) { break; }
	    string headerParts[2];
	    int partSepPos = StringFind(rawHeaderList[i], ":");
	    if(partSepPos <= 0) { continue; } // likely HTTP/1.1 200 OK, we can skip
	    for(int j = 0; j < ArraySize(headerNames); j++) {
	        string targetHeaderName = headerNames[j], testHeaderName = StringSubstr(rawHeaderList[i], 0, partSepPos);
	        StringToLower(targetHeaderName); StringToLower(testHeaderName);
	        if(targetHeaderName == testHeaderName) { 
	            headerData[j] = StringSubstr(rawHeaderList[i], partSepPos+2); 
	            break; 
	        }
	    }
	}
}
//------------------------------------------------------------------ GetContentSize
long MqlNet::GetContentSize(int hRequest)
{
	if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED)) { Print("-DLL not allowed"); return(false); } // checking whether DLLs are allowed in the terminal
	if(!DllsAllowed()) { Print("-DLL not allowed"); return(false); } // checking whether DLLs are allowed in the terminal
	int len=2048, ind=0; uchar buf[2048];
	int Res=HttpQueryInfoW(hRequest, 1, buf, len, ind); // HTTP_QUERY_CONTENT_LENGTH
	if (Res<=0) { Print("-Err QueryInfo"); return(-1); }

	string s=CharArrayToStringW(buf, 0, len, CP_UTF7);
	if (StringLen(s)<=0) return(0);
	return(StringToInteger(s));
}
//----------------------------------------------------- FileToArray
int MqlNet::FileToArray(string aFileName, uchar& data[])
{
	int h, i, size;	
	h=FileOpen(aFileName, FILE_ANSI|FILE_BIN|FILE_READ);	if (h<0) return(-1);
	FileSeek(h, 0, SEEK_SET);	
	size=(int)FileSize(h); ArrayResize(data, (int)size); 
	for (i=0; i<size; i++) data[i]=(uchar)FileReadInteger(h, CHAR_VALUE); 
	FileClose(h); return(size);
}

string MqlNet::StringToBase64(string data) {
    uchar dataChar[], encodedDataChar[], keyChar[];
    
    // python hashlib takes a utf-8 string not null-terminated
    StringToCharArray(data, dataChar, 0, WHOLE_ARRAY, CP_UTF8);
    //ArrayResize(dataChar, ArraySize(dataChar)-1); // drop null byte
    
    CryptEncode(CRYPT_BASE64, dataChar, keyChar, encodedDataChar);
    
    string result = CharArrayToString(encodedDataChar, 0, WHOLE_ARRAY, CP_UTF8); //NULL;
    //int size = ArraySize(encodedDataChar);
    //for(int i = 0; i < size; i++) {
    //    result += StringFormat("%.2x", encodedDataChar[i]); // lowercase
    //}
    
    return result;
}

string MqlNet::Base64ToString(string encodedData) {
    uchar dataChar[], encodedDataChar[], keyChar[];
    
    // python hashlib takes a utf-8 string not null-terminated
    StringToCharArray(encodedData, encodedDataChar, 0, WHOLE_ARRAY, CP_UTF8);
    //ArrayResize(encodedDataChar, ArraySize(dataChar)-1); // drop null byte
    
    CryptDecode(CRYPT_BASE64, encodedDataChar, keyChar, dataChar);
    
    string result = CharArrayToString(dataChar, 0, WHOLE_ARRAY, CP_UTF8);
    //int size = ArraySize(dataChar);
    //for(int i = 0; i < size; i++) {
    //    result += StringFormat("%.2x", dataChar[i]); // lowercase
    //}
    
    return result;
}

string MqlNet::UrlEncode(string source, bool isForm = false) {
    uchar sourceChar[];
    StringToCharArray(source, sourceChar, 0, WHOLE_ARRAY, CP_UTF8);
    
    string result = NULL; int size = ArraySize(sourceChar);
    for(int i = 0; i < size; i++) {
        if(sourceChar[i] == 0) { break; } // null terminator
        else if(
            (sourceChar[i] >= 48 && sourceChar[i] <= 57) // 0-9
            || (sourceChar[i] >= 65 && sourceChar[i] <= 90) // A-Z
            || (sourceChar[i] >= 97 && sourceChar[i] <= 122) // a-z
            || sourceChar[i] == 45 // -
            || sourceChar[i] == 46 // .
            || sourceChar[i] == 95 // _
        ) { result += CharToString(sourceChar[i]); }
        else if(isForm && sourceChar[i] == 32) { result += "+"; }
        else {
            result += "%" + StringFormat("%.2X", sourceChar[i]);
        }
    }
    
    return result;
}

string MqlNet::UrlDecode(string source) {
    uchar sourceChar[];
    StringToCharArray(source, sourceChar, 0, WHOLE_ARRAY, CP_UTF8);
    
    string result = NULL; int size = ArraySize(sourceChar);
    for(int i = 0; i < size; i++) {
        if(sourceChar[i] == 37) { // %
            char secondHexDigit = sourceChar[++i];
            char firstHexDigit = sourceChar[++i];
            result += HexCharToString(firstHexDigit, secondHexDigit);
        } else if(sourceChar[i] == 43) { // +
            result += " ";
        } else { result += CharToString(sourceChar[i]); }
    }
    
    return result;
}

string MqlNet::HexCharToString(char firstHexDigit, char secondHexDigit) {
    int firstPlace = 0, secondPlace = 0;
    switch(firstHexDigit) {
        case 65: case 97: firstPlace = 10; break; // a
        case 66: case 98: firstPlace = 11; break; // b
        case 67: case 99: firstPlace = 12; break; // c
        case 68: case 100: firstPlace = 13; break; // d
        case 69: case 101: firstPlace = 14; break; // e
        case 70: case 102: firstPlace = 15; break; // f
        case 48: firstPlace = 0; break;
        case 49: firstPlace = 1; break;
        case 50: firstPlace = 2; break;
        case 51: firstPlace = 3; break;
        case 52: firstPlace = 4; break;
        case 53: firstPlace = 5; break;
        case 54: firstPlace = 6; break;
        case 55: firstPlace = 7; break;
        case 56: firstPlace = 8; break;
        case 57: firstPlace = 9; break;
    }
    
    switch(secondHexDigit) {
        case 65: case 97: secondPlace = 10; break; // a
        case 66: case 98: secondPlace = 11; break; // b
        case 67: case 99: secondPlace = 12; break; // c
        case 68: case 100: secondPlace = 13; break; // d
        case 69: case 101: secondPlace = 14; break; // e
        case 70: case 102: secondPlace = 15; break; // f
        case 48: secondPlace = 0; break;
        case 49: secondPlace = 1; break;
        case 50: secondPlace = 2; break;
        case 51: secondPlace = 3; break;
        case 52: secondPlace = 4; break;
        case 53: secondPlace = 5; break;
        case 54: secondPlace = 6; break;
        case 55: secondPlace = 7; break;
        case 56: secondPlace = 8; break;
        case 57: secondPlace = 9; break;
    }
    
    return CharToString(firstPlace + (secondPlace*16));
}

void MqlNet::StringToCharArrayW(const string text_string, uchar &char_array[], int start_pos = 0, int count = WHOLE_ARRAY, uint codepage = CP_ACP) {
    int stringSize = StringLen(text_string);
    int limit = count == WHOLE_ARRAY ? stringSize : count;
    bool isDynamic = ArrayIsDynamic(char_array);
    if(isDynamic) {
        ArrayFree(char_array);
        ArrayResize(char_array, ArraySize(char_array), (limit*2)+2);
    }
    ArrayInitialize(char_array, NULL);
    
    for(int i = start_pos, j = 0; i < limit; i++,j++) {
        if(ArraySize(char_array)/2 <= i) { 
            if(isDynamic) { ArrayResize(char_array, j+2); }
            else { break; }
        }
        char_array[j] = StringGetCharacter(text_string, i);
        char_array[++j] = NULL; // W functions are wide character, this is what they expect
    }
}

string MqlNet::CharArrayToStringW(const uchar &char_array[], int start_pos = 0, int count = WHOLE_ARRAY, uint codepage = CP_ACP) {
    int stringSize = ArraySize(char_array);
    string result = "";
    int limit = count == WHOLE_ARRAY ? stringSize : count;
    for(int i = start_pos; i < limit; i++) {
        if(char_array[i] == NULL) { break; }
        result += CharToString(char_array[i++]); // increment to skip odd indexes, W functions are wide character
    }
    
    return result;
}

bool MqlNet::DllsAllowed() {
    return MQLInfoInteger(MQL_DLLS_ALLOWED);
}