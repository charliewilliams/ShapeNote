# ShapeNote
Companion iPhone app for shape-note singing

This app was written as a minutes-taking and general companion app for the ShapeNote community. I don't have time to maintain it and so I'm deprecating and open-sourcing it here.

If you don't sing [Sacred Harp](https://en.wikipedia.org/wiki/Sacred_Harp), you may find some of the information in the app confusing. For code-review purposes, it will suffice to say that it's an *a capella* singing tradition dating back to the 17th century. The "shape note" system was designed to allow people who weren't necessarily literate to sing from printed music— the corresponding texts would have been familiar to those in the community at the time. While it developed as an *intensely* religious tradition, in modern practice you will find secular and religious folk singing together. A final point is that there are no leaders; it isn't a "choir" with a director— everyone at the singing who wishes to takes it in turn to choose and lead a song.

Points of interest:
- Quiz with dynamic question generation based on the underlying data, which I'm fairly proud of
- Core Data to store song info, read from JSON on first launch (this could be pulled out into a pre-deploy step if the JSON contained sensitive information, but since it doesn't this is easy to work with and update as a developer)

Theoretical future enhancements:
- Auto-ingestion of singers' information in each geographical group
- Cloud storage of group minutes
- Sharing of cloud-stored minutes among group members
- GameKit integration for challenges singers can complete (i.e. on the quiz)
- Leaderboards to see singers' choices in an intuitive format

![screenshot](https://raw.githubusercontent.com/charliewilliams/ShapeNote/master/Screenshots/2.jpeg)
![screenshot](https://raw.githubusercontent.com/charliewilliams/ShapeNote/master/Screenshots/3.jpeg)
![screenshot](https://raw.githubusercontent.com/charliewilliams/ShapeNote/master/Screenshots/1.jpeg)
