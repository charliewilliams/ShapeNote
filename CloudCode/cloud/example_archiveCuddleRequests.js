Parse.Cloud.job("archiveOldCuddleRequests", function(request, response) {
	
	Parse.Cloud.useMasterKey();
	var now = new Date();
	var nowSecs = now.getTime();
	var twoMonthsAgo = new Date(nowSecs - 60*60*24*7*4*3*1000);
	var ArchiveClass = Parse.Object.extend("ArchivedCuddleRequest");

	var promises = [];
	var count = 0;
	var archiveCount = 0;
	var deleteCount = 0;
	var archiveError = 0;
	var deleteError = 0;

	var q = new Parse.Query("CuddleRequest");
	// q.ascending('createdAt');
	q.lessThan('createdAt', twoMonthsAgo);
	q.limit(500);
	q.find().then(function(requests) {

		console.log("requests: " + requests.length);

		requests.forEach(function(cuddleRequest) {

			var archive = new ArchiveClass();
			archive.set('originallyCreated', cuddleRequest.createdAt);
			archive.set('originallyModified', cuddleRequest.updatedAt);
			archive.set('creator', cuddleRequest.get('creator'));
			archive.set('recipient', cuddleRequest.get('recipient'));

			var creator_location = cuddleRequest.get('creator_location');
			if (creator_location) {

				archive.set('creator_lat', creator_location.latitude);
				archive.set('creator_lon', creator_location.longitude);
			}

			archive.set('recipient_location', cuddleRequest.get('recipient_location'));
			archive.set('creator_positives', cuddleRequest.get('creator_positives'));
			archive.set('creator_negatives', cuddleRequest.get('creator_negatives'));
			archive.set('recipient_positives', cuddleRequest.get('recipient_positives'));
			archive.set('message', cuddleRequest.get('message'));
			archive.set('creator_name', cuddleRequest.get('creator_name'));
			archive.set('recipient_name', cuddleRequest.get('recipient_name'));
			archive.set('accepted', cuddleRequest.get('accepted'));
			archive.set('active', cuddleRequest.get('active'));
			archive.set('pushed_sender', cuddleRequest.get('pushed_sender'));
			archive.set('pushed_recipient', cuddleRequest.get('pushed_recipient'));
			archive.set('creatorSharedLocation', cuddleRequest.get('creatorSharedLocation'));
			archive.set('recipientSharedLocation', cuddleRequest.get('recipientSharedLocation'));
			archive.set('creator_deleted', cuddleRequest.get('creator_deleted'));
			archive.set('recipient_deleted', cuddleRequest.get('recipient_deleted'));
			archive.set('status', cuddleRequest.get('status'));
			archive.set('creatorProfilePicURL', cuddleRequest.get('creatorProfilePicURL'));
			archive.set('deleted', cuddleRequest.get('deleted'));
			archive.set('expiry', cuddleRequest.get('expiry'));
			archive.set('recipientProfilePicURL', cuddleRequest.get('recipientProfilePicURL'));

			var promise = archive.save();
			promises.push(promise);

			var p2 = cuddleRequest.destroy();
			promises.push(p2);

			promise.then(function() {

				archiveCount++;

			}, function(error) {

				archiveError++;
				archive.destroy();
				console.error(JSON.stringify(error));
			});

			p2.then(function() {

				deleteCount++;
			}, function(error) {

				deleteError++;
				console.error(JSON.stringify(error));
			});


			
		});

	}).then(function() {

		Parse.Promise.when(promises).then(function() {

			response.success("" + archiveCount + " arch. w " + archiveError + " ar error, " + deleteCount + " del w " + deleteError + " errors.");
		});
	}, function(error) {

		console.error("Errored out: " + archiveCount + " arch. w " + archiveError + " ar error, " + deleteCount + " del w " + deleteError + " errors.");
		response.error(JSON.stringify(error));
	});
});