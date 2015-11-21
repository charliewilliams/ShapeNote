
Parse.Cloud.afterSave(Parse.User, function(request) {

user = Parse.User.current();
group = user["group"];

  query = new Parse.Query("Group");
  query.get(request.object.get("post").id, {
    success: function(post) {
      post.increment("comments");
      post.save();
    },
    error: function(error) {
      console.error("Got an error " + error.code + " : " + error.message);
    }
  });
});