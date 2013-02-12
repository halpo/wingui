
#include <Rcpp.h>
#include <string>

using namespace Rcpp;
using namespace std;

int get_pid();
string get_win();
// int set_win_title(string title);



RCPP_MODULE(wintitle){
    function("get_pid", &get_pid);
    function("get_win", &get_win);
}

