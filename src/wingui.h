#ifdef Realloc
#undef Realloc
#endif
#ifdef Free
#undef Free
#endif

#include <windows.h>

#ifndef _WINDEF_
typedef void * HWND;
#endif 

class WindowsGUI{
  private:
    HWND HGUI;
  public:
    WindowsGUI();
    int get_pid();
    std::string get_win();
    std::string get_window_text();
    void set_window_text(std::string);
    bool get_on_top();
    void set_on_top(bool);
};

