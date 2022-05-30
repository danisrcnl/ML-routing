#include <iostream>
#include <queue>
#include <cinttypes>
#include <mutex>

using namespace std;

class RewardsQ {
private:
  mutex q_mutex;
  queue<uint32_t> q;
public:

  int size () {
    lock_guard<mutex> lk(q_mutex);
    return q.size();
  }

  void push (uint32_t value) {
    lock_guard<mutex> lk(q_mutex);
    q.push(value);
  }

  uint32_t pop () {
    lock_guard<mutex> lk(q_mutex);
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
