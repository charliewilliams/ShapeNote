var fbGroupID = "fbGroupID";
var Group = "Group";
var Singer = "Singer";
var JobMetadata = "JobMetadata";
var lastGroupQueriedForMembersJob = "lastGroupQueriedForMembersJob";

Parse.Cloud.job("updateMembersOfFacebookGroups", function(request, response) {

  var dummy = new Parse.Promise();
  var promises = [dummy];
  Parse.Cloud.useMasterKey();
  var query = new Parse.Query(Group);
  query.find().then(function(groups) {

    groups.forEach(function(group) {

      var promise = new Parse.Promise();
      promises.push(promise);

      var groupID = group.get(fbGroupID);
      console.log("GROUP " + groupID + " / " + group.id);
    
      getMembersOfFacebookGroupFromID(groupID).then(function(users) {
        checkGroupListAgainstExistingMembersOfGroup(users["data"], group).then(function() {
            promise.resolve();
          });
      });
    });

  }).then(function() {

    dummy.resolve();
    Parse.Promise.when(promises).then(function() {
      console.log("DONE. ");
      response.success("DONE. ");
    });

  }, function(error) {
      console.log(error);
      promise.reject(error);
      response.error(error);
  });
})

function checkGroupListAgainstExistingMembersOfGroup(users, group) {

  var debugMax = 10; // 1000
  var promise = new Parse.Promise();
  var singersRelation = group.relation("singers");
  var singersQuery = singersRelation.query();
  singersQuery.limit(debugMax);
  singersQuery.find().then(function(singers) {

    var remainingSingers = singers.slice();
    var dummy = new Parse.Promise();
    var promises = [dummy];

    // For each singer Facebook gave us
    var count = Math.min(debugMax, users.length);
    for (var j = 0; j < count; j++) {

      var user = users[j];
      // console.log(user["name"]);

      var foundIndex = -1;

      // Look for a singer in Parse matching the FBID
      var innerCount = Math.min(debugMax, remainingSingers.count);
      for (var i = 0; i < innerCount; i++) {

        var singer = remainingSingers[i];
          
        // If you did find one, update the info
        if (singer.get("fbID") === user["id"]) {
          foundIndex = i;
          copyDetailsFromFBUserToSinger(user, singer);
          promises.push(singer.save());
        }
      }

      // If you haven't found one, query to see if they exist and are tied to another group
      var singerQuery = new Parse.Query(Singer);
      singerQuery.equalTo(fbID, user["id"]);
      var queryPromise = singerQuery.first();
      promises.push(queryPromise);
      queryPromise.then(function(existingSinger) {
        existingSinger.addUnique("groups", group.id);
        foundIndex = 0;
        queryPromise.resolve();
      }, function(error) {
        console.log("Error looking up existing singer! " + error);
        queryPromise.resolve();
      });

      // If you STILL haven't found one, make a new singer
      if (foundIndex === -1) {
        var SingerClass = Parse.Object.extend("Singer");
        var newSinger = new SingerClass();
        copyDetailsFromFBUserToSinger(user, newSinger);
        newSinger.addUnique("groups", group.id);

        var savePromise = newSinger.save();

        savePromise.then(function(savedSinger) {
          singersRelation.add(savedSinger);
          singers.push(savedSinger);

        }, function(error) {
          console.log(error);
        });

        promises.push(savePromise);

      } else {
        remainingSingers.splice(foundIndex, 0);
      }
    }

    // for singer in remainingSingers { that singer wasn't found anymore in the facebook group, remove them }
    for (var i = 0; i < remainingSingers.length; i++) {
      var singer = remainingSingers[i];
      singer.remove("groups", group);
      singers.push(singer);
    }

    console.log("Resolving dummy");
    dummy.resolve();
    Parse.Promise.when(promises).then([Parse.Object.saveAll(singers)], group.save()).then(function() {
      console.log("Found " + singers.length + " singers and " + users.length + " facebookers in group");
      promise.resolve();
    });

  }, function(error) {
    console.log(JSON.stringify(error));
    promise.reject(error);
  });

  return promise;
}

