#!/usr/bin/env node

// Dump Intercom data to S3
var _ = require('lodash');
var Promise = require('bluebird');
var AWS = require('aws-sdk');
var zlib = require('zlib');
var Intercom = require('intercom-client');
var moment = require('moment');
var extend = require('xtend');

var s3 = new AWS.S3({ apiVersion: '2006-03-01' });

// Environment
var INTERCOM_APPID = process.env.INTERCOM_APPID || '';
var INTERCOM_ACCESSTOKEN = process.env.INTERCOM_ACCESSTOKEN || '';
var S3BUCKET = process.env.S3BUCKET || '';

var HIVE_DATE_FORMAT = 'YYYY-MM-DD HH:mm:ss';
var OBSERVED_AT = moment();
var _observed_at = OBSERVED_AT.format(HIVE_DATE_FORMAT);

module.exports = dump;

function dump(event, context, cb) {
  if (!INTERCOM_APPID || !INTERCOM_ACCESSTOKEN || !S3BUCKET) return cb('Missing required fields.');

  var client = new Intercom.Client({ token: INTERCOM_ACCESSTOKEN });

  // Retrieve records from Intercom
  var pSegments = client.segments.list();
  var pUsers = new Promise(function(resolve, reject) {
    var users = [];
    client.users.scroll.each({}, function(res) {
      users = users.concat(res.body.users);
    })
    .then(function() { resolve(users); })
    .catch(function(ex) { reject(ex); });
  });

  // Write output
  pSegments
    .then(function(res) { return write('segments', res.body.segments); })
    .then(function() { return pUsers; })
    .then(function(users) { return write('users', users); })
    .then(function(users) {
      var relationships = [
        write('segment_memberships', createJoinTable('segment', users)),
        write('tag_memberships', createJoinTable('tag', users))
      ];
      return Promise.all(relationships);
    })
    .then(function() { return cb; })
    .catch(function(ex) { return cb(ex); });
}

function write(table, content) {
  return new Promise(function(resolve, reject) {
    s3.upload({
      Bucket: S3BUCKET,
      Key: `${table}/${OBSERVED_AT.format('YYYYMMDD-HHmm')}.ndjson.gz`,
      Body: zlib.gzipSync(toNDJson(content))
    }, function(err, data) {
      if (err) reject(err);
      resolve(content);
    });
  })
}

function createJoinTable(key, users) {
  var relationships = users.map(function(u) {
    return _.get(u, `${key}s.${key}s`).map(function(r) {
      return { user_id: u.id, [`${key}_id`]: r.id };
    });
  });
  return _.flatten(relationships);
}

// Stringify collection to new line delimited JSON
function toNDJson(collection) {
  return collection.map(function(item) {
    // Extend each record with the date-time it was observed
    return JSON.stringify(extend(item, { _observed_at: _observed_at }));
  }).join('\n');
}

