
var exec = require('cordova/exec');

var PLUGIN_NAME = 'MyCordovaPlugin';

//var MyCordovaPlugin = function(config, successCallback, errorCallback) {
//	cordova.exec(function(params) {
//		successCallback();
//	},
//	function(error) {
//		errorCallback(error);
//	}, "MyCordovaPlugin", "init", [config]);
//};
//
//
//MyCordovaPlugin.prototype.echo = function(phrase, successCallback, errorCallback) {
//	cordova.exec(function(params) {
//		successCallback(params);
//	},
//	function(error) {
//		errorCallback(error);
//	}, "MyCordovaPlugin", "echo", [phrase]);
//};
//
//MyCordovaPlugin.prototype.getDate = function(config, successCallback, errorCallback) {
//	cordova.exec(function(params) {
//		successCallback(params);
//	},
//	function(error) {
//		errorCallback(error);
//	}, "MyCordovaPlugin", "getDate", [config]);
//};

var MyCordovaPlugin = {
  init: function(options, cb, ecb) {
    exec(cb, ecb, PLUGIN_NAME, 'init', [options]);
  }, 
  login: function(loginDetails, cb, ecb) {
    exec(cb, ecb, PLUGIN_NAME, 'login', [loginDetails]);
  }, 
  logout: function(cb, ecb) {
    exec(cb, ecb, PLUGIN_NAME, 'logout', []);
  }, 
  refresh: function(cb, ecb) {
    exec(cb, ecb, PLUGIN_NAME, 'refresh', []);
  }, 
  echo: function(phrase, cb) {
    exec(cb, null, PLUGIN_NAME, 'echo', [phrase]);
  },
  getDate: function(cb) {
    exec(cb, null, PLUGIN_NAME, 'getDate', []);
  }
};

module.exports = MyCordovaPlugin;
