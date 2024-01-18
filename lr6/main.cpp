#include <iostream.h>
#include <limits.h>

extern "C" {
	float CalcOne(float);
	float CalcTwo(float);
	float CalcThree(float);
}

int is_err = 0;

float InputX() {
	float in_x = 0;

	cout << "Enter X of range: from "
             << INT_MIN
             << " to "
             << INT_MAX
             << " -> ";
	cin >> in_x;

	if (cin.fail()) {
		cout << "Faild input" << endl;
		is_err = -1;
	}

	return in_x;
}


int main() {
	float in_x = 0;
	float res = 0;

	in_x = InputX();

	if (is_err == -1) {
		return 0;
	}

	if (in_x < 0) {
        res = CalcOne(in_x);
    } else if (in_x > 0.5) {
        res = CalcThree(in_x);
    } else {
        res = CalcTwo(in_x);
    }

    cout << "Res function: "
         << res
         << endl;

	return 0;
}