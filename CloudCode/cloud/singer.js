
Parse.Cloud.job("joinBristol", function(request, response) {

  var query = new Parse.Query("Singer");
  var bristolID = "6yEHk8lwYs";




  query.equalTo("movie", request.params.movie);
  query.find({
    success: function(results) {
      var sum = 0;
      for (var i = 0; i < results.length; ++i) {
        sum += results[i].get("stars");
      }
      response.success(sum / results.length);
    },
    error: function() {
      response.error("movie lookup failed");
    }
  });

})