var fbGroupID = "fbGroupID";
var Group = "Group";
var JobMetadata = "JobMetadata";
var lastGroupQueriedForMembersJob = "lastGroupQueriedForMembersJob";

Parse.Cloud.job("updateMembersOfFacebookGroups", function(request, response) {

  Parse.Cloud.useMasterKey();
  var lastGroupQuery = new Parse.Query(JobMetadata);
  lastGroupQuery.find().then(function(results) {

    var metadata = results[0];
    var group = metadata[lastGroupQueriedForMembersJob];

    // Get the group because we're going to add singers to it
    var query = new Parse.Query(Group);
    query.equalTo("objectId", group);
    query.find().then(function(results) {

        console.log(JSON.stringify(results[0]));

        var pfGroup = results[0];

        // Now ask Facebook for the members of the group with this ID
        Parse.H

    }).then(setNextGroupIDInMetadata(request, response));

  }, function(error) {

      console.log(error);
  })
})

Parse.Cloud.job("facebookAPITest", function(request, response) {
  getMembersOfFacebookGroupFromID("159750340866331").then(function(users) {

    console.log(JSON.stringify(users));
  });
})

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

      console.log("FACEBOOK SEZ: " + JSON.stringify(res["data"]));
      var users = res["data"];
      promise.resolve(users);

    }, function(error) {

      console.log("Error: " + JSON.stringify(error));
      promise.reject(error);
    });

    return promise;
}

Parse.Cloud.job("setNextGroupIDInMetadataTest", function(request, response) {
  setNextGroupIDInMetadata().then(function(nextGroupID) {
    response.success("nextGroupID: " + nextGroupID);
  });
})

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
        for (i = 0; i < results.length; i++) {

          var groupToTest = results[i];
          if (group.get("objectId") === groupToTest.get("objectId")) {

            found = true;
            var index = (i + 1) % results.length;
            var nextGroup = results[index];
            console.log("HI " + nextGroup.get("objectId"));
            metadata.set(lastGroupQueriedForMembersJob, nextGroup);
            metadata.save().then(promise.resolve(nextGroup.get("objectId")));
            break;
          }
        }

        if (found == false) {
          // If we haven't found anything, start over at 0
          var nextGroup = results[0];
          metadata.set(lastGroupQueriedForMembersJob, nextGroup);
          console.log("DEFAULT to groupID " + nextGroup);
          metadata.save().then(promise.resolve(nextGroup.get("objectId")));
        }
    });
  });
  return promise;
}

