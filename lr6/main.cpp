#include <iostream.h>
#include <limits.h>

extern "C" {
	int CalcOne(int);
	int CalcTwo(int);
	int CalcThree(int);
}

int InputX() {
	int in_x = 0;

	cout << "Enter X of range: from "
             << INT_MIN
             << " to "
             << INT_MAX
             << " -> ";
	cin >> in_x;

	if (cin.fail()) {
		cout << "Faild input" << endl;
	}

	return in_x;
}


int main() {
	int in_x = 0;
	int res = 0;

	in_x = InputX();

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