function copyDetailsFromFBUserToSinger(fbUser, singer) {
  var name = fbUser["name"];
  var components = name.split(" ");
  singer.set("firstName", components.shift());
  singer.set("lastName", components.join(" "));
  singer.set("fbID", fbUser["id"]);
  singer.set("fbGroupAdmin", fbUser["administrator"]);
}

function getMembersOfFacebookGroupFromID(facebookGroupID) {

  //GET /v2.1/{group-id}/members HTTP/1.1
  // Host: graph.facebook.com
  // Any valid access token if the group's privacy setting is either OPEN or CLOSED.

  var promise = new Parse.Promise();

  var accessToken = "CAAE2GNwThbwBAORdOZAoefdNQcBZB8sF26uWXfaFmc2jTW9ZBTGJhgvarxZAwWuHePHQ74KZAZBocpZAKTkgZCuFJejopftZBhZAq7FYZArRRN4ZCc8jTJRtFECtiEoJqj1KSjoVKLuBapnAUqaQopZAWiM7iaI7rz7ZC2ZBlmSIkzwrODORmrIW4xue4PETS1TthQ3LGX5HdZABt7xbQXz2xBFXJ0ZBzzgAmBpfURqEZD";
  // "expiration_date":"2016-01-24T21:36:40.205Z",

  Parse.Cloud.httpRequest({

    method: 'GET',
      headers: {
          'Content-Type': 'application/json'
      },
      url: 'https://graph.facebook.com/v2.1/' + facebookGroupID + '/members?access_token=' + accessToken

    }).then(function(res) {

      // console.log("FACEBOOK SEZ: " + JSON.stringify(res["data"]));
      var usersArray = res["data"];
      promise.resolve(usersArray);

    }, function(error) {

      console.log("Error: " + JSON.stringify(error));
      promise.reject(error);
    });

    return promise;
}

// function setNextGroupIDInMetadata() {

//   var promise = new Parse.Promise();
//   var lastGroupQuery = new Parse.Query(JobMetadata);
//   lastGroupQuery.include(lastGroupQueriedForMembersJob);
//   lastGroupQuery.find().then(function(metadataResults) {

//     var metadata = metadataResults[0];
//     var group = metadata.get(lastGroupQueriedForMembersJob);
//     var query = new Parse.Query(Group);
//     group.fetch().then(query.find()).then(function(results) {

//       console.log(JSON.stringify(results));
//       var found = false;
//       for (var i = 0; i < results.length; i++) {

//         var groupToTest = results[i];
//         console.log("Comparing " + group.get(fbGroupID) + " with " + groupToTest.get(fbGroupID));
//         if (group.get(fbGroupID) === groupToTest.get(fbGroupID)) {

//           found = true;
//           var index = (i + 1) % results.length;
//           var nextGroup = results[index];
//           var nextGroupID = nextGroup.get(fbGroupID);
//           metadata.set(lastGroupQueriedForMembersJob, nextGroup);
//           console.log("Saving next group with ID " + nextGroup.id + " / " + nextGroupID);
//           metadata.save().then(promise.resolve(nextGroupID));
//         }
//       }

//       if (found === false) {
//         // If we haven't found anything, start over at 0
//         console.log("Defaulting to first group");
//         var nextGroup = results[0];
//         metadata.set(lastGroupQueriedForMembersJob, nextGroup);
//         metadata.save().then(promise.resolve(nextGroup.get(fbGroupID)));
//       }
//     }, function(error) {
//       console.log(error);
//       promise.reject(error);
//     });
//   });

//   return promise;
// }

// Jobs for testing

Parse.Cloud.job("facebookAPITest", function(request, response) {
  getMembersOfFacebookGroupFromID("159750340866331").then(function(users) {
    console.log(JSON.stringify(users));
  });
})

Parse.Cloud.job("setNextGroupIDInMetadataTest", function(request, response) {
  setNextGroupIDInMetadata().then(function(nextGroupID) {
    response.success("nextGroupID: " + nextGroupID);
  });
})

