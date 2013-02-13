
#include <Rcpp.h>
#include <string>

using namespace Rcpp;
using namespace std;

int get_pid();
string get_window_text();
string set_window_text(string);



RCPP_MODULE(wintitle){
    function("get_pid", &get_pid);
    function("get_window_text", &get_window_text);
    function("set_window_text", &set_window_text);
}

