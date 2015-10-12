
#ifdef _WIN32

#include <Rcpp.h>
#include <string>

#include "wingui.h"

using namespace Rcpp;
using namespace std;

RCPP_MODULE(wingui){
    class_<WindowsGUI>( "WindowsGUI" )
        .constructor()
        .property(".pid"  , &WindowsGUI::get_pid)
        .property(".hwnd" , &WindowsGUI::get_win)
        .property("Title" , &WindowsGUI::get_window_text, &WindowsGUI::set_window_text, "Title of the window")
        .property("on.top", &WindowsGUI::get_on_top     , &WindowsGUI::set_on_top     , "Is the window fixed on top?");
        ;
}

#endif
