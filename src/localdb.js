// Generated by CoffeeScript 1.7.1
var Collection, LocalDB, Utils, dbPrefix;

Utils = require('./lib/utils');

Collection = require('./lib/collection');

dbPrefix = "ldb_";

LocalDB = function(dbName, engine) {
  if (engine == null) {
    engine = localStorage;
  }
  this.ls = engine;
  this.name = dbPrefix + dbName;
  return this;
};

LocalDB.isSupport = function() {
  if (typeof localStorage !== "undefined" && localStorage !== null) {
    return true;
  } else {
    return false;
  }
};

LocalDB.prototype.collections = function() {
  var i, _i, _ref, _results;
  _results = [];
  for (i = _i = 0, _ref = this.ls.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
    if (this.ls.key(i).indexOf("" + this.name + "_") === 0) {
      _results.push(this.ls.key(i));
    }
  }
  return _results;
};

LocalDB.prototype.collection = function(collectionName) {
  return new Collection(collectionName, this);
};

LocalDB.prototype.drop = function(collectionName) {
  var i, j, keys, _i, _len;
  collectionName = collectionName != null ? "_" + collectionName : "";
  keys = (function() {
    var _i, _ref, _results;
    _results = [];
    for (i = _i = 0, _ref = this.ls.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      if (this.ls.key(i).indexOf(this.name + collectionName) === 0) {
        _results.push(this.ls.key(i));
      }
    }
    return _results;
  }).call(this);
  for (_i = 0, _len = keys.length; _i < _len; _i++) {
    j = keys[_i];
    this.ls.removeItem(j);
  }
  return true;
};

module.exports = LocalDB;