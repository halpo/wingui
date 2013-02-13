
#include <Rcpp.h>

#undef Realloc
#undef Free

#include <windows.h>
#include <string>
#include <sstream>
#include <stdexcept>
using namespace std;

class findR{
  private:
    DWORD _Rpid;
    HWND _RWnd;
  public:
    findR(DWORD pid):_Rpid(pid),_RWnd(NULL){}
    bool isR( HWND in) {
        DWORD inPid=0;
        GetWindowThreadProcessId(in, &inPid);
        // Rprintf("ipPid=%d\t", inPid);
        if (inPid == _Rpid) {
            _RWnd = in;
            // Rprintf("this is R(%p).\n", _RWnd);
            return (inPid == _Rpid);
        }
        return false;
    }
    HWND RWnd(){
        // Rprintf("RWnd=%p\t", _RWnd);
        return _RWnd;
    }
};


int get_pid() {
    return GetCurrentProcessId();
}
BOOL CALLBACK EnumFind(HWND aWnd, LPARAM lParam) {
	findR* find = (findR *)lParam;
	if (!IsWindowVisible(aWnd)){ // Skip hidden windows.
        // Rprintf("Awnd=%p\n", aWnd);
		return true;
    }
	return !(find->isR(aWnd));
}
HWND getWin() {
    findR find(get_pid());
    EnumWindows(EnumFind, (LPARAM)&find);
    return find.RWnd();
}
string get_win() {
    ostringstream stringStream;
    stringStream << getWin() << endl;
    return stringStream.str();
}
string getWindowTextI(HWND Wnd=NULL) {
    const int nMaxCount = 255;
    char szBuffer[nMaxCount+1];
    if(!Wnd)
        Wnd = getWin();
    if(!Wnd)
        throw runtime_error("could not find R!");
    GetWindowText( getWin(), szBuffer, nMaxCount );
    string title = szBuffer;
    return title;
}
string get_window_text() {
    return getWindowTextI();
}
string set_window_text(string title) {
    SetWindowText(getWin(), title.c_str());
    return get_window_text();
}


