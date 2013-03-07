

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
};

