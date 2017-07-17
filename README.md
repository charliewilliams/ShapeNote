# ShapeNote
Companion iPhone app for shape-note singing

This app was written as a minutes-taking and general companion app for the ShapeNote community. I don't have time to maintain it and so I'm deprecating and open-sourcing it here.

Points of interest:
- Quiz with dynamic question generation based on the underlying data, which I'm fairly proud of
- Core Data to store song info, read from JSON on first launch (this could be pulled out into a pre-deploy step if the JSON contained sensitive information, but since it doesn't this is easy)

Theoretical future enhancements:
-Auto-ingestion of singers' information in each geographical group
-Cloud storage of group minutes
-Sharing of cloud-stored minutes among group members
-GameKit integration for challenges singers can complete
-Leaderboards to see singers' choices in an intuitive format

