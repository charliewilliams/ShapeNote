
Parse.Cloud.job("joinBristol", function(request, response) {

  var query = new Parse.Query("Singer");
  var bristolID = "6yEHk8lwYs";

  query.find({
    success: function(results) {
      
      for (var i = 0; i < results.length; ++i) {

          var singer = results[i];
          singer.set("")

        // sum += results[i].get("stars");
      }
      response.success(sum / results.length);
    },
    error: function() {
      response.error("movie lookup failed");
    }
  });

})