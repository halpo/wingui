

#include <windows.h>
#include <string>
#include <sstream>
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
        if (inPid == _Rpid) {
            _RWnd = in;
            return (inPid == _Rpid);
        }
        return false;
    }
    HWND RWnd(){
        return _RWnd;
    }
};


int get_pid(){
    return GetCurrentProcessId();
}

BOOL CALLBACK EnumFind(HWND aWnd, LPARAM lParam)
{
	findR find = *(findR *)lParam;
	if (!IsWindowVisible(aWnd)) // Skip hidden windows.
		return true;
	return !(find.isR(aWnd));
}
HWND getWin(){
    findR find(get_pid());
    EnumWindows(EnumFind, (LPARAM)&find);
    return find.RWnd();
}
string get_win(){
    ostringstream stringStream;
    stringStream << getWin();
    return stringStream.str();
}
// int set_win_title(string title) {
    // return 0;
// }


