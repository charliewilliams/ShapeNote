var fbGroupID = "fbGroupID";
var Group = "Group";
var Singer = "Singer";
var JobMetadata = "JobMetadata";
var lastGroupQueriedForMembersJob = "lastGroupQueriedForMembersJob";

Parse.Cloud.job("updateMembersOfFacebookGroups", function(request, response) {

  var promise = new Parse.Promise();
  Parse.Cloud.useMasterKey();
  var query = new Parse.Query(JobMetadata);
  query.find().then(function(results) {

    var metadata = results[0];
    var group = metadata.get(lastGroupQueriedForMembersJob);
    group.fetch().then(function() {

      var groupID = group.get(fbGroupID);
      console.log("GROUP " + groupID);
    
      getMembersOfFacebookGroupFromID(groupID).then(function(users) {

        checkGroupListAgainstExistingMembersOfGroup(users["data"], group);
        .then(group.save())
        .then(setNextGroupIDInMetadata())
        .then(function() {
          promise.resolve();
          response.success("DONE… " + users.length);
        });
      });
    });

  }, function(error) {
      console.log(error);
      promise.reject(error);
      response.error(error);
  });
})

function checkGroupListAgainstExistingMembersOfGroup(users, group) {

  var promise = new Parse.Promise();
  var singersRelation = group.relation("singers");
  var singersQuery = singersRelation.query();
  singersQuery.limit(1000);
  singersQuery.find().then(function(singers) {

    // console.log("HERE: " + users.length + " / " + singers.length + " / " + users.length - singers.length + " new singers since last check");
    var dummy = new Parse.Promise();
    var promises = [dummy];

    // For each singer Facebook gave us
    for (var j = 0; j < users.length; j++) {

      var user = users[j];
      // console.log(user["name"]);

      var found = false;

      // Look for a singer in Parse matching the FBID
      for (var i = 0; i < singers.count; i++) {

        var singer = singers[i];
          
        // If you did find one, update the info
        if (singer.get("fbID") === user["id"]) {
          found = true;
          copyDetailsFromFBUserToSinger(user, singer);
          promises.push(singer.save());
        }
      }

      // If you haven't found one, add the singer to the group
      if (!found) {
        var SingerClass = Parse.Object.extend("Singer");
        var newSinger = new SingerClass();
        copyDetailsFromFBUserToSinger(user, newSinger);
        
        var relationPromise = new Parse.Promise();
        promises.push(relationPromise);

        newSinger.save().then(function() {
          singersRelation.add(newSinger);
          singers.push(newSinger);
          relationPromise.resolve();
        });
      }
    }

    dummy.resolve();
    Parse.Promise.when(promises).then([Parse.Object.saveAll(singers)]).then(function() {
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

function setNextGroupIDInMetadata() {

  var promise = new Parse.Promise();
  var lastGroupQuery = new Parse.Query(JobMetadata);
  lastGroupQuery.include(lastGroupQueriedForMembersJob);
  lastGroupQuery.find().then(function(groupResults) {

    var metadata = groupResults[0];
    var group = metadata.get(lastGroupQueriedForMembersJob);
    var query = new Parse.Query(Group);
    query.find().then(function(results) {

        var found = false;
        for (var i = 0; i < results.length; i++) {

          var groupToTest = results[i];
          if (group.get(fbGroupID) === groupToTest.get(fbGroupID)) {

            found = true;
            var index = (i + 1) % results.length;
            var nextGroup = results[index];
            var nextGroupID = nextGroup.get(fbGroupID);
            metadata.set(lastGroupQueriedForMembersJob, nextGroup);
            metadata.save().then(promise.resolve(nextGroupID));
            break;
          }
        }

        if (found === false) {
          // If we haven't found anything, start over at 0
          var nextGroup = results[0];
          metadata.set(lastGroupQueriedForMembersJob, nextGroup);
          metadata.save().then(promise.resolve(nextGroup.get(fbGroupID)));
        }
    });
  });
  return promise;
}

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

