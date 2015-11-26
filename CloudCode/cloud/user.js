
Parse.Cloud.afterSave(Parse.User, function(request) {

user = Parse.User.current();
group = user["group"];

  group.add
});