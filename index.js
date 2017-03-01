var dump = require('./actions/dump');

exports.handler = function(event, context, cb) {
  // Only supported function is dump!
  return dump(event, context, cb);
}
