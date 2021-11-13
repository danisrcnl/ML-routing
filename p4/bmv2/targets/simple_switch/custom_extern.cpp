#include <chrono>

#include <bm/bm_sim/extern.h>
#include <rohc/rohc_compressor_module.h>

using namespace std;

template <typename... Args>
using ActionPrimitive = bm::ActionPrimitive<Args...>;

using bm::Data;
using bm::Header;
using bm::PHV;
using bm::ExternType;

class CustomExtern : public ExternType {
 public:

  BM_EXTERN_ATTRIBUTES {
    BM_EXTERN_ATTRIBUTE_ADD(custom_attribute);
  }

  // Init variables
  void init() override {
    std::cout << "custom_extern --- init called" << std::endl;
  }

  void print() {
    std::cout << "custom_extern --- print called" << std::endl;
  }

  // Default constructor/destructor
  virtual ~CustomExtern () {}

 private:
  // declared attributes
  Data custom_attribute;

};

BM_REGISTER_EXTERN(CustomExtern);
BM_REGISTER_EXTERN_METHOD(CustomExtern, print);

// End Declaration

int import_custom_extern() {
  return 0;
}
