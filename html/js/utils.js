// Generated by CoffeeScript 1.7.1
String.prototype.startswith = function(ex) {
  if (this.substr(0, ex.length) === ex) {
    return true;
  }
  return false;
};

String.prototype.istartswith = function(ex) {
  if (this.substr(0, ex.length).toLowerCase() === ex.toLowerCase()) {
    return true;
  }
  return false;
};
