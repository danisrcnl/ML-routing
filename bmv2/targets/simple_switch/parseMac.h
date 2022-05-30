#ifndef __PARSEMAC_H__
#define __PARSEMAC_H__

#include <iostream>
#include <fstream>
#include <unordered_map>
#include <sstream>
#include <algorithm>
#include <list>
#include <map>
#include <nlohmann/json.hpp>

#define LOG_mac "[parseMac.h] "

using namespace std;
using json = nlohmann::json;

bool debug = false;

uint64_t convert_mac(string mac) {
    mac.erase(remove(mac.begin(), mac.end(), ':'), mac.end());
    uint64_t addr;
    stringstream ss;
    ss << hex << mac;
    ss >> addr;
    return addr;
}

list<string> readP4app () {
    list<string> switches;
    ifstream fp;
    fp.open("p4app.json");
    if (!fp.is_open())
        throw runtime_error("File is not opened");
    json j;
    fp >> j;
    auto m = j["topology"]["switches"];
    for (auto it = m.begin(); it != m.end(); it++)
      switches.push_back(it.key());
    fp.close();
    return switches;
}

void showMacs (unordered_map <uint64_t, string> macs) {
    if (debug) cout << LOG_mac << "Printing list of mac addresses mapping" << endl;
    for (auto i : macs) {
      stringstream ss;
      ss << hex << i.first;
      string addr = ss.str();
      if (debug) cout << LOG_mac << addr << " => " << i.second << endl;
    }
}

unordered_map <uint64_t, string> parseMac () {
    unordered_map <uint64_t, string> macs;
    list<string> switches;

    ifstream fp;
    fp.open("topology.db");
    if (!fp.is_open())
        throw runtime_error("File is not opened");
    json j;
    fp >> j;

    switches = readP4app();

    for (auto it = switches.begin(); it != switches.end(); it++) {
      auto switchInfo = j[*it];
      auto interfaces = switchInfo["interfaces_to_node"];
      list<string> neighbors;

      for (auto itj = interfaces.begin(); itj != interfaces.end(); itj++)
        neighbors.push_back(itj.value());

      for (auto itj = neighbors.begin(); itj != neighbors.end(); itj++) {
        auto ifInfo = j[*it][*itj];
        uint64_t mac = convert_mac(ifInfo["mac"]);
        macs[mac] = *it;
      }

    }
    fp.close();

    return macs;
}

string getPath () {
  char buffer[200];
   if (getcwd(buffer, sizeof(buffer)) != NULL) {
       string s(buffer);
       return s;
   } else {
       string s("error");
       return s;
   }
}

uint64_t getNeighbor (string host, uint32_t port) {
  ifstream fp;
  fp.open("topology.db");
  if (!fp.is_open())
      throw runtime_error("File is not opened");
  json j;
  fp >> j;
  auto switchInfo = j[host];
  auto neighbors = switchInfo["interfaces_to_node"];
  string interface = host + "-eth" + to_string(port);
  string neighborId;
  for (auto it = neighbors.begin(); it != neighbors.end(); it++) {
    if (it.key() == interface) {
      neighborId = it.value();
      break;
    }
  }
  switchInfo = j[neighborId];
  if (debug) cout << LOG_mac << "chosen neighbor is " << neighborId << endl;
  string macStr = switchInfo[host]["mac"];
  if (debug) cout << LOG_mac << "chosen neighbor has mac " << macStr << endl;
  fp.close();
  return convert_mac(macStr);
}

#endif
