#include <iostream>
#include <queue>
#include <cinttypes>

using namespace std;

class RewardsQ {
private:
  queue<uint32_t> q;
public:

  int size () {
    return q.size();
  }

  void push (uint32_t value) {
    q.push(value);
  }

  uint32_t pop () {
    uint32_t val;
    if (q.size() > 0) {
      val = q.front();
      q.pop();
    } else {
      val = 0;
    }
    return val;
  }

};
