
#ifdef _WIN32

#include <Rcpp.h>

#include <string>
#include <sstream>
#include <stdexcept>
using namespace std;

#include "wingui.h"


class findR{
  private:
    DWORD _Rpid;
    HWND  _RWnd;
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
BOOL CALLBACK EnumFind(HWND aWnd, LPARAM lParam) {
	findR* find = (findR *)lParam;
	if (!IsWindowVisible(aWnd)){ // Skip hidden windows.
        // Rprintf("Awnd=%p\n", aWnd);
		return true;
    }
	return !(find->isR(aWnd));
}

int WindowsGUI::get_pid() {
    return GetCurrentProcessId();
}
WindowsGUI::WindowsGUI() {
    findR find(get_pid());
    EnumWindows(EnumFind, (LPARAM)&find);
    HGUI = find.RWnd();
}
string WindowsGUI::get_win() {
    ostringstream stringStream;
    stringStream << HGUI;
    return stringStream.str();
}
string WindowsGUI::get_window_text() {
    const int nMaxCount = 255;
    char szBuffer[nMaxCount+1];
    GetWindowText( HGUI, szBuffer, nMaxCount );
    string title = szBuffer;
    return title;
}
void WindowsGUI::set_window_text(string title) {
    SetWindowText(HGUI, title.c_str());
    return;
}

#endif
