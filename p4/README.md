# p4 module

Base P4-utils code used to support custom extern implementation has been provided by [this repository](https://github.com/engjefersonsantiago/p4-programs).

All the information you need to install it are below.

## Summary
- [How to install](#how-to-install)
- [Custom extern implementation step by step](#custom-extern-implementation-step-by-step)

## How to install

- inside **bmv2**
```bash
cd bmv2
./autogen.sh
./configure
make -j4
sudo make install
```

- inside **p4c**
```bash
./bootstrap.sh
cd build
make -j4
sudo make install
```

- inside **p4c-bmv2**
```bash
pip install -r requirements_v1_1.txt
```

## Custom extern implementation step by step

Be sure you're using p4c and bmv2 modules from this repository, as they've been modified right to support JSON generation of custom externs, which is not natively supported by p4.

We're going to modify **bmv2** to implement a simple extern called CustomExtern (it's already implemented into this repository).

### 1. Create custom_extern.cpp

```bash
cd bmv2/targets/simple_switch
```
First of all we're going to create a .cpp source file which will contain the complex C++ operations we want to call from the p4 application:

```bash
touch custom_extern.cpp
```

Under this file, already present into the repository, you can see a typical custom extern implementation.
Things this source file can't miss are:

***Inside the class***

- extension to the class **ExternType**
```C++
class CustomExtern : public ExternType {
```

- attribute(s) declaration
```C++
BM_EXTERN_ATTRIBUTES {
    BM_EXTERN_ATTRIBUTE_ADD(custom_attribute);
}
```

- override of method init
```C++
void init() override {
    std::cout << "custom_extern --- init called" << std::endl;
}
```

- default deconstructor
```C++
virtual ~CustomExtern () {}
```

- actual declaration of custom attribute(s)
```C++
private:
    Data custom_attribute;
```

***Outside the class***

- registration of extern and extern method(s)
```C++
BM_REGISTER_EXTERN(CustomExtern);
BM_REGISTER_EXTERN_METHOD(CustomExtern, print); // if you open
// the source file you can see the implementation
// of print method inside the class
```

- a nothing-but-return-zero function we're going to call import_custom_extern, necessary to correctly link the modules with each other
```C++
int import_custom_extern() {
    return 0;
}
```

### 2. Modify simple_switch.cpp

Let's move to the folder containing simple_switch source file (where we also added the extern source).

```bash
cd bmv2/targets/simple_switch
```

Let's open **simple_switch.cpp**: we have to add a couple of LOCs to this file, under the corresponding calls to function related to primitives import, using our nothing-but-return-zero function.

```C++
// around line 65
extern int import_primitives(); // already there
extern int import_custom_extern(); // to be added
...
// around line 111
import_primitives(); // already there
import_custom_extern(); // to be added
```

### 3. Modify Makefile.am
Stay in the same path and modify the Makefile.am file, around line 11, adding the reference to the cpp file we just added

```am
libsimpleswitch_la_SOURCES = \
simple_switch.cpp simple_switch.h primitives.cpp \
custom_extern.cpp
```
Now let's call make on this folder (bmv2/targets/simple_switch) to make our changes effective
```bash
sudo make -j4
```

### 4. Compile and install again bmv2
```bash
cd bmv2
sudo make -j4
sudo make install
```

### 5. Into the p4 application
Now you can easily use your extern into any p4 application. Just declare the extern at the beginning of your code (along with the headers declaration)

```p4
extern CustomExtern {
    CustomExtern(bit<8> custom_attribute);
    void print();
}
```

Inside a control block, such as MyIngress, you can create an instance of the extern and use its methods

```p4
control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {

    @userextern @name("custom_extern_instance")
    CustomExtern(0x01) custom_extern_instance;

    action custom_print() {
        custom_extern_instance.print();
    }

apply {
  custom_print();
...
```

### 6. Compile the application
Now you can obtain the JSON of your application by simply compiling it by means of p4c-bm2-ss
```bash
p4c-bm2-ss myapp.p4 -o myapp.json
```
