This is a visualization of all the addresses present in the latest release of Panama Papers.

The source : https://offshoreleaks.icij.org/pages/database
Total addresses : 151054
Redacted: 15
Missing : 4
Indian Addresses : 828
Correctly geocoded : 627
Wrongly geocoded : 38 + 163 unsearchable, due to wrong spellings or incorrect addresses. 

The source file was used to create a file with all the Indian addresses in it. The file was used to process and search for their
coordinates. The code used is in the r file. An rmd file also accompanies the same as it was used to knit the html.
The html was further modified to embed two maps.
The first one is a heatmap which clearly shows the concentration of the addresses spread across the country. And the results are as
expected, the majority being centered around the metros.
The second one provides a more indepth view of the addresses as it can be used to see particular areas of interests with their addresses
mentioned along with it.
The render of the html can be found at:
https://cdn.rawgit.com/vinyasmusic/Projects/master/Panama%20Papers/Indian%20Addresses.html
The final geocoded csv is also included in the project folder.

To do :
1. Fix the missing 163 values
2. Correct the 38 wrongly geocoded addresses.
3. Create a better connected visualization which shows which address was connected to which bank and where.

