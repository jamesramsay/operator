var _ = require('lodash');
var Promise = require('bluebird');
var retry = require('bluebird-retry');
var AWS = require('aws-sdk');
var zlib = require('zlib');
var Intercom = require('intercom-client');
var moment = require('moment');
var extend = require('xtend');

var s3 = new AWS.S3({ apiVersion: '2006-03-01' });

// Environment
var INTERCOM_ACCESSTOKEN = process.env.INTERCOM_ACCESSTOKEN || '';
var S3BUCKET = process.env.S3BUCKET || '';

// Create join tabls for these many-to-many relationships
var RESOURCE_RELATIONSHIPS = {
  user: ['segment', 'tag']
}
var TO_SINGULAR = {
  users: 'user',
  companies: 'company',
  segments: 'segment',
  tags: 'tag'
};


// Timestamp formatting
var HIVE_DATE_FORMAT = 'YYYY-MM-DD HH:mm:ss';
var S3_DATE_FORMAT = 'YYYYMMDD_HHmm';
var OBSERVED_AT = moment();
var _observed_at = OBSERVED_AT.format(HIVE_DATE_FORMAT);


module.exports = dump;

var client;

function dump(event, context, cb) {
  if (!INTERCOM_ACCESSTOKEN) return cb('Intercom access token is required to retrieve data.');
  if (!S3BUCKET) return cb('Amazon S3 bucket is required to write data.');

  client = new Intercom.Client({ token: INTERCOM_ACCESSTOKEN });

  // 1. snapshot list resources
  listResources().each(uploadSnapshot)
    // 2. snapshot scroll resources
    .then(scrollResources).each(uploadSnapshot)
    // 3. update events
    .each(uploadResourceEvents)
    .then(function() { return cb })
    .catch(function(ex) { return cb(ex) });
}

// Wrap in function to allow us to control order of evaluation
function listResources() {
  // listAll IS NOT mappable
  return Promise.map(['segments', 'tags'], function(r) { return listAll(r); });
}

function scrollResources() {
  // scrollAll IS mappable
  return Promise.mapSeries(['users', 'companies', 'leads'], scrollAll);
}


//
// Intercom utils
//

// Get all items for scrolled resources
function scrollAll(resource) {
  return new Promise(function(resolve, reject) {
    var items = [];
    client[resource].scroll.each({}, function(res) {
      items = items.concat(res.body[resource]);
    })
    .then(function() { resolve({ resource: resource, items: items }); })
    .catch(function(ex) { reject(ex); });
  });
}

// Get all items for paged resources
function listAll(resource, filter, pages, memo) {
  if (!memo) memo = [];

  function next(res) {
    if (res.pages) return listAll(resource, filter, res.pages, memo.concat(res.body[resource]));
    return { resource: resource, items: memo.concat(res.body[resource]) };
  }

  if (pages) {
    // Create closure for retry
    var fn = function(x) { return client.nextPage(x); };
    return retry(fn, { args: [pages] }).then(next);
  }
  if (filter) {
    // Create closure for retry
    var fn = function(x) { return client[resource].listBy(x); };
    return retry(fn, { args: [filter] }).then(next);
  }
  var fn = function() { return client[resource].list(); };
  return retry(fn).then(next);
}


//
// AWS S3 utils
//
function uploadObject(key, items) {
  // Compress JSON to minimize cost when scanning via Athena
  var body = zlib.gzipSync(toNDJson(items));

  return new Promise(function(resolve, reject) {
    s3.upload({ Bucket: S3BUCKET, Key: key, Body: body }, function(err, data) {
      if (err) return reject(err);
      console.log(`Uploaded ${key}`);
      return resolve(key);
    });
  });
}

function copyObject(source, target) {
  return new Promise(function(resolve, reject) {
    s3.copyObject({ Bucket: S3BUCKET, CopySource: source, Key: target }, function(err, data) {
      if (err) return reject(err);
      console.log(`Copied ${source} to ${target}`);
      return resolve(target);
    });
  });
}


function uploadSnapshot(data) {
  var resource = data.resource;
  var items = data.items;
  // Overwrite every run, allowing convenient joins agains the latest data
  var key = `${resource}/${resource}.ndjson.gz`;
  // Store historical snapshot from each run
  var historicalKey = `historical_${resource}/${OBSERVED_AT.format(S3_DATE_FORMAT)}.ndjson.gz`;

  return uploadObject(key, items)
    .then(function() { return copyObject(`${S3BUCKET}/${key}`, `${historicalKey}`); })
    .then(function() { return uploadRelationships(data); });
}

// Coordinate the creation of join tables for many-to-many relationships
function uploadRelationships(data) {
  var resource = TO_SINGULAR[data.resource];
  var joins = RESOURCE_RELATIONSHIPS[resource];

  if (!joins) return;

  var items = data.items;
  var joinTables = joins.map(function(relationship) { return createJoinTable(resource, items, relationship); });

  return Promise.each(joinTables, uploadSnapshot);
}

// Create join tables to connect segments and tags to users and companies
function createJoinTable(resource, items, relationship) {
  var joins = items.map(function(i) {
    return _.get(i, `${relationship}s.${relationship}s`).map(function(r) {
      return { [`${resource}_id`]: i.id, [`${relationship}_id`]: r.id };
    });
  });
  return { resource: `${relationship}_memberships`, items: _.flatten(joins) };
}

function uploadResourceEvents(data) {
  if (data.resource !== 'users') return;
  return Promise.map(data.items, uploadEvents, { concurrency: 5 });
}

function uploadEvents(user) {
  if (user.type !== 'user') return;

  // Can only request all events for a user. Would be ideal if they could be filtered by timestamp
  var filter = {
    type: 'user',
    intercom_user_id: user.id
  };

  return listAll('events', filter).then(function(res) {
    if (res.items.length == 0) return;
    // Partition by user for improved performance. Simpler to overwrite all events than to only add new ones.
    return uploadObject(`events/${user.id}.ndjson.gz`, res.items);
  })
  .catch(function(ex) {
    console.log(`error: failed to retrieve events for user ${user.id}`);
  });
}

// Stringify collection to newline delimited JSON
function toNDJson(collection) {
  return collection.map(function(item) {
    // Extend each record with the date-time it was observed by us
    return JSON.stringify(extend(item, { _observed_at: _observed_at }));
  }).join('\n');
}

