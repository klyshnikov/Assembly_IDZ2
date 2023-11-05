#include <iostream>

double count(double x) {
    double cur_x = x*x;
    double prev = 1;
    double cur = 1 + x;
    while (!((double(cur)/prev) < 1.0005) || !((double(cur)/prev) > 0.9995)) {
        prev = cur;
        cur += cur_x;
        cur_x *= x;
    }
    return cur;
}

int main()
{
    std::cout << "Count 1/(1-x) when x = 0,23 \n";
    std::cout << "Real value = " << 1.0/(1-0.23) << "\n";
    std::cout << "Func value = " << count(0.23) << "\n";

    return 0;
}
